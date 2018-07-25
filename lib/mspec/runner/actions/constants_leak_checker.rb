class ConstantsLockFile
  LOCK_FILE_NAME = '.mspec.constants'

  def self.load
    if File.exist?(LOCK_FILE_NAME)
      File.readlines(LOCK_FILE_NAME).map(&:chomp)
    else
      []
    end
  end

  def self.dump(ary)
    File.write(LOCK_FILE_NAME, ary.map(&:to_s).uniq.sort.join("\n"))
  end
end

class ConstantLeakError < StandardError
end

class ConstantsLeakCheckerAction
  attr_accessor :constants_start, :constants_before

  def register
    MSpec.register :start, self
    MSpec.register :before, self
    MSpec.register :after, self
    MSpec.register :finish, self
  end

  def start
    self.constants_start = constants_now
  end

  def before(state)
    self.constants_before = constants_now
  end

  def after(state)
    constants = remove_helpers(constants_now - constants_before - constants_locked)

    unless constants.empty?
      MSpec.protect 'Leaks check' do
        raise ConstantLeakError, "Top level constants leaked: #{constants.join(', ')}"
      end
    end
  end

  def finish
    constants = remove_helpers(constants_now - constants_start - constants_locked)

    if ENV['CHECK_LEAKS'] == 'save'
      ConstantsLockFile.dump(constants_locked + constants)
    end

    unless constants.empty?
      MSpec.protect 'Global leaks check' do
        raise ConstantLeakError, "Top level constants leaked in the whole test suite: #{constants.join(', ')}"
      end
    end
  end

  private

  def constants_locked
    @constants_locked ||= ConstantsLockFile.load
  end

  def constants_now
    Object.constants.map(&:to_s)
  end

  def remove_helpers(ary)
    ary.reject { |s| s =~ /\wSpecs?$/ }
  end
end
