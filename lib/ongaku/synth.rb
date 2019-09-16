require_relative 'note'
require_relative 'exception'

require 'set'

module Ongaku

  # Synth base class
  # The default implementation is sin
  class Synth
    @@ctrls = Set[].freeze
  
    def self.ctrl_accessor(*names)
      names.each do |name|
        define_method name do
          @ctrl[name] ? instance_exec(&@ctrl[name]) : instance_variable_get("@#{name}")
        end

        define_method "#{name}=" do |value|
          instance_variable_set("@#{name}", value)
        end
      end
      @@ctrls = @@ctrls + names
      @@ctrls.freeze
    end

    def self.ctrls
      @@ctrls
    end

    def ctrls
      @@ctrls
    end
  
    attr_reader   :ctrl
    attr_accessor :bmp
    ctrl_accessor :amp

    def initialize
      @amp = 0
      @bmp = 0

      @ctrl = {}
    end

    def conv(score)
      state = {}

      score.each do |item|
        sample = case item
                 when Note
                  note = complete_note(item, state)
                  conv_note(note)

                 when HzNote
                  note = complete_hz_note(item)
                  conv_note(item)

                 when Hash
                  set_attr(item)
                 when Array
                  reset_attr(item)
                 else raise TypeError.new("a score item must be Note / HzNote / Hash(set attr) / Array(reset attr), but not #{item.class}")
                 end

        output += sample unless sample.nil?
      end
    end

    # 可以重写的方法。调用 conv 时，每次采样会调用这个方法
    #
    # phase - 范围是 [0, 1] 的浮点数
    # tick  - 首次采样以及每次 phase 超过 1 重新计数时为 true
    #
    # 返回采样的值
    def sample(phase, tick)
      raise NotImplementedError.new("sample(phase, tick) method not implemented")
    end

    private
    def conv_note(note)
    end

    def set_attr(hash)
    end

    def reset_attr(array)
    end

    def complete_note(note, state)
      args = {}
      args[:group] = check_state(state, :group) if note.group.nil?
      args[:duration] = check_state(state, :duration) if note.duration.nil?
      note = note.dup_but(**args) if args.length > 0
      state[:group] = note.group
      state[:duration] = note.duration
      note
    end

    def complete_hz_note(hz_note, state)
      cur_duration = check_state(state, :duration)
      hz_note.dup_but(duration: cur_duration) if hz_note.duration.nil?
      cur_duration = item.duration
      hz_note
    end

    def check_state(state, name)
      if state[name].nil?
        raise ConvertError.new("current #{name} state is nil. please provide group and duratioin for the first note") 
      else
        state[name]
      end
    end
  end
end