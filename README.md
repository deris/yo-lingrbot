Yo for Lingr
---

Summary
===

- Lingr部屋の会話が盛り上がった時にYoで通知する
- Yoで一度通知したらその後盛り上がっても特定の時間経過するまでは通知しない
- DBに登録したLingr部屋だけ対応する
- !Yo [member]で特定のメンバーにYoを通知する
- Callback URLで、Yoできるメンバーを限定する(Yoしたら登録し、再度Yoしたら登録解除)
- !Yo -helpでへルプを表示
- !Yo -memberでYo通知できるメンバーのリストを表示
- !Yo -yoaccountでLingr部屋に対応するYoアカウント名を表示

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

