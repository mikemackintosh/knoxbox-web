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
    get '/dashboard' do
      @logins_by_date = {}
      @user = User.where(username: session[:user]['username']).first
      @logins = Log.where(cn: session[:user]['username']).group(:category).count

      Log.where(cn: session[:user]['username'], category: ['login', 'login-vpn']).where('created_at > (SELECT DATETIME("now", "-7 day"))').
        group('strftime("%m/%d", created_at)').group(:category).count.each do |e|
          if @logins_by_date[e.first[0]].nil?
            @logins_by_date[e.first[0]] =  { 'date' => e.first[0], 'login' => 0, 'login-vpn' => 0 }
          end
          @logins_by_date[e.first[0]][e.first[1]] = e[1]
        end

      @total_logins = (@logins['login'] ||= 0) + (@logins['login-vpn'] ||= 0)
      erb :"user/dashboard"
    end

  # Show user management page
    get '/manage' do
      @user = User.where(username: session[:user]['username']).first      
      erb :"user/manage"
    end

  # Update user management page
    post '/manage' do
    # Get the users object
      @user = User.where(username: session[:user]['username']).first      
    
    # Update the users password
      unless params[:password].nil?
        if params[:password].empty? || params[:password] != params[:cpassword]
          log('User failed to update password.', 'updated-password')
          flash[:error] = "Please be sure to not leave your password blank."
        else
          log('User successfully updated password.', 'updated-password')
          flash[:success] = "You successfully updated your VPN password. Please use this password when logging into the VPN."
          @user.password = params[:password]
          @user.save!          
        end
      end

    # Update the users secret token for 2FA  
      unless params[:regenerate_token].nil?
        log('User successfully updated their secret token.', 'token-changed')
        flash[:success] = "You successfully regenerated your secret key. Please be sure to update your Password Management app like Google Authenticator, with this new secret."
        @user.secret = (0...16).map { ('A'..'Z').to_a[rand(26)] }.join
        @user.save!
      end      

      redirect "/user/manage"
    end

# Update user management page
    post '/test' do
    # Get the users object
      @user = User.where(username: session[:user]['username']).first      
    
    # Update the users password
      unless params[:password].empty?
        if @user.authenticate(params[:password])
          log('User successfully tested password authentication.', 'password-test')
          flash[:success] = "You successfully tested password authentication."
        else
          log('User failed authentication when testing password.', 'password-test')
          flash[:error] = "You failed to authenticate when using your password."
        end
      end

    # Update the users secret token for 2FA  
      unless params[:token].empty?
        totp = ROTP::TOTP.new(@user.secret)
        if !totp.verify(params[:token])
          log('User failed to test their secret token.', 'token-test')
          flash[:error] = "The token that you have provided was invalid or incorrect."
        else
          log('User successfully tested their secret token.', 'token-test')
          flash[:success] = "Congratulations! You successfully tested your token."
        end
      end

      redirect "/user/manage"
    end

  # Show Audit Log for user events
    get '/audit' do
      @audit_logs = Log.where(cn: session[:user]['username']).order('created_at DESC')
      erb :"user/audit"
    end

  end
end
