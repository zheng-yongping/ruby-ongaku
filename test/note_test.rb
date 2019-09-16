require "test_helper"

class NoteTest < Minitest::Test
  include Ongaku
  include Ongaku::Temperament
  include Ongaku::Temperament::ET12

  def test_note_unary_plus_and_unary_minus
    assert_equal Note.new(ET12, 5, 1), +a
    assert_equal Note.new(ET12, 5, 1, 2), +a2
    assert_equal Note.new(ET12, 5, -1, 2), -a2
    assert_equal Note.new(ET12, 5, -2, 2), --a2
    assert_equal Note.new(ET12, 5, 0, 2), +-a2
  end

  def test_note_set_group
    assert_equal Note.new(ET12, 5, 0, 1), a.(1)
    assert_raises(DSLSyntaxError){a2.(1)}
    assert_raises(DSLSyntaxError){a[4].(1)}
  end

  def test_note_set_duration
    assert_equal Note.new(ET12, 5, 0, nil, 1/4r), a[4]
    assert_raises(DSLSyntaxError){a[4][4]}
  end

  def test_note_to_s
    assert_equal 'a', a.to_s
    assert_equal '++a1[4]', (++a1[4]).to_s
    assert_equal '++a.(10)[4]', (++a.(10)[4]).to_s
    assert_equal '++a.(10)[2/3r]', (++a.(10)[2/3r]).to_s
    assert_equal '~++a.(10)[2/3r]', (~++a.(10)[2/3r]).to_s
    assert_equal '~++a.(10)[2/3r]>>4', (~++a.(10)[2/3r]>>4).to_s
    assert_equal '~++a.(10)[2/3r]>>2/3r', (~++a.(10)[2/3r]>>2/3r).to_s
  end

  def test_tie
    assert_equal Note.new(ET12, 5, 0, nil, nil, true), ~a
    assert_equal Note.new(ET12, 5, 0, nil, 1/4r, true), ~a[4]
    assert_equal Note.new(ET12, 5, 1, nil, 1/4r, true), ~+a[4]
    assert_equal Note.new(ET12, 5, 1, 1, 1/4r, true), ~+a1[4]
    assert_raises(DSLSyntaxError){~~a}
    assert_raises(DSLSyntaxError){+~a}
  end

  def test_tenuto
    assert_equal Note.new(ET12, 5, 0, nil, nil, false, 1/4r), a>>4
    assert_equal Note.new(ET12, 5, 0, nil, nil, false, 2/3r), a>>2/3r
    assert_raises(DSLSyntaxError){a>>4>>3}
  end
end

class HzNoteTest < Minitest::Test
  include Ongaku
  using Ongaku::Ext

  def test_note_create
    assert_equal HzNote.new(1), 1.Hz
  end

  def test_note_set_duration
    assert_equal HzNote.new(1, 1/4r), 1.Hz[4]
    assert_raises(DSLSyntaxError){1.Hz[4][4]}
  end

  def test_note_to_s
    assert_equal '1.0.Hz', 1.Hz.to_s
    assert_equal '1.0.Hz[4]', 1.Hz[4].to_s
    assert_equal '1.0.Hz[2/3r]', 1.Hz[2/3r].to_s
    assert_equal '~1.0.Hz[2/3r]', (~1.Hz[2/3r]).to_s
    assert_equal '~1.0.Hz[2/3r]>>4', (~1.Hz[2/3r]>>4).to_s
    assert_equal '~1.0.Hz[2/3r]>>2/3r', (~1.Hz[2/3r]>>2/3r).to_s
  end

  def test_tie
    assert_equal HzNote.new(1, nil, true), ~1.Hz
    assert_raises(DSLSyntaxError){~~1.Hz}
  end

  def test_tenuto
    assert_equal HzNote.new(1, nil, false, 1/4r), 1.Hz>>4
    assert_equal HzNote.new(1, nil, false, 2/3r), 1.Hz>>2/3r
    assert_raises(DSLSyntaxError){1.Hz>>4>>4}
  end
end

class ChordTest < Minitest::Test
  include Ongaku
  using Ongaku::Ext
  include Ongaku::Temperament::ET12

  def test_chord_create
    assert_equal Chord.new(a, a), a&a
    assert_equal Chord.new(1.Hz, a), 1.Hz&a
    assert_equal Chord.new(1.Hz, 2.Hz), 1.Hz&2.Hz
    assert_equal Chord.new(c, e, g), c&e&g
  end
end