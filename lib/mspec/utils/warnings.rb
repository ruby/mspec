if RUBY_ENGINE == "ruby" and RUBY_VERSION >= "2.4.0"
  # Kernel#warn does not delegate to Warning.warn yet
  module Kernel
    def warn(*messages)
      return if messages.empty?
      msg = messages.join("\n")
      msg += "\n" unless msg.end_with?("\n")
      Warning.warn(msg) unless $VERBOSE == nil
    end
    private :warn
  end

  def Warning.warn(message)
    case message
    when /constant ::(Fixnum|Bignum) is deprecated/
    when /\/(argf|io|stringio)\/.+(ARGF|IO)#(lines|chars|bytes|codepoints) is deprecated/
    when /Thread\.exclusive is deprecated.+\n.+thread\/exclusive_spec\.rb/
    when /hash\/shared\/index\.rb:\d+: warning: Hash#index is deprecated; use Hash#key/
    when /env\/shared\/key\.rb:\d+: warning: ENV\.index is deprecated; use ENV\.key/
    when /exponent(_spec)?\.rb:\d+: warning: in a\*\*b, b may be too big/
    when /enumerator\/(new|initialize_spec)\.rb:\d+: warning: Enumerator\.new without a block is deprecated/
    else
      $stderr.write message
    end
  end
else
  $VERBOSE = nil unless ENV['OUTPUT_WARNINGS']
end
