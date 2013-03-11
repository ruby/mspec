require 'mspec/guards/guard'

class Object
  # Helper for syntax-sensitive specs. The specs should be placed in a file in
  # the +versions+ subdirectory. For example, suppose language/method_spec.rb
  # contains specs whose syntax depends on the Ruby version. In the
  # language/method_spec.rb use the helper as follows:
  #
  #   language_version __FILE__, "method"
  #
  # Then add a file "language/versions/method_1.8.rb" for the specs that are
  # syntax-compatible with Ruby 1.8.x.
  #
  # The most version-specific file will be loaded. If the version is 1.8.6,
  # "method_1.8.6.rb" will be loaded if it exists, otherwise "method_1.8.rb"
  # will be loaded if it exists.
  def language_version(dir, name)
    dirpath = File.dirname(File.expand_path(dir))
    pattern = File.join dirpath, "versions", "#{name}_*.rb"
    versions = Dir[pattern].map{|path| path[/([\d.]+).rb\z/, 1] }.sort
    target = SpecGuard.ruby_version(:tiny)
    versions.reverse_each do |version|
      if (version <=> target) < 1
        file = File.join dirpath, "versions", "#{name}_#{version}.rb"
        if File.exists? file
          require file
          break
        end
      end
    end

    nil
  end
end
