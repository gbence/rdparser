# Provide Array with method that appends hashes, but concatenates arrays
module RDParser::ArrayExtensions
  def append_or_blend(i)
    i.class == Hash ? self << i : self.concat(i)
  end
end

Array.send :include, RDParser::ArrayExtensions
