require 'spec_helper'

describe "Running mspec" do
  it "runs the specs" do
    fixtures = "spec/fixtures"
    out, ret = run_mspec("run", "#{fixtures}/a_spec.rb")
    out.should == <<EOS
RUBY_DESCRIPTION
.FE

1)
Foo#bar errors FAILED
Expected 1
 to equal 2

CWD/spec/fixtures/a_spec.rb:8:in `block (2 levels) in <top (required)>'
CWD/spec/fixtures/a_spec.rb:2:in `<top (required)>'
CWD/bin/mspec-run:7:in `<main>'

2)
Foo#bar fails ERROR
RuntimeError: failure
CWD/spec/fixtures/a_spec.rb:12:in `block (2 levels) in <top (required)>'
CWD/spec/fixtures/a_spec.rb:2:in `<top (required)>'
CWD/bin/mspec-run:7:in `<main>'

Finished in D.DDDDDD seconds

1 file, 3 examples, 2 expectations, 1 failure, 1 error, 0 tagged
EOS
    ret.success?.should == false
  end

  it "runs the specs in parallel with -j" do
    fixtures = "spec/fixtures"
    out, ret = run_mspec("run", "-j #{fixtures}/a_spec.rb #{fixtures}/b_spec.rb")
    progress_bar =
      "\r[/ |                   0%                     | 00:00:00] \e[0;32m     0F \e[0;32m     0E\e[0m" +
      "\r[- | ==================50%                    | 00:00:00] \e[0;32m     0F \e[0;32m     0E\e[0m" +
      "\r[\\ | ==================100%================== | 00:00:00] \e[0;32m     0F \e[0;32m     0E\e[0m"
    out.should == <<EOS
RUBY_DESCRIPTION
#{progress_bar}

1)
Foo#bar errors FAILED
Expected 1
 to equal 2

CWD/spec/fixtures/a_spec.rb:8:in `block (2 levels) in <top (required)>'
CWD/spec/fixtures/a_spec.rb:2:in `<top (required)>'
CWD/bin/mspec-run:7:in `<main>'

2)
Foo#bar fails ERROR
RuntimeError: failure
CWD/spec/fixtures/a_spec.rb:12:in `block (2 levels) in <top (required)>'
CWD/spec/fixtures/a_spec.rb:2:in `<top (required)>'
CWD/bin/mspec-run:7:in `<main>'

Finished in D.DDDDDD seconds

2 files, 4 examples, 3 expectations, 1 failure, 1 error, 0 tagged
EOS
    ret.success?.should == false
  end
end
