require_relative 'note'

module Ongaku
  module Temperament
    module ET12
      def self.names
        (:a..:g).to_a.rotate(2)
      end

      names.each_with_index do |name, level|
        define_method name do
          Note.new(ET12, level)
        end

        10.times do |group|
          define_method "#{name}#{group}" do
            Note.new(ET12, level, 0, group)
          end
        end
      end

      def self.level_to_name(level)
        names.to_a.fetch(level)
      end

      def self.note_freq(note)
        half_step_map = [-9, -7, -5, -4, -2, 0, 2]
        440.0 * 2 ** ((half_step_map[note.level] + note.shift) / 12.0 + note.group - 4)
      end
    end
  end
end