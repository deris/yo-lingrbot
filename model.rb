require 'bundler'
Bundler.require

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite:db/test.db')

class MessageInfo
  include DataMapper::Resource
  property :id, Serial
  property :room, String
  property :speaker_id, String
  property :nickname, String
  property :text, Text
  property :created_at, DateTime
  auto_upgrade!
end

class LastYoAll
  include DataMapper::Resource
  property :id, Serial
  property :created_at, DateTime
  auto_upgrade!
end

class YoUser
  include DataMapper::Resource
  property :id, Serial
  property :username, String
  property :lingr_id, String
  auto_upgrade!
end

class LingrRoom
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :yo_username, String
  property :yo_api_token, String
  auto_upgrade!
end

