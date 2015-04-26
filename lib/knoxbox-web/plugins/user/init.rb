controller do
  before '/user*' do
    redirect '/' unless is_authenticated?
  end

  namespace '/user' do
  # Generic Admin
    get '/download' do
      log('Configuration downloaded via self-service portal', 'download')
      attachment "KnoxBox - #{session[:user]['username']}.ovpn"

      @user = User.where(username: session[:user]['username']).first
      @ca_cert = File.read settings.ca_cert

      @user.cert = OpenSSL::X509::Certificate.new @user.cert

      erb :client, :layout => false
    end

  # Show Users
    get '/manage' do
      @users = User.all
      erb :"users/list"
    end

  # Show Users
    get '/audit' do
      @audit_logs = Log.where(cn: session[:user]['username']).order('created_at DESC')
      erb :"user/audit"
    end

  end
end