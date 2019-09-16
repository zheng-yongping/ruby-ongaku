module Ongaku
  class Error < StandardError; end
  class DSLSyntaxError < Error; end
  class ConvertError < Error; end
end