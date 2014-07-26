Yo for Lingr
---

Summary
===

- Lingr部屋の会話が盛り上がった時にYoで通知する
- Yoで一度通知したらその後盛り上がっても特定の時間経過するまでは通知しない
- config.ymlに記載した部屋だけ対応する

### config.yml

```
# config.yml
[room名]:
  api_token: [YoアカウントのAPI token]
# 必要なroom分上記を記載
```

Future work
===
- Yoの通知はバックグラウンドでLingrに負荷をかけないようにする
- !Yo [member]で特定のメンバーにYoを通知する
- !Yo -helpでへルプを表示
- !Yo -memberでYo通知できるメンバーをリストアップ
- Callback URLで、Yoできるメンバーを限定する(Yoしたら登録し、再度Yoしたら登録解除)

