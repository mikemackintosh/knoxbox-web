require "#{File.expand_path(File.dirname(__FILE__))}/lib/knoxbox-web"
use ExceptionHandling
run KnoxBoxWeb::Application