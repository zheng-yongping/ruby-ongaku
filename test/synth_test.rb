require "test_helper"

class SynthTest < Minitest::Test
  def test_synth_reader
    synth = Ongaku::Synth.new
    synth.amp = 1
    synth.ctrls[:amp] = ->{@amp + 1}
    assert_equal(2, synth.amp)
  end
end