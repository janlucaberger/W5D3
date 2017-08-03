require 'json'

class Flash

  attr_reader :req

  def initialize(req)
    @req = req
    @flash = {}
  end

  def [](key)
    if key.is_a?(String)
      key.to_sym
    end
    JSON.parse(req.cookies["_rails_lite_app_flash"])[key]
  end

  def []=(key, val)
    @flash[key] = val
  end


  def store_flash(res)
    res.set_cookie('_rails_lite_app_flash',{
      path: "/",
      value: @flash.to_json
    })

  end
end
