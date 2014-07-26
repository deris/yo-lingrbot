require 'yaml'

class YoConfig
  def self.api_token(room)
    return ENV["yolingr_apitoken_#{room}"]
  end
end

