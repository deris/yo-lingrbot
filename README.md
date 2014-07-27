Yo for Lingr
---

Summary
===

- Lingr部屋の会話が盛り上がった時にYoで通知する
- Yoで一度通知したらその後盛り上がっても特定の時間経過するまでは通知しない
- DBに登録したLingr部屋だけ対応する
- !Yo [Yoアカウント名]でYoを通知する
- !Yo -helpでへルプを表示
- !Yo -memberでYo通知できるメンバーのリストを表示
- !Yo -yoaccountでLingr部屋に対応するYoアカウント名を表示
- !Yo -add [Yoアカウント名]でYo通知可能なYoアカウントを追加する(1ユーザ、1Yoアカウントだけ登録可能)
- !Yo -deleteで自分が追加したYoアカウントを削除する

### DBへのLingr部屋情報の登録方法

DBへのLingr部屋情報の登録はrake taskで行います

`heroku run rake yo:add`でLingr部屋と対応するYoアカウントの情報を
登録することで対応できます

```
heroku run rake "yo:add[Lingr部屋ID,Yoアカウント名,YoアカウントAPI TOKEN]"
```

Future work
===
- Yoの通知はバックグラウンドでLingrに負荷をかけないようにする

