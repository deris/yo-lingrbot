require 'uri'
require 'net/http'

class YoApi
  def self.yo_all(api_token)
    Net::HTTP.post_form(
      URI.parse('http://api.justyo.co/yoall/'),
      {api_token: api_token},
    )
  end

  def self.yo(api_token, username)
    Net::HTTP.post_form(
      URI.parse('http://api.justyo.co/yo/'),
      {
        api_token: api_token,
        username: username,
      },
    )
  end
end
