class Object
  def enumerator_class
    MSpec.deprecate "enumerator_class", "Enumerator"
    SpecVersion.new(RUBY_VERSION) < "1.9" ? Enumerable::Enumerator : Enumerator
  end
end
