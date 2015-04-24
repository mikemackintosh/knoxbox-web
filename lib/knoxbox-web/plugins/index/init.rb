controller do 
  namespace '/' do
    get '/' do
      puts session.inspect
      puts "----------------"
      erb :index
    end
  end 
end