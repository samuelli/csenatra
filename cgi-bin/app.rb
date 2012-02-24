require 'bundler'
Bundler.setup(:default, ENV["RACK_ENV"])
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
RACK_ROOT = File.dirname(__FILE__)
require 'sinatra' unless defined?(Sinatra)
require 'json'
require 'gollum/frontend/app'

BASE_PATH = "/~maxs"

require 'lib/core_app'

# Load Apps
require 'lib/api'
require 'lib/wiki'
require 'lib/root_app'

module Rack
  class WikiIndex
    def initialize(app, options={})
      @app = app
    end
  
    def call(env)
      if ["", "/", "/index.html"].include?(env["PATH_INFO"])
        env["PATH_INFO"] = "/wiki"
      end
      @app.call(env)
    end
  end
end

main_app = Rack::Builder.new do  
  
  use Rack::Static, :urls => ['/css', '/javascript', '/images'], :root => Precious::App.settings.public_folder
  use Rack::WikiIndex
  
  map "/api" do
    run ApiApp
  end
  
  map "/wiki" do
    run Precious::App
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
  use Rack::Session::Cookie, :key => 'rack.session.maxs',
                             :path => '/~maxs',
                             :expire_after => 2592000
                             # TODO: :secret => 'password'

  # This only occurs on local machine, since the rewrite removes it.
  map BASE_PATH do
    run main_app
  end
  
  # This is what actually gets used on the server.
  map "/" do
    run main_app
  end
end
