require "test_helper"

class SynthTest < Minitest::Test
  include Ongaku::Temperament::ET12

  class TestSynth < Ongaku::Synth::Base
    def initialize
      super
      @reg = 0.0
    end

    def sample
      @reg = (@reg == 0.0 ? 440.0 : 0.0)
    end
  end

  def test_ctrl_accessor
    synth = TestSynth.new
    synth.amp = 1
    synth.ctrl[:amp] = ->{@amp + 1}
    assert_equal(2, synth.amp)
    assert_equal(Set[:amp], synth.ctrls)
  end

  def test_conv_note
    synth = TestSynth.new
    synth.bmp = 3600
    synth.amp = 1
    data = synth.conv [a4[16]]
    assert_equal(200, data.length)
    assert_equal([440.0, 0.0] * 100, data)
  end
end