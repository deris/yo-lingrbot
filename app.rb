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
YO_INTERVAL  = 30
HELP_MESSAGE = <<EOS
Lingr部屋が盛り上がってきたらYoで通知します
通知するアカウントはLingr部屋ごとに用意しており、
このアカウントをフォローすることで盛り上がりの通知を受信できます
通知するアカウントは以下のコマンドで確認できます

!Yo -yoaccount            : 現在のLingr部屋に対応するYoアカウント名を表示します

他にも以下の機能を提供します

!Yo [Yoアカウント名]      : 指定したYoアカウントにYoを送ります
!Yo -add [Yoアカウント名] : !Yo [Yoアカウント名]で通知可能なYoアカウントを追加します(1ユーザ、1Yoアカウントだけ登録可能)
!Yo -delete               : !Yo [Yoアカウント名]で通知可能なYoアカウントを削除します
!Yo -member               : !Yo [Yoアカウント名]で指定できるYoアカウント名のリストを表示します
!Yo -help                 : ヘルプを表示します

!Yo [Yoアカウント]でのYoの通知は、あらかじめそのYoアカウントが
!Yo -add [Yoアカウント名]で登録されている必要があります
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

    # DBから過去のデータ取得(連投は１つの投稿とする)
    prev = nil
    messages = MessageInfo.all.select do |info|
      not (prev and
           info['room'] == prev['room'] and
           info['speaker_id'] == prev['speaker_id']).tap {prev = info}
    end

    # Lingr部屋が盛り上がっていて、かつ前回Yo allしてからYO_INTERVAL分以上経過していた場合
    last_yo = LastYoAll.first
    if messages.length >= FEVER_COUNT and
       (last_yo.nil? or
        LastYoAll.first(:created_at.lt => YO_INTERVAL.minute.ago))
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
      YoApi.yo(room.yo_api_token, username) if YoUser.first(:username => username)
      ''
    when /^![Yy]o\s+-help$/
      HELP_MESSAGE
    when /^![Yy]o\s+-add\s+(\w+)$/
      user = YoUser.first(:lingr_id => m['speaker_id'])
      if user
        user.update(:username => $1.upcase)
      else
        YoUser.create(
          :username => $1.upupcase,
          :lingr_id => m['speaker_id'],
        )
      end
      ''
    when /^![Yy]o\s+-delete$/
      YoUser.first(:lingr_id => m['speaker_id']).destroy
      ''
    when /^![Yy]o\s+-member$/
      users = YoUser.all
      users.map {|u| u.username}.join("\n")
    when /^![Yy]o\s+-yoaccount$/
      room.yo_username.upcase
    when /^![Yy]o\b/
      "!Yoに指定する引数が不正です\n" +
      "!Yo -helpでコマンドの引数を確認してください"
    else
      ''
    end
  end
end

