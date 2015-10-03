require 'sinatra'

get '/' do
  erb :index
end

post '/search' do
  # use the views/agent.erb file
  erb :search
end
