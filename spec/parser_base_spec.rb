require File.expand_path('../support/spec_helper.rb', __FILE__)

describe RDParser::RDParser, :focused => true do
  context "given a very simple grammar" do
    parser do |p|
      p.expression  '"a" expression1'
      p.expression1 '"s" expression2'
      p.expression2 /^.*$/
    end

    # TODO test failed messages somehow -- cucumber?
    #it { should_not parse("asdf").with error_on_position(1) }
    #it { should_not parse("asdf") }
    #it { should     parse("qwer") }

    it { should     parse("asdf") }
    it { should_not parse("qwer") }
    it { should_not parse("awer").with error_on_position(1) }
  end
end

