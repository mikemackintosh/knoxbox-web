require 'set'
require 'yaml'

# Define the config module
module KnoxBoxWeb
  module Config
    class << self
      def load(file)
        if File.exists?(file)
          puts Yaml.load(file).inspect
        end
      end
    end
  end
end

# Define the configure constant
CONFIG = KnoxBoxWeb::Config