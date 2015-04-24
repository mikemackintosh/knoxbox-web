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

      def get(key)
        env = KnoxBoxWeb::Application.environment.to_sym
        return @config[env][key.to_sym] unless @config[env][key.to_sym].nil?
        return @config[:global][key.to_sym] unless @config[:global][key.to_sym].nil?
        nil
      end

      def set(key, value)
        @config.set(key, value)
      end

      def to_h
        @config
      end

    end
  end
end

# Define the configure constant
CONFIG = KnoxBoxWeb::Config