require_relative 'helper'

module Ongaku
  module Config
    @sample_rate = 48000

    class << self
      attr_accessor :sample_rate
    end
  end
end