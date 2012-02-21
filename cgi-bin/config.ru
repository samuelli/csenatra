require './app'

# For debugging Apache's Auth
class DevHook
  def initialize(app)
    @app = app
  end

  def call(env)
    env["REMOTE_USER"] = 'test'
    @app.call(env)
  end
end

if ENV["RACK_ENV"] == 'development'
  # For my dev machine
  class ::Utility
    def self.pp(cse)
      "Full Real Name"
    end
  end
  use DevHook
end

run App
