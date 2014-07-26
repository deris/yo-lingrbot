require 'uri'
require 'net/http'
require './yoconfig.rb'

class YoApi
  def yo_all(room)
    Net::HTTP.post_form(
      URI.parse('http://api.justyo.co/yoall/'),
      {api_token: YoConfig.api_token(room)},
    )
  end

  def yo(room, username)
    Net::HTTP.post_form(
      URI.parse('http://api.justyo.co/yo/'),
      {
        api_token: YoConfig.api_token(room),
        username: username,
      },
    )
  end
end
