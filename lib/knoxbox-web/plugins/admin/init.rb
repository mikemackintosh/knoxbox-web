controller do
  before '/admin*' do
    redirect_to '/' unless is_admin?
  end

  namespace '/admin' do
  # Generic Admin
    get '/' do
      erb :admin_general
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