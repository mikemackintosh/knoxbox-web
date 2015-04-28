controller do 
  namespace '/' do
    get '/' do
      redirect '/user/dashboard'
    end
  end 
end