# raised when Parser cannot get through the entire string.
class RDParser::ParseError < StandardError
  attr_reader :content, :position
  def initialize content, position
    super(%{Cannot parse the entire content! (error was on position ##{position}: "#{content[0...position]}|#{content[position..position]}|#{content[position+1..-1]}")})
    @content  = content
    @position = position
  end
end
