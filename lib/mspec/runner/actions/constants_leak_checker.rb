class ConstantsLeakChecker
  attr_accessor :constants_new

  def initialize
    @constants_before = Module.constants
  end

  def check
    @constants_after = Module.constants
    @constants_new = @constants_after - @constants_before
    @constants_new.empty?
  end
end

class ConstantsLockFile
  LOCK_FILE_NAME = '.mspec.constants.lock'

  def self.exist?
    File.exist?(LOCK_FILE_NAME)
  end

  def self.load
    File.read(LOCK_FILE_NAME).split
  end

  def self.dump(ary)
    File.write(LOCK_FILE_NAME, ary.map(&:to_s).uniq.sort.join("\n"))
  end
end

class ConstantsLeakLockAction
  def register
    MSpec.register :start, self
    MSpec.register :finish, self
  end

  def start
    @checker = ConstantsLeakChecker.new
  end

  def finish
    unless @checker.check
      if ConstantsLockFile.exist?
        constants_locked = ConstantsLockFile.load
        result = constants_locked | @checker.constants_new.map(&:to_s)
        ConstantsLockFile.dump(result)
      else
        ConstantsLockFile.dump(@checker.constants_new)
      end
    end
  end
end

class ConstantsLeakCheckerAction
  def register
    MSpec.register :start, self
    MSpec.register :finish, self
  end

  def start
    @checker = ConstantsLeakChecker.new
  end

  def finish
    unless @checker.check
      constants = @checker.constants_new.map(&:to_s) - constants_locked

      unless constants.empty?
        puts "\nNew top level constants found:"
        puts constants.join(", ")

        MSpec.register_exit 1
      end
    end
  end

  private

  def constants_locked
    if ConstantsLockFile.exist?
      ConstantsLockFile.load
    else
      []
    end
  end
end
