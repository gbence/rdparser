# Provide Array with method that appends hashes, but concatenates arrays
module RDParser
  module ArrayExtensions
    def append_or_blend(i)
      i.class == Hash ? self << i : self.concat(i)
    end
  end
end

Array.send :include, RDParser::ArrayExtensions
