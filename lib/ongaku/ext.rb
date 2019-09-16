module Ongaku
  module HzExt
    refine Numeric do
      def Hz
        HzNote.new(self)
      end
    end
  end

  module Ext
    include HzExt
  end
end