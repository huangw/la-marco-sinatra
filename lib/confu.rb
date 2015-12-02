class ConfuMissing < NoMethodError; end
# Base class for configuration management
class Confu
  # Proxy object to handle arbitrage attribute read and write
  class Data < Hash
    def initialize(hsh = {})
      hsh.each do |k, v|
        self[k.to_sym] = v.is_a?(Hash) ? self.class.new(v) : v
      end
    end

    # Arbitrage attributes creation, refuse to set new attributes if
    # `finalized?` is true, and create a nested `Data` instance on the fly
    # if `finalized?` is false
    # rubocop:disable CyclomaticComplexity
    def method_missing(met, val = nil, &prc)
      met = met.to_s.sub(/=\Z/, '').to_sym
      return finalized_accessor(met) if finalized?
      fail 'can not set value with configuration block' if val && prc
      return handle_block(met, prc) if prc

      return self[met] = self.class.new(val) if val && val.is_a?(Hash)
      return self[met] if key?(met)

      self[met] = val ? val : self.class.new
    end

    # Recursively load dat (an other Data instance) as default value
    def merge_default(dat)
      dat.each do |k, v|
        if key?(k.to_sym)
          self[k.to_sym].merge_default(v) if self[k.to_sym].is_a?(Confu::Data)
          # self defined the key, and not a Data, ignore v
        else
          self[k.to_sym] = v
        end
      end
    end

    # Recursively transform Data to hash
    def to_hash
      nhsh = {}
      map do |k, v|
        nhsh[k.to_sym] = v.is_a?(Confu::Data) ? v.to_hash : v
      end
      nhsh
    end

    def finalize!
      @finalized = true
      to_h.map { |_, v| v.finalize! if v.is_a?(Confu::Data) }
    end

    def finalized?
      @finalized ? true : false
    end

    private

    def finalized_accessor(met)
      fail ConfuMissing, "#{met} not set" unless self[met]
      if self[met] && self[met].is_a?(self.class)
        return nil if self[met].keys.size == 0 # nothing inside
      end
      self[met]
    end

    def handle_block(met, prc)
      self[met] = self.class.new unless self.key?(met)
      fail "`#{met} (#{self[met].class})` can not "\
           'handle configuration block' unless self[met].is_a?(self.class)
      self[met].instance_eval(&prc)
    end
  end # end of class Data

  class << self # directly let into the Eigenclass
    # Return the receiver
    def for_environment(environment, &prc)
      fail 'Confu is finalized, can not configure anymore.' if finalized?
      @data ||= { default: Confu::Data.new }
      @data[environment.to_sym] ||= Confu::Data.new
      @data[environment.to_sym].instance_eval(&prc) if prc
      @data[environment.to_sym]
    end
    alias_method :'[]', :for_environment

    # Recursively convert `Data` instance into hash format,
    # ensure symbolic keys
    def to_hash
      fail 'Can not convert to hash unless finalized' unless finalized?
      @data[@finalized].to_hash
    end

    # Make the default environment
    def finalize!(ev = ENV['RACK_ENV'])
      return warn 'No configuration data to be finalized' unless @data
      return warn 'Can not finalize without an environment' unless ev
      @data[ev.to_sym] ||= Confu::Data.new unless @data[ev.to_sym]

      @data[ev.to_sym]
        .merge_default(@data[:default]) unless ev.to_sym == :default
      @data[ev.to_sym].each do |met, dat|
        define_singleton_method(met.to_sym) { dat }
      end

      @finalized = ev.to_sym
      @data.map { |_, v| v.finalize! }
    end

    def finalized?
      @finalized ? true : false
    end
  end
end
