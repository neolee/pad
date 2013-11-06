require 'rubygems' if RUBY_VERSION < "1.9"
require 'omniauth'

require File.join(File.dirname(__FILE__), 'model.rb')

module PAD
  class Main < Base
    set :root, File.dirname(__FILE__)

    use Rack::Session::Cookie, :key => 'rack.session',
                               :path => '/',
                               :expire_after => 2592000,
                               :secret => '6539a8628b0e7d39fabacf0479a159ef'

    use OmniAuth::Builder do
      provider :twitter, 'TzadAI8gaQ0jMZVyp9SPg', 'hVVfW0TXBxWLJZrnfMTFCa69IkrvDhEpvEs0QkpekU'
    end

    # Filters

    # Routes
    # login to start
    get '/login/?' do
      haml :login
    end

    # twitter oauth login callback
    get "/auth/:provider/callback" do
      @auth = request.env['omniauth.auth']
      twitter = @auth['info']['nickname']
      @user = User.first_or_create({:twitter => twitter}, {
        :username   => twitter,
        :twitter    => twitter,
        :avatar     => @auth['info']['image'],
        :created_at => Time.now
      })
      session[:user_id] = @user.id
      session[:username] = @user.username

      if session[:previous_url]
        redirect_to = session[:previous_url]
        session[:previous_url] = nil
        redirect redirect_to
      else
        # haml :auth_callback
        redirect '/'
      end
    end

    # logout
    get '/logout/?' do
      session.clear
      redirect '/'
    end

    # show user profile
    get '/users/:id' do
      @user = User.get(params[:id])
      haml :user
    end

    # update attrs of logged in user
    patch '/users/:id' do
      if params[:id].to_i != session[:user_id].to_i
        error 401
      end

      user = User.get(params[:id])
      email = params[:email]
      current_password = params[:current_password]
      new_password = params[:new_password]

      # check current password
      if user.password and !user.password.empty? and !password_check(current_password, user.password)
        error 403
      end

      data = {}
      if new_password and !new_password.empty?
        data[:password] = password_encode(new_password)
      end
      if email and !email.empty?
        data[:email] = email
      end
      if data.empty?
        error 400, 'Nothing changed.'
      end

      if !user.update(data)
        error_msgs = Array.new
        user.errors.each {|e| error_msgs << e[0]}
        error 400, error_msgs.join(';')
      end
    end

    # show all posts
    get '/', '/posts/?' do
      haml :index
    end

  end
end
