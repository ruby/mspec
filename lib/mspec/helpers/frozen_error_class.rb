# This helper makes it easy to write version independent
# specs for frozen objects.
unless respond_to? :frozen_error_class
  if VersionGuard.new("2.5").match?
    def frozen_error_class
      FrozenError
    end
  else
    def frozen_error_class
      RuntimeError
    end
  end
end
