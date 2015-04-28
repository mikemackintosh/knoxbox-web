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

  # Show user management page
    get '/manage' do
      @logins_by_date = {}
      @user = User.where(username: session[:user]['username']).first
      @logins = Log.where(cn: session[:user]['username']).group(:category).count

      Log.
        where(cn: session[:user]['username'], category: ['login', 'login-vpn']).
        where('created_at > (SELECT DATETIME("now", "-7 day"))').
        group('strftime("%m/%d", created_at)').
        group(:category).
        count.
          each do |e|
            if @logins_by_date[e.first[0]].nil?
              @logins_by_date[e.first[0]] =  { 'date' => e.first[0], 'login' => 0, 'login-vpn' => 0 }
            end
            @logins_by_date[e.first[0]][e.first[1]] = e[1]
          end

      @total_logins = (@logins['login'] ||= 0) + (@logins['login-vpn'] ||= 0)
      erb :"user/manage"
    end  

  # Update user management page
    post '/manage' do
      puts params.inspect
      erb :"user/manage"
    end

  # Show Audit Log for user events
    get '/audit' do
      @audit_logs = Log.where(cn: session[:user]['username']).order('created_at DESC')
      erb :"user/audit"
    end

  end
end
