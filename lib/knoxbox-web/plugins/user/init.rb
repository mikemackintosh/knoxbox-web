controller do
  before '/user*' do
    redirect '/' unless is_authenticated?
    @user = User.where(username: session[:user]['username']).first
  end

  namespace '/user' do
  # Generic Admin
    get '/download' do
    # Regenerate the cert
      if @user.cert.to_s.empty? || @user.key.to_s.empty?
        log("Creating certificate with fingerprint '#{KnoxBoxWeb::EasyRSA::fingerprint(g[:crt])}", 'certificate-create')      
        c = KnoxBoxWeb::EasyRSA::create_cert("#{@user.given_name} #{@user.family_name}", @user.email)
        @user.key = c[0]
        @user.cert = c[1]
        @user.save!
      end

    # Read the cert
      @ca_cert = settings.ca_cert
      @user_certificate = OpenSSL::X509::Certificate.new @user.cert

    # Log the config download
      log('Configuration downloaded via self-service portal', 'download')
      attachment "KnoxBox - #{session[:user]['username']}.ovpn"

    # Generate the client config
      erb :"user/client", :layout => false
    end

  # Show user management page
    get '/dashboard' do
      @logins_by_date = {}
      @logins = Log.where(cn: session[:user]['username']).group(:category).count

    # Get login counts
      Log.where(cn: session[:user]['username'], category: ['login', 'login-vpn']).where('created_at > (SELECT DATETIME("now", "-7 day"))').
        group('strftime("%m/%d", created_at)').group(:category).count.each do |e|
          if @logins_by_date[e.first[0]].nil?
            @logins_by_date[e.first[0]] =  { 'date' => e.first[0], 'login' => 0, 'login-vpn' => 0 }
          end
          @logins_by_date[e.first[0]][e.first[1]] = e[1]
        end

    # Get total login counts
      @total_logins = (@logins['login'] ||= 0) + (@logins['login-vpn'] ||= 0)
      erb :"user/dashboard"
    end

  # Show user management page
    get '/manage' do
      erb :"user/manage"
    end

  # Update user management page
    post '/manage' do
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

    # Update the users certificate and key
      unless params[:regenerate_certificate].nil?

        KnoxBoxWeb::EasyRSA::revoke(@user.cert)
        log("Revoking certificate with fingerprint '#{KnoxBoxWeb::EasyRSA::fingerprint(@user.cert)}", 'certificate-revoke')

        c = KnoxBoxWeb::EasyRSA::create_cert("#{@user.given_name} #{@user.family_name}", @user.email)
        puts c.inspect
        log("Creating certificate with fingerprint '#{KnoxBoxWeb::EasyRSA::fingerprint(c[1])}", 'certificate-create')
        @user.key = c[0]
        @user.cert = c[1]
        @user.save!
        flash[:success] = 'You successfully regenerated you client certificate. Please make sure to <a href="/user/download">download it now</a>. Your old certificate will no longer work.'
      end

    # Update the users secret token for 2FA
      unless params[:regenerate_token].nil?
        log('User updated their secret token.', 'token-changed')
        flash[:success] = "You successfully regenerated your secret key. Please be sure to update your Password Management app like Google Authenticator, with this new secret."
        @user.secret = (0...16).map { ('A'..'Z').to_a[rand(26)] }.join
        @user.save!
      end

      redirect "/user/manage"
    end

# Update user management page
    post '/test' do
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
