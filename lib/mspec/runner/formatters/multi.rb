require 'mspec/runner/formatters/dotted'
require 'yaml'

class MultiFormatter < DottedFormatter
  def initialize(out=nil)
    super(out)
    @timer = TimerAction.new
    @timer.start
  end

  def aggregate_results(files)
    @timer.finish
    @exceptions = []
    @tally = Tally.new

    files.each do |file|
      d = File.open(file, "r") { |f| YAML.load f }
      File.delete file

      @exceptions += Array(d['exceptions'])
      @tally.files!        d['files']
      @tally.examples!     d['examples']
      @tally.expectations! d['expectations']
      @tally.errors!       d['errors']
      @tally.failures!     d['failures']
    end
  end

  def print_exception(exc, count)
    print "\n#{count})\n#{exc}\n"
  end
end
