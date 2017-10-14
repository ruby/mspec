require 'mspec/helpers/io'

class ComplainMatcher
  def initialize(complaint)
    @complaint = complaint
  end

  def matches?(proc)
    @saved_err = $stderr
    @verbose = $VERBOSE

    $stderr = IOStub.new
    $VERBOSE = false

    proc.call

    @warning = $stderr.to_s
    unless @complaint.nil?
      case @complaint
      when Regexp
        return false unless @warning =~ @complaint
      else
        return false unless @warning == @complaint
      end
    end

    return @warning.empty? ? false : true
  ensure
    $VERBOSE = @verbose
    $stderr = @saved_err
  end

  def failure_message
    if @complaint.nil?
      ["Expected a warning", "but received none"]
    elsif @complaint.kind_of? Regexp
      ["Expected warning to match: #{@complaint.inspect}", "but got: #{@warning.chomp.inspect}"]
    else
      ["Expected warning: #{@complaint.inspect}", "but got: #{@warning.chomp.inspect}"]
    end
  end

  def negative_failure_message
    if @complaint.nil?
      ["Unexpected warning: ", @warning.chomp.inspect]
    elsif @complaint.kind_of? Regexp
      ["Expected warning not to match: #{@complaint.inspect}", "but got: #{@warning.chomp.inspect}"]
    else
      ["Expected warning: #{@complaint.inspect}", "but got: #{@warning.chomp.inspect}"]
    end
  end
end

module MSpecMatchers
  private def complain(complaint=nil)
    ComplainMatcher.new(complaint)
  end
end
