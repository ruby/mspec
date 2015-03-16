class Object
  def mock_to_path(path)
    obj = double('path')
    obj.should_receive(:to_path).and_return(path)
    obj
  end
end
