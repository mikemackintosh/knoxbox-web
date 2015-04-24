controller do 
  namespace '/' do
    get '/' do
      
      if is_admin?
        
      end

      erb :index
    end
  end 
end