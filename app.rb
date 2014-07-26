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

!Yo [member]   : memberで指定したYoアカウントにYoを送ります
!Yo -help      : ヘルプを表示します
!Yo -member    : !Yo [member]で指定できるmemberのリストを表示します

!Yo [member]でのYoの通知は、あらかじめそのYoアカウントが
Bot用のYoアカウントにYoを送り登録されている必要があります
Bot用のYoアカウントは[room名]LINGRのような名前で作成されているはずです
登録を解除したい場合は再度Bot用のYoアカウントにYoを送ります
EOS

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
        not LastYoAll.first(:created_at.lt => YO_INTERVAL.minute.ago).nil?)
      YoApi.yo_all(e['message']['room'])
      if last_yo
        last_yo.update(:created_at => DateTime.now)
      else
        LastYoAll.create(:created_at => DateTime.now)
      end
    end

    case e['message']['text']
    when /^!Yo\s+(\w+)$/
      username = $1
      if YoUser.first(:username => username.upcase)
        YoApi.yo(e['message']['room'], username)
      end
      ''
    when /^!Yo\s+-help$/
      HELP_MESSAGE
    else
      ''
    end
  end
end

get '/yo/callback' do
  # 直接Yoを送るユーザを制限するために、DBに登録しておく
  user = YoUser.first(:username => params[:username])
  if user.nil?
    YoUser.create(:username => params[:username])
  else
    user.destroy
  end
end

