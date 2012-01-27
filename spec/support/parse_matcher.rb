module RDParser::ParseMatcher
  class Parse
    def initialize expression, root
      @expression = expression
      @root       = root
    end

    def matches? parser
      parser.parse(@root, @expression).kind_of?(Array)
      return true
    rescue RDParser::ParseError
      @error_on_position = $!.position
      @error_in_content  = $!.content
      return false
    end

    def failure_message
      %{Grammar should parse "#{@expression}" starting with :#{@root} but error was catched on position #{@error_on_position}! "#{@expression[0...@error_on_position]}|#{@expression[@error_on_position..@error_on_position]}|#{@expression[@error_on_position+1..-1]}"}
    end

    def negative_failure_message
      %{Grammar should not parse "#{@expression}" starting with :#{@root}} + (@expected_error_on_position && %{ and first error should appear on position #{@expected_error_on_position}} || '') + %{!}
    end

    def description
      %{parse "#{@expression}" starting with :#{@root}} + (@expected_error_on_position && %{ and with first error on position #{@expected_error_on_position.to_s}} || '')
    end

    def with position
      @expected_error_on_position = position
      self
    end
  end

  def self.included base
    base.extend const_get("ClassMethods") if const_defined?("ClassMethods")
    base.send :include, const_get("InstanceMethods") if const_defined?("InstanceMethods")
  end

  module ClassMethods
    def parser &block
      subject { RDParser::RDParser.new(&block) }
    end
  end

  module InstanceMethods
    def parse expression, root=:expression
      RDParser::ParseMatcher::Parse.new expression, root
    end

    def error_on_position position
      position
    end
    alias :first_error_on_position :error_on_position
  end
end
