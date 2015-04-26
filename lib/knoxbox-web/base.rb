# Define the controller alias
def controller(&block)
  KnoxBoxWeb::Application.class_eval(&block)
end

# Log alias for audit stuff
def log(message, type='general', instance=nil)
  Log.new do |l|
    l.category = type
    l.message = message
    l.instance_id = instance
    l.cn = session[:user]['username']
    l.remote_host = @env['REMOTE_ADDR']
    l.save!
  end
end

# Returns relative time in words referencing the given date
# relative_time_ago(Time.now) => 'about a minute ago'
def relative_time_ago(from_time)
  distance_in_minutes = (((Time.now - from_time.to_time).abs)/60).round
  case distance_in_minutes
    when 0..1 then 'about a minute'
    when 2..44 then "#{distance_in_minutes} minutes"
    when 45..89 then 'about 1 hour'
    when 90..1439 then "about #{(distance_in_minutes.to_f / 60.0).round} hours"
    when 1440..2439 then '1 day'
    when 2440..2879 then 'about 2 days'
    when 2880..43199 then "#{(distance_in_minutes / 1440).round} days"
    when 43200..86399 then 'about 1 month'
    when 86400..525599 then "#{(distance_in_minutes / 43200).round} months"
    when 525600..1051199 then 'about 1 year'
    else "over #{(distance_in_minutes / 525600).round} years"
  end
end

# Define the module
module KnoxBoxWeb
  class Application < Sinatra::Base
  # Register different submodules
    register Sinatra::ConfigFile
    register Sinatra::Flash
    register Sinatra::Namespace
    register Sinatra::ActiveRecordExtension

    use Rack::Deflater
    use Rack::Session::Cookie, :key => 'knoxbox.session',
                           :path => '/',
                           :expire_after => 3600,
                           :secret => 't6xws7f8BSSWcP7INqCrcAs==' #SecureRandom.base64

  # Default configuration 
    configure do
      disable   :debug
      disable   :raise_errors
      disable   :show_exceptions
    # disable   :dump_errors
      enable    :method_override
      enable    :cross_origin
      enable    :logging
      mime_type :json,              'application/json'
      mime_type :ovpn,              'text/plain'
      set       :erb,               :escape_html => true
      set       :allow_credentials, true
      set       :allow_methods,     [:get, :post, :options]
      set       :allow_origin,      :any
      set       :protection,        :except => :json_csrf
      set       :root,              PROJECT_ROOT
      set       :environments,      %w{development test production}
      set       :views,             [""]
      set       :public_folder,     Proc.new { File.join(root, "knoxbox-web/assets") }
      set       :static,            true

    # Define these, they are important for OpenVPN
      set :ca_cert, Config.get(:'openvpn.ca_cert')
      set :ca_key, Config.get(:'openvpn.ca_key')
    end

  # Define route conditions on environment
    set(:is_env) {|value| condition{value == settings.environment}}

  # Read the Application Configs
    unless Config.get(:global).nil?
      set :config, Config.get(:global)
    end
  
  # Create the database connection
    unless Config.get(:database).nil?   
      ActiveRecord::Base.establish_connection(Config.get(:database))
    end

  # Discover plugins
    plugins = [
      "#{PROJECT_ROOT}/knoxbox-web/plugins/*/lib/*.rb",
      "#{PROJECT_ROOT}/knoxbox-web/plugins/*/models/**/*.rb",
      "#{PROJECT_ROOT}/knoxbox-web/plugins/*/tasks/**/*.rb",
      "#{PROJECT_ROOT}/knoxbox-web/plugins/*/init.rb",
    ].collect{|pattern|
      Dir[pattern]
    }.flatten.uniq()

  # Load the actual plugins and their views
    plugins.each do |lib|
      settings.views.push(File.join(File.dirname(lib), 'views'))
      plugin_name = lib.match(/#{PROJECT_ROOT+'/knoxbox-web/plugins/([^\/]+)'}/)[1]
      require lib
    end

  # Override the views for said plugins
    helpers do
      def find_template(views, name, engine, &block)
        Array(views).each { |v| super(v, name, engine, &block) }
      end
    end

    not_found do
      erb :'404'
    end

  end
end