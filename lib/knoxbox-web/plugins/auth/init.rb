require 'signet/oauth_2/client'
require 'google/api_client'
require 'httparty'
controller do 

  def api_client; settings.api_client; end
  def gplus; settings.gplus; end

  def user_credentials
    # Build a per-request oauth credential based on token stored in session
    # which allows us to use a shared API client.
    @authorization ||= (
      auth = self.api_client.authorization.dup
      auth.redirect_uri = to('/auth')
      auth.update_token!(session)
      auth
    )
  end
  
  configure do
  # Set Things for Google-ness
  #  -> https://console.developers.google.com
    begin
      client_secrets = Google::APIClient::ClientSecrets.load(File.join(root, '..', 'config/client_secrets.json'))
    rescue MultiJson::ParseError => e
      raise "This does not appear to be a valid 'client_secrets.json' file."      
    rescue RuntimeError
      raise "Please be sure to load your 'client_secrets.json', as provided by Google."
    end

    # Init new Client
    client = Google::APIClient.new(
      :application_name => 'KnoxBox',
      :application_version => KnoxBoxWeb::VERSION,
      :authorization => Signet::OAuth2::Client.new(
        :client_id => client_secrets.client_id,
        :client_secret => client_secrets.client_secret,
        :scope => 'openid email profile',                 # These are all needed to verify identity
        :redirect_uri => client_secrets.redirect_uris[1], # Redirect URL from client_secrets.json
        #:hd => 'yoursite.com',
        :authorization_uri =>
          'https://accounts.google.com/o/oauth2/auth',
        :token_credential_uri =>
          'https://accounts.google.com/o/oauth2/token'
      )
    )

    # Splice them into KnoxBoxWeb::Application.settings
    set :gplus, client.discovered_api('plus', 'v1')
    set :api_client, client
  end

  before do
  # Ensure user has authorized the app
    unless request.path_info =~ /^\/(auth|login)/
    # Grab the access_token if you're not in the above routes
      unless user_credentials.access_token
        redirect to('/login')
      end
    # And the session details are important too
      if session.nil? or session[:user].nil?
        redirect to('/login')
      end
    # Make sure the username is in the session also
      if session[:user]['username'].nil?
        redirect to('/login')
      end
    end

  end

  after do
  # Serialize the access/refresh token to the session
    session[:access_token] = user_credentials.access_token
    session[:refresh_token] = user_credentials.refresh_token
    session[:expires_in] = user_credentials.expires_in
    session[:issued_at] = user_credentials.issued_at
  end

  # Make the user click login
  get '/login' do
    erb :login
  end

  # Log the user out
  get '/logout' do
      
  # Revoke the token
    HTTParty.get("https://accounts.google.com/o/oauth2/revoke?token=#{session[:access_token]}")
  
  # Unset the session stuff
    session[:user] = nil
    session[:access_token] = nil
    session[:refresh_token] = nil
    session[:expires_in] = nil
    session[:issued_at] = nil
    user_credentials = nil
    session.clear

    redirect '/'
  end

  get '/authorize' do
    redirect user_credentials.authorization_uri.to_s, 303
  end

  get '/auth' do
    begin
      # Exchange token
      user_credentials.code = params[:code] if params[:code]
      user_credentials.fetch_access_token!

      # Set Session Details
      session[:access_token] = user_credentials.access_token
      session[:refresh_token] = user_credentials.refresh_token
      session[:expires_in] = user_credentials.expires_in
      session[:issued_at] = user_credentials.issued_at

      # HTTParty
      result = HTTParty.get("https://www.googleapis.com/plus/v1/people/me/openIdConnect?hd=#{HOSTED_DOMAIN}&access_token=#{user_credentials.access_token}")

      # Check for a 200
      unless result.code.eql? 200
        halt 401, erb(:error)
      end
      
      user_info = result.parsed_response
      if user_info['hd'].eql? HOSTED_DOMAIN
        user_info['username'] = user_info['email'].gsub(HOSTED_DOMAIN, '')
        session[:user] = user_info
        redirect to('/')
      else
        halt 403, erb(:unauthorized)
      end

      redirect to('/')
    rescue Signet::AuthorizationError => e
      puts e.inspect
      halt 500, erb(:error)
    end
  end  

end