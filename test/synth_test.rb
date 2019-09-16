require "test_helper"

class SynthTest < Minitest::Test
  def test_ctrl_accessor
    synth = Ongaku::Synth.new
    synth.amp = 1
    synth.ctrl[:amp] = ->{@amp + 1}
    assert_equal(2, synth.amp)
    assert_equal(Set[:amp], synth.ctrls)
  end
end