require_relative 'config'
require_relative 'note'
require_relative 'exception'

require 'set'

module Ongaku
  module Synth
    class Base
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

        @phase = 0.0
        @tick = false
        @progress = 0.0

        @ctrl = {}
      end

      def conv(score)
        state = {}
        output = []

        score.each do |item|
          case item
          when Note
            note = complete_note(item, state)
            output += conv_note(note)

          when HzNote
            note = complete_hz_note(item)
            output += conv_note(item)

          when Hash
            set_attr(item)
          when Array
            reset_attr(item)
          else raise TypeError.new("a score item must be Note / HzNote / Hash(set attr) / Array(reset attr), but not #{item.class}")
          end
        end
        output
      end

      def sample
        raise NotImplementedError.new("sample method not implemented")
      end

      private
      def conv_note(note)
        sec_per_quarter_note = 60.0 / bmp
        sec_per_whole_note = sec_per_quarter_note * 4.0
        duration_sec = sec_per_whole_note * note.duration
        freq = note.freq
        num_samples = (duration_sec * Config.sample_rate).to_i
        phase_delta = freq / Config.sample_rate

        @tick = false
        last_phase = @phase = -1
        output = []

        num_samples.times do |i|
          @progress = i.to_f / num_samples
          last_phase = @phase
          @phase = (@phase + phase_delta) % 1.0
          @tick = last_phase > @phase

          case value = sample()
          when Array then output += value
          else output << value
          end
        end

        output
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
end