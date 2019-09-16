module Ongaku
  # Synth base class
  # The default implementation is sin
  class Synth
    def self.synth_accessor(*names)
      names.each do |name|
        define_method name do
          @ctrls[name] ? instance_exec(&@ctrls[name]) : instance_variable_get("@#{name}")
        end

        define_method "#{name}=" do |value|
          instance_variable_set("@#{name}", value)
        end
      end
    end

    synth_accessor :amp
    attr_reader :ctrls

    def initialize
      @amp = 0
      @ctrls = {}
    end

    def conv(score)
    end

    # 可以重写的方法。调用 conv 时，每次采样会调用这个方法
    #
    # phase - 范围是 [0, 1] 的浮点数
    # tick  - 首次采样以及每次 phase 超过 1 重新计数时为 true
    #
    # 返回采样的值
    def sample(phase, tick)
      Math.sin(2 * Math::PI * phase)
    end
  end
end