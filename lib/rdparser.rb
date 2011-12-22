require 'strscan'
require File.expand_path('../patches/array.rb', __FILE__)

# A Simple Recursive Descending (LL) Parser for Ruby
module RDParser

  # raised when Parser cannot get through the entire string.
  class ParserError < StandardError; end

  autoload :RDParser, File.expand_path('../rdparser/rdparser.rb', __FILE__)
  autoload :Scanner,  File.expand_path('../rdparser/scanner.rb', __FILE__)

  # change to true to get flooded with debug messages during parsing
  DEBUG = false
end
