require 'bundler'
Bundler.setup(:default, ENV["RACK_ENV"])
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
RACK_ROOT = File.dirname(__FILE__)
require 'sinatra' unless defined?(Sinatra)
require 'json'

require 'lib/core_app'

# Load Apps
require 'lib/api'

class RootApp < CoreApp
  get '/' do
    send_file File.join(settings.public_folder, "index.html")
  end
  
  # Login auth
  get '/auth' do
    if env["REMOTE_USER"]
      session[:user] = env["REMOTE_USER"]
      redirect "/~maxs/"
    else
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end
end

main_app = Rack::Builder.new do  
  map "/api" do
    run ApiApp
  end
  
  map "/" do
    run RootApp
  end
end

App = Rack::Builder.new do
  use Rack::Lock
  use Rack::Lint
  use Rack::MethodOverride
  use Rack::Head
  use Rack::ConditionalGet
  use Rack::Session::Cookie, :key => 'rack.session.maxs',
                             :path => '/~maxs',
                             :expire_after => 2592000
                             # TODO: :secret => 'password'

  # This only occurs on local machine, since the rewrite removes it.
  map "/~maxs" do
    run main_app
  end
  
  # This is what actually gets used on the server.
  map "/" do
    run main_app
  end
end
