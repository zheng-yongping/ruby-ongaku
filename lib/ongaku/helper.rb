module Ongaku
  module DefineClassMethod
    def define_class_method(name, &block)
      extend(Module.new{define_method name, &block})
    end
  end
end