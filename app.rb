require "roda"
require "net/http"

class App < Roda
  plugin :sessions, secret: ENV["SESSION_SECRET"]
  plugin :render
  plugin :flash

  route do |r|
    login_params = {
      client_id: ENV['FACEBOOK_APP_ID'],
      redirect_uri: URI::Parser.new.escape("http://localhost:9292/auth/facebook"),
      scope: 'pages_show_list,pages_read_engagement,pages_manage_posts',
      response_type: 'code'
    }
    @facebook_login_path = 
      "https://www.facebook.com/v24.0/dialog/oauth?#{URI.encode_www_form(login_params)}"
    @notice = flash["notice"]

    r.root do
      render "index"
    end

    r.post "logout" do
      session.clear
      flash["notice"] = "Logged out successfully."
      r.redirect "/"
    end

    r.on "auth/facebook" do
      r.get do
        if r.params["error"]
          # Handle authentication error
          @error = r.params
          render "index"
        elsif r.params["code"]
          set_facebook_page_info(r.params["code"])
          flash["notice"] = "Successfully authenticated with Facebook!"
          r.redirect "/"
        else
          @error = { "App Error" => "Unexpected response" }.merge r.params
          render "index"
        end
      end
    end

    r.on "select_page" do
      r.post do
        page_id = r.params["page_id"]
        page_access_token = session["page_data"].find { |page| page["id"] == page_id }&.[]("access_token")
        if page_id && page_access_token
          session["page_id"] = page_id
          session["page_access_token"] = page_access_token
          session["page_name"] = session["page_data"].find { |page| page["id"] == page_id }&.[]("name")
          flash["notice"] = "Page selected successfully!"
          r.redirect "/"
        else
          @error = { "Selection Error" => "Invalid page selection" }
          render "index"
        end
      end
    end

    r.on "post_to_page" do
      r.post do
        message = r.params["message"]
        if message && !message.strip.empty?
          uri = URI("https://graph.facebook.com/v24.0/#{session["page_id"]}/feed")
          params = {
            message: message,
            access_token: session["page_access_token"]
          }
          response = Net::HTTP.post_form(uri, params)
          data = JSON.parse(response.body)
          if data["error"]
            @error = data
          else
            flash["notice"] = "Post published successfully!\n" +
                             "Post ID: #{data['id']}</br>" +
                             "<a href=\"https://www.facebook.com/#{data['id'].gsub('_', '/posts/')}\" target=\"_blank\">View your Post</a>"
            r.redirect "/"
          end
        else
          @error = { "Post Error" => "Message cannot be empty" }
          render "index"
        end
      end
    end
  end

  def set_facebook_page_info(code)
    set_access_token(code)
    return if @error
    get_page_info
    render "index"
  end

  def set_access_token(code)
    # Exchange the login code for long-lived user access token
    uri = URI("https://graph.facebook.com/v24.0/oauth/access_token")
    params = {
      # redirect_uri must match the one used in the initial auth request
      redirect_uri: "http://localhost:9292/auth/facebook",
      client_id: ENV["FACEBOOK_APP_ID"],
      client_secret: ENV["FACEBOOK_APP_SECRET"],
      code: code
    }
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)
    data = JSON.parse(response.body)
    if data["error"]
      @error = data
      return
    end
    if !data["access_token"]
      @error = { "Token Error" => "No access token received" }
      return
    end
    session["access_token"] = data["access_token"]
  end

  def get_page_info
    # Use the user access token to get the list of pages they manage
    uri = URI("https://graph.facebook.com/v24.0/me/accounts")
    params = {
      access_token: session["access_token"]
    }
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)
    data = JSON.parse(response.body)
    if data["error"]
      @error = data
      return
    end
    if data["data"] && data["data"].any?
      session["page_data"] = data["data"]
    else
      @error = { "Page Error" => "No managed pages found" }.merge data
    end
  end
end

