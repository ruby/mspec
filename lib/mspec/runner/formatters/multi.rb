require 'mspec/runner/formatters/dotted'

class MultiFormatter < DottedFormatter
  def initialize(timer, tally, exceptions)
    super(nil)
    @timer = timer
    @tally = tally
    @exceptions = exceptions
  end

  def print_exception(exc, count)
    print "\n#{count})\n#{exc}\n"
  end
end
