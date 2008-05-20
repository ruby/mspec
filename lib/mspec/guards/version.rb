require 'mspec/guards/guard'

class VersionGuard < SpecGuard
  def initialize(*versions)
    @versions = versions
  end

  def match?
    @versions.any? do |version|
      case version
      when :standard
        RUBY_VERSION == "1.8.6" && RUBY_PATCHLEVEL == 114
      when :development
        RUBY_VERSION == "1.8.7"
      when :experimental
        RUBY_VERSION == "1.9.0"
      end
    end
  end
end

class Object
  def ruby_version_is(*args)
    g = VersionGuard.new(*args)
    yield if g.yield?
    g.unregister
  end
end
