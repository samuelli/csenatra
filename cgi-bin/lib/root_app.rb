class RootApp < CoreApp
  # Login auth
  get '/auth' do
    if env["REMOTE_USER"]
      session[:user] = env["REMOTE_USER"]
      redirect "#{BASE_PATH}/"
    else
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end
end
