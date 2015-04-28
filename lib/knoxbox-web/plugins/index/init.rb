controller do 
  namespace '/' do
    get '/' do
      redirect '/user/manage'
    end
  end 
end