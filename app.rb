require 'rubygems'
require 'bundler'
Bundler.require
require 'yaml'
require 'json'
require 'uri'
require 'net/http'
require 'date'
require './model.rb'
require './yoconfig.rb'
require './customfixnum.rb'

using CustomFixnumForTime

FEVER_COUNT  = 15
FEVER_MINUTE = 5
YO_INTERVAL  = 10

get '/' do
  'Yo for Lingr'
end

post '/' do
  content_type :text
  json = JSON.parse(request.body.string)

  json['events'].select { |e| e['message'] }.map do |e|
    MessageInfo.create(
      :room       => e['message']['room'],
      :speaker_id => e['message']['speaker_id'],
      :nickname   => e['message']['nickname'],
      :text       => e['message']['text'],
      :created_at => DateTime.parse(e['message']['timestamp']),
    )

    # DBからFEVER_MINUTE分前以前のデータ削除
    MessageInfo.all(:created_at.lt => FEVER_MINUTE.minute.ago).destroy

    # DBから過去のデータ取得
    messages = MessageInfo.all

    # Lingr部屋が盛り上がっていて、かつ前回Yo allしてからYO_INTERVAL分以上経過していた場合
    last_yo = LastYoAll.first
    if messages.length >= FEVER_COUNT and
       (last_yo.nil? or
        not LastYoAll.first(:created_at.lt => YO_INTERVAL.minute.ago).nil?) then
      Net::HTTP.post_form(
        URI.parse('http://api.justyo.co/yoall/'),
        {api_token: YoConfig.api_token(e['message']['room'])},
      )
      if last_yo then
        last_yo.update(:created_at => DateTime.now)
      else
        LastYoAll.create(:created_at => DateTime.now)
      end
    end
    ''
  end
end

