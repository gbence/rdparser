class RDParser::RDParser
  # Class used to accept Ruby metafoo when specifying grammars with a block and virtual methods
  class GenericBlockToHashCreator; def method_missing(m, *args); @h ||= {}; @h[m] = args.first; @h; end; end

  # Creates a parser based on a certain grammar provided either as a hash or as
  # methods within a block (that then uses GrammarCreator)
  def initialize(grammar = '')
    @grammar = grammar == '' ? yield(GenericBlockToHashCreator.new) : grammar.dup
  end

  # Parse content using the parser object's grammar set
  def parse(rule, content, options = {})
    # @depth is used to make debugging output look nice and nested
    @depth = -1

    # Create a string scanner object based on the content
    @content = RDParser::Scanner.new(content, :slurp_whitespace => !options[:manual_whitespace])

    # Kick off the show by parsing from the rule specified
    result = parse_section(rule.to_sym).flatten

    # Raises ParserError when cannot get parse the entire content and :partial is not set.
    raise ParserError, %{Cannot parse the entire content! (error was on position ##{@content.position}: "#{content[0...@content.position]}|#{content[@content.position..@content.position]}|#{content[@content.position+1..-1]}")} unless options[:partial] == true or @content.eos?

    result
  end

  # Parse the content based on the rulesets for a particular grammar context
  def parse_section(rule)
    # Increase the depth of parsing - used for debug messages currently
    @depth += 1

    # For each distinct set of rules within a ruleset, get parsing..
    sub_rulesets(rule).each do |ruleset|
      RDParser::DEBUG && debug_message("RULE SET : #{ruleset}")

      # By default, we assume failure!
      success = false
      output = []

      # Keep a local copy of the current position to roll back to if things get hairy..
      was_position = @content.position            

      # Go through each rule in this ruleset
      sub_rules(ruleset).each do |r|
        RDParser::DEBUG && debug_message("Running rule '#{r}' against '#{@content.lookahead}'")
        suboutput = []

        # Match a rule with 1 or more occurrences (e.g. "rule(s)") 
        if r =~ /(\w+)(\(s\))$/
          r = $1

          # Force the first occurrence to succeed or break this sub-ruleset
          unless result = match_for_rule(r.to_sym)
            success = false
            break
          end

          suboutput.append_or_blend result

          # Now pick up any of the "or more" occurrences for free
          while result = match_for_rule(r.to_sym)
            suboutput.append_or_blend result
          end

          # Match a rule with 0 or more occurrences (e.g. "rule(s?)")
        elsif r =~ /(\w+)(\(s\?\))$/
          r = $1
          while result = match_for_rule(r.to_sym)
            suboutput.append_or_blend result
          end

          # Match a rule with 0 or 1 occurrences (e.g. "rules(?)")
        elsif r =~ /(\w+)(\(\?\))$/
          r = $1
          if result = match_for_rule(r.to_sym)
            suboutput.append_or_blend result
          end

          # Match a rule that has one single occurrence
        else
          unless result = match_for_rule(r.to_sym)
            success = false
            break
          end

          suboutput.append_or_blend result
        end

        success = true

        # Append the output from this rule to the output we'll use later..
        output += suboutput 
      end

      # We've either processed all the rules for this ruleset, or.. it failed      
      if success
        RDParser::DEBUG && debug_message("Success of all rules in #{ruleset}")

        # No need to check any more rulesets! We've just passed one,
        # so drop the depth a notch, we're headed back up the tree of recursion!
        @depth -= 1
        RDParser::DEBUG && debug_message("SUCCEED: #{ruleset}", :passback)
        return output
      else
        RDParser::DEBUG && debug_message("failed #{ruleset}.. moving on")

        # If the rule set failed, revert the position back to that we stored earlier
        @content.rollback_to(was_position)

        # And clean the output.. because any output we got from a broken rule is as useful
        # as an ashtray on a motorbike, a chocolate teapot, or ice cutlery.
        RDParser::DEBUG && debug_message("FAIL: #{ruleset}", :passback)
      end
    end

    # Well nothing passed, so this rule was totally bogus. Great. We've totally wasted our time.
    @depth -= 1
    return false
  end

  # Parse the content based on a single subrule
  def match_for_rule(rule)
    RDParser::DEBUG && debug_message("TRYING #{rule}")
    output = []
    rule_data = @grammar[rule]

    # If the rule is a string literal "likethis" then match it
    if rule.to_s =~ /^\"(.+)\"$/
      m = $1
      if @content.scan(m)
        RDParser::DEBUG && debug_message("GOT #{m}")
        output << {rule => m}
      else
        return false
      end

      # Is the rule a regular expression?
    elsif rule_data.class == Regexp
      # If we get a match.. do stuff!
      if c = @content.scan(rule_data)
        RDParser::DEBUG && debug_message("GOT IT --> #{c}")
        output << {rule => c}
      else
        # If we get no match, go and cry to mommy^H^H^H^H^Hhead up the recursion ladder
        return false
      end

      # Is the rule a string of other rules?
    elsif rule_data.class == String
      # A RULE THAT HAS RULES?? RECURSION IN THE HOUSE!
      response = parse_section(rule)

      # But did it really work out as planned?
      if response
        # Yes.. so celebrate and process the response.
        RDParser::DEBUG && debug_message("GOT #{rule}")
        return {rule => response}
      else
        # No.. so throw a hissyfit
        RDParser::DEBUG && debug_message("NOT GOT #{rule}")
        return false
      end
    end    
    output
  end

  # Splits a ruleset into its constituent rules or matches by whitespace
  def sub_rules(ruleset); ruleset.split(/\s+/); end

  # Extracts all rulesets from a single rule
  # e.g. 'rule1 rule2 | rule3 | rule4 rule 5' is three rule sets separated by bars
  def sub_rulesets(rule); @grammar[rule].split(/\s+\|\s+/); end

  # A 'pretty printer' for RDParser's syntax trees (pp just doesn't cut it for these beasties)
  # There's probably a nice iterative way of doing this but I'm tired.
  def RDParser.text_syntax_tree(v, depth = 0, output = '')
    if v.class == Array
      v.each { |a| output = text_syntax_tree(a, depth, output) }
    elsif v.class == Hash
      v.each do |a, b|
        output += ("  " * depth) + a.to_s
        b.class == String ? output += " => #{b}\n" : output = text_syntax_tree(b, depth + 1, output + "\n")
      end
    end
    output
  end  

  # Prints a debugging message if debug mode is enabled
  def debug_message(message, priority = true)
    # Let's different types of message through
    return if priority != RDParser::DEBUG
    puts "#{("  " * @depth.to_i) if @depth && @depth > -1 } #{message}"
  end
end
