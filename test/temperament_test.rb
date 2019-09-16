require "test_helper"

class TemperamentET12Test < Minitest::Test
  include Ongaku
  include Temperament
  include Temperament::ET12
  def test_note_create
    assert_equal [
        Note.new(ET12, 0),
        Note.new(ET12, 1),
        Note.new(ET12, 2),
        Note.new(ET12, 3),
        Note.new(ET12, 4),
        Note.new(ET12, 5),
        Note.new(ET12, 6),
      ], [c, d, e, f, g, a, b]

    10.times do |group|
      assert_equal (0..6).map{|level| Note.new(ET12, level, 0, group)},
        ('a'..'g').to_a.rotate(2).map{|name| eval("#{name}#{group}")}
    end
  end
  
  def test_note_freq
    assert_equal 440.0, a4.freq
    assert_equal 27.5, a0.freq
    assert_equal 16.351597831287414, c0.freq
    assert_equal 16.351597831287414 / 2 ** 10, c.(-10).freq
    assert_equal 16.351597831287414 * 2 ** 10, c.(10).freq
  end
end