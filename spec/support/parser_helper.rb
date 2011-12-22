module ParserHelper
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
      class << (o=Object.new)
        def description
          %{should parse "#{@_expression}" starting with :#{@_root}}
        end
        def failure_message
          %{Grammar should parse "#{@_expression}"!}
        end
        def negative_failure_message
          %{Grammar should not parse "#{@_expression}"!}
        end
        def matches? parser
          parser.parse(@_root, @_expression).kind_of?(Array)
          return true
        rescue RDParser::ParserError
          return false
        end
      end
      o.instance_variable_set('@_expression', expression)
      o.instance_variable_set('@_root', root)
      o
    end
  end
end
