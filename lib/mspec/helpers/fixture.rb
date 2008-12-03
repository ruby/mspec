class Object
  # Returns the name of a fixture file by adjoining the directory
  # of the +dir+ argument with "fixtures" and the contents of the
  # +args+ array. For example,
  #
  #   +dir+ == "some/path"
  #
  # and
  #
  #   +args+ == ["dir", "file.txt"]
  #
  # then the result is the expanded path of
  #
  #   "some/fixtures/dir/file.txt".
  def fixture(dir, *args)
    File.expand_path(File.join(File.dirname(dir), "fixtures", args))
  end
end
