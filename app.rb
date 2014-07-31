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
!Yo -pattern /パターン/   : パターンを//内に設定できます。設定したパターンにマッチする発言があった場合、
                          : !Yo -addで登録したYoアカウントにYoを送ります
!Yo -pattern              : !Yo -pattern /パターン/で登録したパターンを表示します
!Yo -waitfor [Lingr ID]   : Lingr IDのユーザを登録します。その後このユーザが発言したらあなたにYoを送ります。
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
    next '' if room.nil?

    MessageInfo.create(
      :room       => m['room'],
      :speaker_id => m['speaker_id'],
      :nickname   => m['nickname'],
      :text       => m['text'],
      :created_at => DateTime.parse(m['timestamp']),
    )

    # DBからFEVER_MINUTE分前までのデータ取得(連投は１つの投稿とする)
    messages = MessageInfo.all(
      :created_at.gte => FEVER_MINUTE.minute.ago
    ).chunk {|mi|
      [mi.room, mi.speaker_id]
    }.map {|_, v| v.first}

    # Lingr部屋が盛り上がっていて、かつ前回Yo allしてからYO_INTERVAL分以上経過していた場合
    if messages.length >= FEVER_COUNT and
       LastYoAll.first(:created_at.lt => YO_INTERVAL.minute.ago)
      YoApi.yo_all(room.yo_api_token)
      LastYoAll.first.tap do |last_yo|
        last_yo ? last_yo.update(:created_at => DateTime.now)
                : LastYoAll.create(:created_at => DateTime.now)
      end
    end

    WaitForUser.all(
      :target_user   => [m['speaker_id'], m['nickname']],
      :created_at.gt => 1.day.ago,
    ).each {|user|
      YoUser.first(:lingr_id => user.lingr_id).tap {|youser|
        YoApi.yo(room.yo_api_token, youser.username) if youser
      }
    }.destroy

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
          :username => $1.upcase,
          :lingr_id => m['speaker_id'],
        )
      end
      ''
    when /^![Yy]o\s+-delete$/
      YoUser.first(:lingr_id => m['speaker_id']).destroy
      ''
    when /^![Yy]o\s+-member$/
      users = YoUser.all
      if users.empty?
        'メンバーが登録されていません'
      else
        users.map {|u| u.username}.join("\n")
      end
    when /^![Yy]o\s+-yoaccount$/
      room.yo_username.upcase
    when /^![Yy]o\s+-pattern$/
      user = YoUser.first(:lingr_id => m['speaker_id'])
      if user and user.pattern
        "/#{user.pattern}/"
      else
        'パターンが登録されていません'
      end
    when /^![Yy]o\s+-pattern\s+\/(.*)\/$/
      pattern = $1
      begin
        Regexp.compile(pattern)

        user = YoUser.first(:lingr_id => m['speaker_id'])
        if user
          user.update(:pattern => pattern.empty? ? nil : pattern)
          ''
        else
          'パターンを登録する前に!Yo -add でYoアカウントを登録する必要があります'
        end
      rescue
        "指定したパターンが不正です:/#{pattern}/"
      end
    when /^![Yy]o\s+-waitfor\s+(\S*)$/
      WaitForUser.first_or_new({:lingr_id => m['speaker_id']}, {
        :target_user => $1,
        :created_at  => DateTime.now,
      })
      ''
    else
      YoUser.all(:lingr_id.not => m['speaker_id']).select { |u|
        u and u.pattern and /#{u.pattern}/ =~ m['text']
      }.map { |u|
        YoApi.yo(room.yo_api_token, u.username)
      }
      ''
    end
  end
end

