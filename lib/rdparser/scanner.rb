# Attached class below for simplicity of transfer at the moment.. but this should really be
# separated.

# Scanner is basically a proxy class for StringScanner that adds some convenience features.
# Could probably be a subclass actually, but this was a quick, scrappy job so I could get
# onto the fun stuff in RDParser!
class RDParser::Scanner
  def initialize(string, options = {})
    @options = options
    @scanner = StringScanner.new(string.dup)
    @rollback_pointers = []
  end

  def position
    @scanner.pos
  end

  def eos?
    @scanner.eos?
  end

  def rollback_position
    @rollback_pointers.last
  end

  def lookahead
    @scanner.peek(10)
  end

  def scan(regexp)
    space = @options[:slurp_whitespace] && @options[:slurp_whitespace] == true ? /\s*/ : //
      if regexp.class == String
        regexp = Regexp.new(regexp.gsub(/\(|\)|\+|\|/) { |a| '\\' + a })
      end
    if match = @scanner.scan(/(#{space}(#{regexp}))/)
      @rollback_pointers << (@scanner.pos - match.length)
      @options[:slurp_whitespace] && @options[:slurp_whitespace] == true ? match.sub(/^\s*/, '') : match
    else
      nil
    end
  end

  def rollback
    begin
      (@scanner.pos = @rollback_pointers.pop) && true
    rescue
      nil
    end
  end

  def rollback_to(posi)
    @scanner.pos = posi
    @rollback_pointers.delete_if { |p| p >= posi }
  end
end

