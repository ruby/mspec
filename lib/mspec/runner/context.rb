require 'mspec/runner/mspec'
require 'mspec/runner/example'

# Holds the state of the +describe+ block that is being
# evaluated. Every example (i.e. +it+ block) is evaluated
# in a context, which may include state set up in <tt>before
# :each</tt> or <tt>before :all</tt> blocks.
#
#--
# A note on naming: this is named _ContextState_ rather
# than _DescribeState_ because +describe+ is the keyword
# in the DSL for refering to the context in which an example
# is evaluated, just as +it+ refers to the example itself.
#++
class ContextState
  attr_reader :state, :parent, :parents, :children, :examples, :description

  def initialize
    @parsed   = false
    @before   = { :all => [], :each => [] }
    @after    = { :all => [], :each => [] }
    @pre      = {}
    @post     = {}
    @examples = []
    @parent   = nil
    @parents  = [self]
    @children = []
    @mock_verify         = lambda { Mock.verify_count }
    @mock_cleanup        = lambda { Mock.cleanup }
    @expectation_missing = lambda { raise ExpectationNotFoundError }
  end

  # Set the parent (enclosing) +ContextState+ for this state. Creates
  # the +parents+ list.
  def parent=(parent)
    @parent = parent
    parent.child self if parent

    state = parent
    while state
      parents.unshift state
      state = state.parent
    end
  end

  # Add the ContextState instance +child+ to the list of nested
  # describe blocks.
  def child(child)
    @children << child
  end

  # Returns a list of all before(+what+) blocks from self and any parents.
  def pre(what)
    @pre[what] ||= parents.inject([]) { |l, s| l.push(*s.before(what)) }
  end

  # Returns a list of all after(+what+) blocks from self and any parents.
  # The list is in reverse order. In other words, the blocks defined in
  # inner describes are in the list before those defined in outer describes,
  # and in a particular describe block those defined later are in the list
  # before those defined earlier.
  def post(what)
    @post[what] ||= parents.inject([]) { |l, s| l.unshift(*s.after(what)) }
  end

  # Records before(:each) and before(:all) blocks.
  def before(what, &block)
    block ? @before[what].push(block) : @before[what]
  end

  # Records after(:each) and after(:all) blocks.
  def after(what, &block)
    block ? @after[what].unshift(block) : @after[what]
  end

  # Creates an ExampleState instance for the block and stores it
  # in a list of examples to evaluate unless the example is filtered.
  def it(desc, &block)
    example = ExampleState.new @description, desc, block
    @examples << example unless example.filtered?
  end

  # Evaluates the block and resets the toplevel +ContextState+ to #parent.
  def describe(mod, desc=nil, &block)
    description = parents.inject([]) { |l, s| l << s.description }.compact
    sep = /^(::|[.#])/ =~ desc ? "" : " "
    description << (desc ? "#{mod}#{sep}#{desc}" : mod.to_s)
    @description = description.join " "

    @parsed = protect @description, block, false
    MSpec.register_current parent
  end

  def protect(what, blocks, check=true)
    return true if check and MSpec.pretend_mode?
    Array(blocks).all? { |block| MSpec.protect what, &block }
  end

  def process
    MSpec.register_current self

    if @parsed and @examples.any? { |example| example.unfiltered? }
      MSpec.shuffle @examples if MSpec.randomize?
      MSpec.actions :enter, @description

      if protect "before :all", pre(:all)
        @examples.each do |state|
          @state  = state
          example = state.example
          MSpec.actions :before, state

          if protect "before :each", pre(:each)
            MSpec.clear_expectations
            if example
              passed = protect nil, example
              MSpec.actions :example, state, example
              protect nil, @expectation_missing unless MSpec.expectation? or not passed
            end
            protect "after :each", post(:each)
            protect "Mock.verify_count", @mock_verify
          end

          protect "Mock.cleanup", @mock_cleanup
          MSpec.actions :after, state
          @state = nil
        end
        protect "after :all", post(:all)
      else
        protect "Mock.cleanup", @mock_cleanup
      end

      MSpec.actions :leave
    end

    MSpec.register_current nil
    children.each { |child| child.process }
  end
end
