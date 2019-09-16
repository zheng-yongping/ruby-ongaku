module Ongaku
  class NoteBase
    attr_reader :duration, :tie

    def initialize(duration, tie, tenuto)
      @duration = duration
      @tie = tie
      @tenuto = tenuto
    end

    def [](argv)
      raise DSLSyntaxError.new('duration is no nil') if @duration

      dup_but(duration: argv_to_duration(argv))
    end

    def ~
      raise DSLSyntaxError.new('tie is true') if @tie
      dup_but(tie: true)
    end

    def >>(argv)
      raise DSLSyntaxError.new('tenuto is not nil') if @tenuto
      dup_but(tenuto: argv_to_duration(argv))
    end

    def &(other)
      Chord.new self, other
    end
    
    def ==(other)
      instance_variables.all? do |name|
        instance_variable_get(name) == other.instance_variable_get(name)
      end
    end

    def inspect
      to_s
    end

    def dup_but(**kwargs)
      args = self.method(:initialize).parameters.map do |_, name|
        if kwargs.include?(name)
          kwargs[name]
        else
          self.instance_variable_get("@#{name}")
        end
      end
      self.class.new(*args)
    end

    private def argv_to_duration(argv)
      case argv
      when Integer  then Rational(1, argv)
      when Rational then argv
      else raise TypeError.new('duration must be an Integer / Rational')
      end
    end
  end

  class Note < NoteBase
    attr_reader :temperament, :level, :shift, :group

    def initialize(temperament, level, shift = 0, group = nil, duration = nil, tie = false, tenuto = nil)
      super(duration, tie, tenuto)
      @temperament = temperament
      @level = level
      @shift = shift
      @group = group
    end

    def freq
      @temperament.note_freq(self)
    end

    def +@
      raise DSLSyntaxError.new('use + after use ~') if @tie
      dup_but(shift: @shift + 1)
    end

    def -@
      raise DSLSyntaxError.new('use - after use ~') if @tie
      dup_but(shift: @shift - 1)
    end

    def call(group)
      raise DSLSyntaxError.new('group is not nil') if @group
      raise DSLSyntaxError.new('use .() after []') if @duration
      dup_but(group: group)
    end

    def to_s
      name = @temperament.level_to_name(@level)
      shift = (@shift > 0 ? '+' : '-') * @shift.abs
      tie = @tie ? '~' : ''

      group = if @group
        0 <= @group && @group <= 9 ? @group : ".(#{@group})"
        else ''
      end

      duration = if @duration
        @duration.numerator == 1 ? "[#{@duration.denominator}]" : "[#{@duration}r]"
        else ''
      end

      tenuto = if @tenuto
        @tenuto.numerator == 1 ? ">>#{@tenuto.denominator}" : ">>#{@tenuto}r"
        else ''
      end

      return "#{tie}#{shift}#{name}#{group}#{duration}#{tenuto}"
    end
  end

  class HzNote < NoteBase
    def initialize(freq, duration = nil, tie = false, tenuto = nil)
      super(duration, tie, tenuto)
      @freq = freq.to_f
    end

    def to_s
      tie = @tie ? '~' : ''

      duration = if @duration
        @duration.numerator == 1 ? "[#{@duration.denominator}]" : "[#{@duration}r]"
        else ''
      end
      
      tenuto = if @tenuto
        @tenuto.numerator == 1 ? ">>#{@tenuto.denominator}" : ">>#{@tenuto}r"
        else ''
      end
      
      return "#{tie}#{@freq}.Hz#{duration}#{tenuto}"
    end
  end

  class Chord
    attr_reader :notes

    def initialize(*notes)
      @notes = notes
    end

    def &(other)
      Chord.new(*@notes.push(other))
    end

    def ==(other)
      @notes == other.notes
    end

    def to_s
      @notes.map{|note| note.to_s}.join(' & ')
    end

    alias_method :inspect, :to_s 
  end
end 