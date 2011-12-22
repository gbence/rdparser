require File.expand_path('../support/spec_helper.rb', __FILE__)

describe RDParser::RDParser do
  context "given a very simple grammar" do
    include ParserHelper
    parser do |p|
      p.expression  '"a" expression1'
      p.expression1 /^.*$/
    end

    it { should     parse("asdf") }
    it { should_not parse("qwer") }
  end
end

