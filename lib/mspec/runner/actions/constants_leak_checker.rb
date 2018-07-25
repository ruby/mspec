class ConstantsLockFile
  LOCK_FILE_NAME = '.mspec.constants.lock'

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
    constants_new = constants_now - constants_before - constants_locked
    constants_new = remove_helpers(constants_new)

    MSpec.protect 'Leaks check' do
      if !constants_new.empty? && ENV['CHECK_LEAKS']
        raise ConstantLeakError, "Top level constants leaked: #{constants_new.join(', ')}"
      end
    end
  end

  def finish
    constants_new = remove_helpers(constants_now - constants_start)

    if MSpec.exit_code == 0 && !ENV['CHECK_LEAKS']
      ConstantsLockFile.dump(constants_locked + constants_new)
    end

    MSpec.protect 'Global leaks check' do
      if !constants_new.empty? && ENV['CHECK_LEAKS']
        raise ConstantLeakError, "Top level constants leaked in the whole test suite: #{constants_new.join(', ')}"
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
