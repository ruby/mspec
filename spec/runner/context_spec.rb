require File.dirname(__FILE__) + '/../spec_helper'
require 'mspec/expectations/expectations'
require 'mspec/matchers/base'
require 'mspec/runner/mspec'
require 'mspec/mocks/mock'
require 'mspec/runner/context'

describe ContextState, "#describe" do
  before :each do
    @state = ContextState.new
    @proc = lambda { ScratchPad.record :a }
    ScratchPad.clear
  end

  it "evaluates the passed block" do
    @state.describe(Object, &@proc)
    ScratchPad.recorded.should == :a
  end

  it "sets the description string" do
    @state.description.should be_nil
    @state.describe("Object#to_s") { }
    @state.description.should == "Object#to_s"
  end

  it "registers #parent as the current MSpec ContextState" do
    parent = ContextState.new
    @state.parent = parent
    MSpec.should_receive(:register_current).with(parent)
    @state.describe("C#m") { }
  end

  it "registers nil as the current MSpec ContextState if it has no parent" do
    MSpec.should_receive(:register_current).with(nil)
    @state.describe("C#m") { }
  end
end

describe ContextState, "#description when there are no parents" do
  before :each do
    @state = ContextState.new
  end

  it "returns a description string for self when passed a Module" do
    @state.describe(Object) { }
    @state.description.should == "Object"
  end

  it "returns a description string for self when passed a String" do
    @state.describe("SomeClass") { }
    @state.description.should == "SomeClass"
  end

  it "returns a description string for self when passed a Module, String" do
    @state.describe(Object, "when empty") { }
    @state.description.should == "Object when empty"
  end

  it "returns a description string for self when passed a Module and String beginning with '#'" do
    @state.describe(Object, "#to_s") { }
    @state.description.should == "Object#to_s"
  end

  it "returns a description string for self when passed a Module and String beginning with '.'" do
    @state.describe(Object, ".to_s") { }
    @state.description.should == "Object.to_s"
  end

  it "returns a description string for self when passed a Module and String beginning with '::'" do
    @state.describe(Object, "::to_s") { }
    @state.description.should == "Object::to_s"
  end
end

describe ContextState, "#description when there are parents" do
  before :each do
    @state = ContextState.new
    @parent = ContextState.new
    @state.parent = @parent
  end

  it "returns a composite description string from self and all parents" do
    @parent.describe("Toplevel") { }
    @state.describe("when empty") { }
    @state.description.should == "Toplevel when empty"
  end
end

describe ContextState, "#it" do
  before :each do
    @state = ContextState.new
    @proc = lambda { }
  end

  it "creates an ExampleState instance for the block" do
    ex = ExampleState.new("", "", &@proc)
    ExampleState.should_receive(:new).with("describe", "it", @proc).and_return(ex)
    @state.describe("describe", &@proc)
    @state.it("it", &@proc)
  end
end

describe ContextState, "#examples" do
  before :each do
    @state = ContextState.new
  end

  it "returns a list of all examples in this ContextState" do
    @state.it("first") { }
    @state.it("second") { }
    @state.examples.size.should == 2
  end
end

describe ContextState, "#before" do
  before :each do
    @state = ContextState.new
    @proc = lambda { }
  end

  it "records the block for :each" do
    @state.before(:each, &@proc)
    @state.before(:each).should == [@proc]
  end

  it "records the block for :all" do
    @state.before(:all, &@proc)
    @state.before(:all).should == [@proc]
  end
end

describe ContextState, "#after" do
  before :each do
    @state = ContextState.new
    @proc = lambda { }
  end

  it "records the block for :each" do
    @state.after(:each, &@proc)
    @state.after(:each).should == [@proc]
  end

  it "records the block for :all" do
    @state.after(:all, &@proc)
    @state.after(:all).should == [@proc]
  end
end

describe ContextState, "#pre" do
  before :each do
    @a = lambda { }
    @b = lambda { }
    @c = lambda { }

    parent = ContextState.new
    parent.before(:each, &@c)
    parent.before(:all, &@c)

    @state = ContextState.new
    @state.parent = parent
  end

  it "returns before(:each) actions in the order they were defined" do
    @state.before(:each, &@a)
    @state.before(:each, &@b)
    @state.pre(:each).should == [@c, @a, @b]
  end

  it "returns before(:all) actions in the order they were defined" do
    @state.before(:all, &@a)
    @state.before(:all, &@b)
    @state.pre(:all).should == [@c, @a, @b]
  end
end

describe ContextState, "#post" do
  before :each do
    @a = lambda { }
    @b = lambda { }
    @c = lambda { }

    parent = ContextState.new
    parent.after(:each, &@c)
    parent.after(:all, &@c)

    @state = ContextState.new
    @state.parent = parent
  end

  it "returns after(:each) actions in the reverse order they were defined" do
    @state.after(:each, &@a)
    @state.after(:each, &@b)
    @state.post(:each).should == [@b, @a, @c]
  end

  it "returns after(:all) actions in the reverse order they were defined" do
    @state.after(:all, &@a)
    @state.after(:all, &@b)
    @state.post(:all).should == [@b, @a, @c]
  end
end

describe ContextState, "#protect" do
  before :each do
    ScratchPad.record []
    @a = lambda { ScratchPad << :a }
    @b = lambda { ScratchPad << :b }
    @c = lambda { raise Exception, "Fail!" }
  end

  it "returns true and does execute any blocks if check is true and MSpec.pretend_mode? is true" do
    MSpec.stub!(:pretend_mode?).and_return(true)
    ContextState.new.protect("message", [@a, @b]).should be_true
    ScratchPad.recorded.should == []
  end

  it "executes the blocks if MSpec.pretend_mode? is false" do
    MSpec.stub!(:pretend_mode?).and_return(false)
    ContextState.new.protect("message", [@a, @b])
    ScratchPad.recorded.should == [:a, :b]
  end

  it "executes the blocks if check is false" do
    ContextState.new.protect("message", [@a, @b], false)
    ScratchPad.recorded.should == [:a, :b]
  end

  it "returns true if none of the blocks raise an exception" do
    ContextState.new.protect("message", [@a, @b]).should be_true
  end

  it "returns false if any of the blocks raise an exception" do
    ContextState.new.protect("message", [@a, @c, @b]).should be_false
  end
end

describe ContextState, "#parent=" do
  before :each do
    @state = ContextState.new
    @parent = mock("describe")
    @parent.stub!(:parent).and_return(nil)
    @parent.stub!(:child)
  end

  it "sets self as a child of parent" do
    @parent.should_receive(:child).with(@state)
    @state.parent = @parent
  end

  it "creates the list of parents" do
    @state.parent = @parent
    @state.parents.should == [@parent, @state]
  end
end

describe ContextState, "#parent" do
  before :each do
    @state = ContextState.new
    @parent = mock("describe")
    @parent.stub!(:parent).and_return(nil)
    @parent.stub!(:child)
  end

  it "returns nil if parent has not been set" do
    @state.parent.should be_nil
  end

  it "returns the parent" do
    @state.parent = @parent
    @state.parent.should == @parent
  end
end

describe ContextState, "#parents" do
  before :each do
    @first = ContextState.new
    @second = ContextState.new
    @parent = mock("describe")
    @parent.stub!(:parent).and_return(nil)
    @parent.stub!(:child)
  end

  it "returns a list of all enclosing ContextState instances" do
    @first.parent = @parent
    @second.parent = @first
    @second.parents.should == [@parent, @first, @second]
  end
end

describe ContextState, "#child" do
  before :each do
    @first = ContextState.new
    @second = ContextState.new
    @parent = mock("describe")
    @parent.stub!(:parent).and_return(nil)
    @parent.stub!(:child)
  end

  it "adds the ContextState to the list of contained ContextStates" do
    @first.child @second
    @first.children.should == [@second]
  end
end

describe ContextState, "#children" do
  before :each do
    @parent = ContextState.new
    @first = ContextState.new
    @second = ContextState.new
  end

  it "returns the list of directly contained ContextStates" do
    @first.parent = @parent
    @second.parent = @first
    @parent.children.should == [@first]
    @first.children.should == [@second]
  end
end

describe ContextState, "#state" do
  before :each do
    MSpec.store :before, []
    MSpec.store :after, []

    @state = ContextState.new
  end

  it "returns nil if no spec is being executed" do
    @state.state.should == nil
  end

  it "returns a ExampleState instance if an example is being executed" do
    ScratchPad.record @state
    @state.describe("") { }
    @state.it("") { ScratchPad.record ScratchPad.recorded.state }
    @state.process
    @state.state.should == nil
    ScratchPad.recorded.should be_kind_of(ExampleState)
  end
end

describe ContextState, "#process" do
  before :each do
    MSpec.store :before, []
    MSpec.store :after, []
    MSpec.stub!(:register_current)

    @state = ContextState.new
    @state.describe("") { }

    @a = lambda { ScratchPad << :a }
    @b = lambda { ScratchPad << :b }
    ScratchPad.record []
  end

  it "calls each before(:all) block" do
    @state.before(:all, &@a)
    @state.before(:all, &@b)
    @state.it("") { }
    @state.process
    ScratchPad.recorded.should == [:a, :b]
  end

  it "calls each after(:all) block" do
    @state.after(:all, &@a)
    @state.after(:all, &@b)
    @state.it("") { }
    @state.process
    ScratchPad.recorded.should == [:b, :a]
  end

  it "calls each it block" do
    @state.it("one", &@a)
    @state.it("two", &@b)
    @state.process
    ScratchPad.recorded.should == [:a, :b]
  end

  it "calls each before(:each) block" do
    @state.before(:each, &@a)
    @state.before(:each, &@b)
    @state.it("") { }
    @state.process
    ScratchPad.recorded.should == [:a, :b]
  end

  it "calls each after(:each) block" do
    @state.after(:each, &@a)
    @state.after(:each, &@b)
    @state.it("") { }
    @state.process
    ScratchPad.recorded.should == [:b, :a]
  end

  it "calls Mock.cleanup for each it block" do
    @state.it("") { }
    @state.it("") { }
    Mock.should_receive(:cleanup).twice
    @state.process
  end

  it "calls Mock.verify_count for each it block" do
    @state.it("") { }
    @state.it("") { }
    Mock.should_receive(:verify_count).twice
    @state.process
  end

  it "calls the describe block" do
    ScratchPad.record []
    @state.describe(Object, "msg") { ScratchPad << :a }
    @state.process
    ScratchPad.recorded.should == [:a]
  end

  it "creates a new ExampleState instance for each example" do
    ScratchPad.record @state
    @state.describe("desc") { }
    @state.it("it") { ScratchPad.record ScratchPad.recorded.state }
    @state.process
    ScratchPad.recorded.should be_kind_of(ExampleState)
  end

  it "clears the expectations flag before evaluating the #it block" do
    MSpec.clear_expectations
    MSpec.should_receive(:clear_expectations)
    @state.it("it") { ScratchPad.record MSpec.expectation? }
    @state.process
    ScratchPad.recorded.should be_false
  end

  it "shuffles the spec list if MSpec.randomize? is true" do
    MSpec.randomize
    MSpec.should_receive(:shuffle)
    @state.it("") { }
    @state.process
    MSpec.randomize false
  end

  it "sets the current MSpec ContextState" do
    MSpec.should_receive(:register_current).with(@state)
    @state.process
  end

  it "resets the current MSpec ContextState to nil when there are examples" do
    MSpec.should_receive(:register_current).with(nil)
    @state.it("") { }
    @state.process
  end

  it "resets the current MSpec ContextState to nil when there are no examples" do
    MSpec.should_receive(:register_current).with(nil)
    @state.process
  end

  it "call #process on children when there are examples" do
    child = ContextState.new
    child.should_receive(:process)
    @state.child child
    @state.it("") { }
    @state.process
  end

  it "call #process on children when there are no examples" do
    child = ContextState.new
    child.should_receive(:process)
    @state.child child
    @state.process
  end
end

describe ContextState, "#process" do
  before :each do
    MSpec.store :exception, []

    @state = ContextState.new
    @state.describe("") { }

    action = mock("action")
    def action.exception(exc)
      ScratchPad.record :exception if exc.exception.is_a? ExpectationNotFoundError
    end
    MSpec.register :exception, action

    MSpec.clear_expectations
    ScratchPad.clear
  end

  after :each do
    MSpec.store :exception, nil
  end

  it "raises an ExpectationNotFoundError if an #it block does not contain an expectation" do
    @state.it("it") { }
    @state.process
    ScratchPad.recorded.should == :exception
  end

  it "does not raise an ExpectationNotFoundError if an #it block does contain an expectation" do
    @state.it("it") { MSpec.expectation }
    @state.process
    ScratchPad.recorded.should be_nil
  end

  it "does not raise an ExpectationNotFoundError if the #it block causes a failure" do
    @state.it("it") { raise Exception, "Failed!" }
    @state.process
    ScratchPad.recorded.should be_nil
  end
end

describe ContextState, "#process" do
  before :each do
    MSpec.store :example, []

    @state = ContextState.new
    @state.describe("") { }

    example = mock("example")
    def example.example(state, spec)
      ScratchPad << state << spec
    end
    MSpec.register :example, example

    ScratchPad.record []
  end

  after :each do
    MSpec.store :example, nil
  end

  it "calls registered example actions with the current ExampleState and block" do
    @state.it("") { MSpec.expectation }
    @state.process

    ScratchPad.recorded.first.should be_kind_of(ExampleState)
    ScratchPad.recorded.last.should be_kind_of(Proc)
  end

  it "does not call registered example actions if the example has no block" do
    @state.it("empty example")
    @state.process
    ScratchPad.recorded.should == []
  end
end

describe ContextState, "#process" do
  before :each do
    MSpec.store :before, []
    MSpec.store :after, []

    @state = ContextState.new
    @state.describe("") { }
    @state.it("") { MSpec.expectation }
  end

  after :each do
    MSpec.store :before, nil
    MSpec.store :after, nil
  end

  it "calls registered before actions with the current ExampleState instance" do
    before = mock("before")
    before.should_receive(:before).and_return {
      ScratchPad.record :before
      @spec_state = @state.state
    }
    MSpec.register :before, before
    @state.process
    ScratchPad.recorded.should == :before
    @spec_state.should be_kind_of(ExampleState)
  end

  it "calls registered after actions with the current ExampleState instance" do
    after = mock("after")
    after.should_receive(:after).and_return {
      ScratchPad.record :after
      @spec_state = @state.state
    }
    MSpec.register :after, after
    @state.process
    ScratchPad.recorded.should == :after
    @spec_state.should be_kind_of(ExampleState)
  end
end

describe ContextState, "#process" do
end

describe ContextState, "#process" do
  before :each do
    MSpec.store :enter, []
    MSpec.store :leave, []

    @state = ContextState.new
    @state.describe("") { }
    @state.it("") { MSpec.expectation }
  end

  after :each do
    MSpec.store :enter, nil
    MSpec.store :leave, nil
  end

  it "calls registered enter actions with the current #describe string" do
    enter = mock("enter")
    enter.should_receive(:enter).and_return { ScratchPad.record :enter }
    MSpec.register :enter, enter
    @state.process
    ScratchPad.recorded.should == :enter
  end

  it "calls registered leave actions" do
    leave = mock("leave")
    leave.should_receive(:leave).and_return { ScratchPad.record :leave }
    MSpec.register :leave, leave
    @state.process
    ScratchPad.recorded.should == :leave
  end
end

describe ContextState, "#process when an exception is raised in before(:all)" do
  before :each do
    MSpec.store :before, []
    MSpec.store :after, []

    @state = ContextState.new
    @state.describe("") { }

    @a = lambda { ScratchPad << :a }
    @b = lambda { ScratchPad << :b }
    ScratchPad.record []

    @state.before(:all) { raise Exception, "Fail!" }
  end

  after :each do
    MSpec.store :before, nil
    MSpec.store :after, nil
  end

  it "does not call before(:each)" do
    @state.before(:each, &@a)
    @state.it("") { }
    @state.process
    ScratchPad.recorded.should == []
  end

  it "does not call the it block" do
    @state.it("one", &@a)
    @state.process
    ScratchPad.recorded.should == []
  end

  it "does not call after(:each)" do
    @state.after(:each, &@a)
    @state.it("") { }
    @state.process
    ScratchPad.recorded.should == []
  end

  it "does not call after(:each)" do
    @state.after(:all, &@a)
    @state.it("") { }
    @state.process
    ScratchPad.recorded.should == []
  end

  it "does not call Mock.verify_count" do
    @state.it("") { }
    Mock.should_not_receive(:verify_count)
    @state.process
  end

  it "calls Mock.cleanup" do
    @state.it("") { }
    Mock.should_receive(:cleanup)
    @state.process
  end
end

describe ContextState, "#process when an exception is raised in before(:each)" do
  before :each do
    MSpec.store :before, []
    MSpec.store :after, []

    @state = ContextState.new
    @state.describe("") { }

    @a = lambda { ScratchPad << :a }
    @b = lambda { ScratchPad << :b }
    ScratchPad.record []

    @state.before(:each) { raise Exception, "Fail!" }
  end

  after :each do
    MSpec.store :before, nil
    MSpec.store :after, nil
  end

  it "does not call the it block" do
    @state.it("one", &@a)
    @state.process
    ScratchPad.recorded.should == []
  end

  it "does not call after(:each)" do
    @state.after(:each, &@a)
    @state.it("") { }
    @state.process
    ScratchPad.recorded.should == []
  end

  it "does not call Mock.verify_count" do
    @state.it("") { }
    Mock.should_not_receive(:verify_count)
    @state.process
  end
end

describe ContextState, "#process in pretend mode" do
  before :all do
    MSpec.register_mode :pretend
  end

  after :all do
    MSpec.register_mode nil
  end

  before :each do
    ScratchPad.clear
    MSpec.store :before, []
    MSpec.store :after, []

    @state = ContextState.new
    @state.describe("") { }
    @state.it("") { }
  end

  after :each do
    MSpec.store :before, nil
    MSpec.store :after, nil
  end

  it "calls registered before actions with the current ExampleState instance" do
    before = mock("before")
    before.should_receive(:before).and_return {
      ScratchPad.record :before
      @spec_state = @state.state
    }
    MSpec.register :before, before
    @state.process
    ScratchPad.recorded.should == :before
    @spec_state.should be_kind_of(ExampleState)
  end

  it "calls registered after actions with the current ExampleState instance" do
    after = mock("after")
    after.should_receive(:after).and_return {
      ScratchPad.record :after
      @spec_state = @state.state
    }
    MSpec.register :after, after
    @state.process
    ScratchPad.recorded.should == :after
    @spec_state.should be_kind_of(ExampleState)
  end
end

describe ContextState, "#process in pretend mode" do
  before :all do
    MSpec.register_mode :pretend
  end

  after :all do
    MSpec.register_mode nil
  end

  before :each do
    MSpec.store :before, []
    MSpec.store :after, []

    @state = ContextState.new
    @state.describe("") { }

    @a = lambda { ScratchPad << :a }
    @b = lambda { ScratchPad << :b }
    ScratchPad.record []
  end

  it "calls the describe block" do
    ScratchPad.record []
    @state.describe(Object, "msg") { ScratchPad << :a }
    @state.process
    ScratchPad.recorded.should == [:a]
  end

  it "does not call any before(:all) block" do
    @state.before(:all, &@a)
    @state.before(:all, &@b)
    @state.it("") { }
    @state.process
    ScratchPad.recorded.should == []
  end

  it "does not call any after(:all) block" do
    @state.after(:all, &@a)
    @state.after(:all, &@b)
    @state.it("") { }
    @state.process
    ScratchPad.recorded.should == []
  end

  it "does not call any it block" do
    @state.it("one", &@a)
    @state.it("two", &@b)
    @state.process
    ScratchPad.recorded.should == []
  end

  it "does not call any before(:each) block" do
    @state.before(:each, &@a)
    @state.before(:each, &@b)
    @state.it("") { }
    @state.process
    ScratchPad.recorded.should == []
  end

  it "does not call any after(:each) block" do
    @state.after(:each, &@a)
    @state.after(:each, &@b)
    @state.it("") { }
    @state.process
    ScratchPad.recorded.should == []
  end

  it "does not call Mock.cleanup" do
    @state.it("") { }
    @state.it("") { }
    Mock.should_not_receive(:cleanup)
    @state.process
  end
end

describe ContextState, "#process in pretend mode" do
  before :all do
    MSpec.register_mode :pretend
  end

  after :all do
    MSpec.register_mode nil
  end

  before :each do
    MSpec.store :enter, []
    MSpec.store :leave, []

    @state = ContextState.new
    @state.describe("") { }
    @state.it("") { }
  end

  after :each do
    MSpec.store :enter, nil
    MSpec.store :leave, nil
  end

  it "calls registered enter actions with the current #describe string" do
    enter = mock("enter")
    enter.should_receive(:enter).and_return { ScratchPad.record :enter }
    MSpec.register :enter, enter
    @state.process
    ScratchPad.recorded.should == :enter
  end

  it "calls registered leave actions" do
    leave = mock("leave")
    leave.should_receive(:leave).and_return { ScratchPad.record :leave }
    MSpec.register :leave, leave
    @state.process
    ScratchPad.recorded.should == :leave
  end
end
