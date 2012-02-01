# app.rb

require 'sinatra' unless defined?(Sinatra)

class App < Sinatra::Base
  configure do
    set :public_folder, "#{File.dirname(__FILE__)}/public"
    set :views, "#{File.dirname(__FILE__)}/views"
  end

  get '/' do
    send_file File.join(settings.public_folder, "index.html")
  end

  get '/cookies' do
    @info = request.cookies
    erb :cookies
  end

end
