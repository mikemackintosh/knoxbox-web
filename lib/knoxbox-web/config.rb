# Require deps


# Define the config module
module KnoxBoxWeb
  module Config
    
    require 'set'
    require 'yaml'

    class << self

      attr_writer :config

      def load(file)
        if File.exists?(file)
          @config = YAML.load(File.read(file))
        end

        @config.symbolize_keys_deep!
      end

      def get(key, default=nil)
        rv = nil

        [*key].each do |k|
          rv = @config.get(k.to_s)
          break unless rv.nil?

          rv = @config.get(KnoxBoxWeb::Application.environment.to_s << '.' << k.to_s)
          break unless rv.nil?
        end

        return default if rv.nil?
        return rv
      end

      def get!(key)
        rv = @config.get(key)
        return rv
      end

      def to_h
        @config
      end

    end
  end
end

# Define the configure constant
CONFIG = KnoxBoxWeb::Config