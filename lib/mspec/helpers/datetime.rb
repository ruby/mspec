class Object
  # the following helper provides some comfort at
  # writing and reading tests against implementations
  # of DateTime
  
  # This function let's you create a new DateTime object with only the
  # parameters, you are interested in.
  # new_datetime :hour => 1, :minute => 20
  # possible values are: year, month, day, hour, minute, second, offset and sg
  def new_datetime(value = nil)
    default = {
      :year   => -4712,
      :month  => 1,
      :day    => 1,
      :hour   => 0,
      :minute => 0,
      :second => 0,
      :offset => 0,
      :sg     => Date::ITALY
    }
    if value.is_a? Hash
      value = default.merge(value)
    else
      value = default
    end

    DateTime.new value[:year], value[:month], value[:day], value[:hour],
      value[:minute], value[:second], value[:offset], value[:sg]
  end
end
