require 'dm-core'
require 'dm-migrations'

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

