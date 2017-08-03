require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    @req = req
    @app = "_rails_lite_app"
    @cookie = @req.cookies[@app] ? JSON.parse(@req.cookies[@app]) : {}
  end

  def [](key)
    @cookie[key] ? @cookie[key] : nil
  end

  def []=(key, val)
    @cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    attributes =  {
      path: "/",
      value: @cookie.to_json
      }

    res.set_cookie(@app,attributes)
  end
end
