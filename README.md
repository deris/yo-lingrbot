Yo for Lingr
---

Summary
===

- Lingr部屋の会話が盛り上がった時にYoで通知する
- Yoで一度通知したらその後盛り上がっても特定の時間経過するまでは通知しない
- DBに登録した部屋だけ対応する
- !Yo [member]で特定のメンバーにYoを通知する
- Callback URLで、Yoできるメンバーを限定する(Yoしたら登録し、再度Yoしたら登録解除)
- !Yo -helpでへルプを表示
- !Yo -memberでYo通知できるメンバーのリストを表示

### db/seed.rb

db/seed.rbに以下の様にLingr部屋の情報を記載し、

`heroku rake db:set`することで対応する部屋の情報を登録できます

```ruby
# db/seed.rb
LingrRoom.create!(
  :name         => 'room name',
  :yo_username  => 'yo username',
  :yo_api_token => 'yo api token',
)
```

Future work
===
- Yoの通知はバックグラウンドでLingrに負荷をかけないようにする

