# app.rb

# Gems
# On a local dev machine, you can use bundler/setup.
# On a restricted server, you need the load path modifier.
# require 'bundler/setup'

Dir[File.join(File::dirname(__FILE__), "./vendor/gems/**")].map do |dir|
  File.directory?(lib = "#{dir}/lib") ? lib : dir
end.each {|x| $LOAD_PATH << x}
require 'sinatra' unless defined?(Sinatra)

class App < Sinatra::Base
  configure do
    set :public_folder, "#{File.dirname(__FILE__)}/public"
    set :views, "#{File.dirname(__FILE__)}/views"
  end

  get '/' do
    @info = request.cookies
    erb :index
  end

end
