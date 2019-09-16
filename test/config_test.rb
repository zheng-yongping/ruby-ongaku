require "test_helper"

class ConfigTest < Minitest::Test
  def test_config
    _test_config(:sample_rate, 48000)
    Ongaku::Config.sample_rate = 100
    _test_config(:sample_rate, 100)
  end

  def _test_config(name, expected)
    assert_equal(expected, Ongaku::Config.method(name).call)
  end
end