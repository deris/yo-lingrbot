require 'bundler'
Bundler.require
require 'yaml'
require 'json'
require 'date'
require './model.rb'
require './customfixnum.rb'
require './yoapi.rb'

using CustomFixnumForTime

FEVER_COUNT  = 15
FEVER_MINUTE = 5
YO_INTERVAL  = 10
HELP_MESSAGE = <<EOS
Lingr部屋が盛り上がってきたらYoで通知します
他にも以下の機能を提供します

!Yo [Yoアカウント名]      : 指定したYoアカウントにYoを送ります
!Yo -add [Yoアカウント名] : !Yo [Yoアカウント名]で通知可能なYoアカウントを追加する(1ユーザ、1Yoアカウントだけ登録可能)
!Yo -delete               : !Yo [Yoアカウント名]で通知可能なYoアカウントを削除する
!Yo -member               : !Yo [Yoアカウント名]で指定できるYoアカウント名のリストを表示します
!Yo -yoaccount            : 現在のLingr部屋に対応するYoアカウント名を表示します
!Yo -help                 : ヘルプを表示します

!Yo [Yoアカウント]でのYoの通知は、あらかじめそのYoアカウントが
Bot用のYoアカウントにYoを送り登録されている必要があります
Bot用のYoアカウントは!Yo -yoaccountで表示できます
登録を解除したい場合は再度Bot用のYoアカウントにYoを送ります
EOS

get '/' do
  'Yo for Lingr'
end

post '/' do
  content_type :text
  json = JSON.parse(request.body.string)

  json['events'].select { |e| e['message'] }.map do |e|
    m = e['message']
    room = LingrRoom.first(:name => m['room'])
    return '' if room.nil?

    MessageInfo.create(
      :room       => m['room'],
      :speaker_id => m['speaker_id'],
      :nickname   => m['nickname'],
      :text       => m['text'],
      :created_at => DateTime.parse(m['timestamp']),
    )

    # DBからFEVER_MINUTE分前以前のデータ削除
    MessageInfo.all(:created_at.lt => FEVER_MINUTE.minute.ago).destroy

    # DBから過去のデータ取得
    messages = MessageInfo.all

    # Lingr部屋が盛り上がっていて、かつ前回Yo allしてからYO_INTERVAL分以上経過していた場合
    last_yo = LastYoAll.first
    if messages.length >= FEVER_COUNT and
       (last_yo.nil? or
        not LastYoAll.first(:created_at.lt => YO_INTERVAL.minute.ago).nil?)
       YoApi.yo_all(room.yo_api_token)
      if last_yo
        last_yo.update(:created_at => DateTime.now)
      else
        LastYoAll.create(:created_at => DateTime.now)
      end
    end

    case m['text']
    when /^![Yy]o\s+(\w+)$/
      username = $1.upcase
      if YoUser.first(:username => username)
        YoApi.yo(room.yo_api_token, username)
      end
      ''
    when /^![Yy]o\s+-help$/
      HELP_MESSAGE
    when /^![Yy]o\s+-add\s+(\w+)$/
      user = YoUser.first(:lingr_id => m['speaker_id'])
      if user.nil?
        YoUser.create(
          :username => $1,
          :lingr_id => m['speaker_id'],
        )
      else
        user.update(:username => $1)
      end
    when /^![Yy]o\s+-delete$/
      YoUser.first(:lingr_id => m['speaker_id']).destroy
    when /^![Yy]o\s+-member$/
      users = YoUser.all
      users.map {|u| u.username}.join("\n")
    when /^![Yy]o\s+-yoaccount$/
      room.yo_username.upcase
    else
      ''
    end
  end
end

