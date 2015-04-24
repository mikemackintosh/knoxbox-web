# Define the controller alias
def controller(&block)
  KnoxBoxWeb::Application.class_eval(&block)
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
                           :secret => 't6xws7f8BSSWcP7INqCrcA==' #SecureRandom.base64

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
      set :ca_cert, '/opt/knoxbox/keys/ca.crt'    
      set :ca_key, '/opt/knoxbox/keys/ca.key'
    end

  # Helper for checking if user is authenticated
    def is_authenticated?
      return !!session[:user]
    end

  # Define route conditions on environment
    set(:is_env) {|value| condition{value == settings.environment}}
  # Condition based
    set(:auth) do |*roles|
      condition do
        unless roles.any? { |role| (role == :user) ? is_user? : is_authorized?(role) }
          handle_unauthorized_access(roles)
        end
      end
    end

  # Read the Application Configs
    if File.exist?(ENV['KNOXBOXWEB_CONFIG'].to_s)
      set :config, YAML::load(File.read(ENV['KNOXBOXWEB_CONFIG']))[KnoxBoxWeb::Application.environment.to_s]
    end
    
  # Make sure the config exists
    if File.exist?(ENV['KNOXBOXWEB_DATABASE_CONFIG'].to_s)
      db_config = YAML::load(File.read(ENV['KNOXBOXWEB_DATABASE_CONFIG']))[KnoxBoxWeb::Application.environment.to_s]
    # Create the database connection
      ActiveRecord::Base.establish_connection(db_config)
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

  end
end