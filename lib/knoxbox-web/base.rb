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

  # Create the database connection
    unless Config.get(:database).nil?   
      ActiveRecord::Base.establish_connection(Config.get(:database))
    end
    require 'knoxbox-web/models/init'

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

    # Configure the EasyRSA stuff
      set :easyrsa,                 ::EasyRSA::Config.from_hash(Config.get(:'easyrsa.issuer'))

    # Define these, they are important for OpenVPN
      set :ca_cert,                 Pki.find_or_create_by(is: 'ca_cert').content
      set :ca_key,                  Pki.find_or_create_by(is: 'ca_key').content

    end

  # Define route conditions on environment
    set(:is_env) {|value| condition{value == settings.environment}}

  # Read the Application Configs
    unless Config.get(:global).nil?
      set :config, Config.get(:global)
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

      # Smart time helper which returns relative text representing times for recent dates
      # and absolutes for dates that are far removed from the current date
      # time_in_words(10.days.ago) => '10 days ago'
      # Credit goes to SinatraMore gem
      def time_in_words(date)
        date = date.to_date
        date = Date.parse(date, true) unless /Date.*/ =~ date.class.to_s
        days = (date - Date.today).to_i

        return 'today'     if days >= 0 and days < 1
        return 'tomorrow'  if days >= 1 and days < 2
        return 'yesterday' if days >= -1 and days < 0

        return "in #{days} days"      if days.abs < 60 and days > 0
        return "#{days.abs} days ago" if days.abs < 60 and days < 0

        return date.strftime('%A, %B %e') if days.abs < 182
        return date.strftime('%A, %B %e, %Y')
      end
      alias time_ago time_in_words

      # Returns relative time in words referencing the given date
      # relative_time_ago(Time.now) => 'about a minute ago'
      # Credit goes to SinatraMore gem
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

      # Returns escaped text to protect against malicious content
      def escape_html(text)
        Rack::Utils.escape_html(text)
      end
      alias h escape_html
      alias sanitize_html escape_html

      # Returns escaped text to protect against malicious content
      # Returns blank if the text is empty
      def h!(text, blank_text = '&nbsp;')
        return blank_text if text.nil? || text.empty?
        h text
      end

      # Percentage helper that returns the percentage that what is of.
      # lol
      def p(what, of)
        (what.to_f  / of.to_f )*100
      end
   
    end

    not_found do
      erb :'404'
    end

  end
end