require 'mspec/guards/guard'

class UserGuard < SpecGuard
  def match?
    Process.euid != 0
  end
end

class Object
  def as_user(&block)
    UserGuard.new.run_if(:as_user, &block)
  end
end
