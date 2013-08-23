require 'rubygems'
require 'sinatra'

set :sessions, true

get '/home'  do
"Hello World"	
end

get '/newpage' do
erb :welcome
end

get '/nestedpage' do
erb :"layers/nestedfile"
end

