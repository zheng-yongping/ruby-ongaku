require_relative 'helper'

module Ongaku
  module Config
    extend DefineClassMethod

    def self.def_config(name, value)
      class_variable_name = "@@#{name}"
      class_variable_set(class_variable_name, value)
      define_class_method(name){class_variable_get(class_variable_name)}
      define_class_method("#{name}="){|value| class_variable_set(class_variable_name, value)}
    end

    def_config :sample_rate, 48000
  end
end