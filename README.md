Yo for Lingr
---

Summary
===

- Lingr部屋の会話が盛り上がった時にYoで通知する
- Yoで一度通知したらその後盛り上がっても特定の時間経過するまでは通知しない
- 環境変数に記載した部屋だけ対応する
- !Yo [member]で特定のメンバーにYoを通知する
- Callback URLで、Yoできるメンバーを限定する(Yoしたら登録し、再度Yoしたら登録解除)

### 環境変数

環境変数に部屋を記載するルールは以下

```
$yolingr_apitoken_[Lingrの部屋ID]
```

Future work
===
- Yoの通知はバックグラウンドでLingrに負荷をかけないようにする
- !Yo -helpでへルプを表示
- !Yo -memberでYo通知できるメンバーをリストアップ

