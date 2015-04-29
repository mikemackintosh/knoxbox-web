controller do
  before '/admin*' do
    redirect '/' unless is_admin?
  end

  namespace '/admin' do
  # Generic Admin
    get '/' do

      @users = User.count
      @networks = Network.count
      @network_roles = NetworkRole.count

      @logins_by_date = {}
      @logins = Log.group(:category).count

    # Get login counts
      Log.where(category: ['login', 'login-vpn']).where('created_at > (SELECT DATETIME("now", "-7 day"))').
        group('strftime("%m/%d", created_at)').group(:category).count.each do |e|
          if @logins_by_date[e.first[0]].nil?
            @logins_by_date[e.first[0]] =  { 'date' => e.first[0], 'login' => 0, 'login-vpn' => 0 }
          end
          @logins_by_date[e.first[0]][e.first[1]] = e[1]
        end

    # Get total login counts
      @total_logins = (@logins['login'] ||= 0) + (@logins['login-vpn'] ||= 0)

    # Recent Logs
      @logs = Log.where('created_at > (SELECT DATETIME("now", "-7 day"))').order('id DESC')

      erb :"admin/dashboard"
    end

  # Show Users
    get '/users' do
      @users = User.all
      erb :"users/list"
    end

  # Edit User
    get '/users/:username' do
      params[:username]
    end

  # Edit User
    get '/users/:username/edit' do
      params[:username]
    end

  # Edit User
    get '/users/:username/disable' do
      params[:username]
    end

  end
end