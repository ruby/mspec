class EqualElementMatcher
  def initialize(element, attributes = nil, content = nil)
    @element = element
    @attributes = attributes
    @content = content
  end
 
  def matches?(actual)
    @actual = actual
    
    matched = actual =~ /^#{Regexp.quote("<" + @element)}/
    matched &&= actual =~ /#{Regexp.quote("</" + @element + ">")}$/
    matched &&= actual =~ /#{Regexp.quote(">" + @content + "</")}/ if @content
    
    if @attributes
      if @attributes.empty?
        matched &&= actual.scan(/\w+\=\"(.*)\"/).size == 0
      else
        @attributes.each do |key, value|
          matched &&= (actual.scan(%Q{ #{key}="#{value}"}).size == 1)
        end        
      end
    end
    
    !!matched
  end
 
  def failure_message
    ["Expected #{@actual.pretty_inspect}",
     "to be a '#{@element}' element with #{attributes_for_failure_message} and #{content_for_failure_message}"]
  end
 
  def negative_failure_message
    ["Expected #{@actual.pretty_inspect}",
      "not to be a '#{@element}' element with #{attributes_for_failure_message} and #{content_for_failure_message}"]
  end

  def attributes_for_failure_message
    if @attributes
      if @attributes.empty?
        "no attributes"
      else
        @attributes.inject([]) { |memo, n| memo << %Q{#{n[0]}="#{n[1]}"} }.join(" ")
      end
    else
      "any attributes"
    end
  end
 
  def content_for_failure_message
    if @content
      if @content.empty?
        "no content"
      else  
        "#{@content.inspect} as content"
      end
    else
      "any content"
    end
  end
end
 
class Object
  def equal_element(*args)
    EqualElementMatcher.new(*args)
  end
end