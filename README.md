# vim .env

```
FREEE_CLIENT_ID='***'
FREEE_SECRET_KEY='***'
FREEE_CALLBACK_URL='http://freee2kintone.dev/callback'
FREEE_COMPANY_ID='9999'

KINTONE_HOST='****.cybozu.com'
KINTONE_USER='****'
KINTONE_PASS='****'
KINTONE_APP='**'
```

# save freee token
* bundle install
* rake db:setup
* powder link
* powder open
* access http://freee2kintone.dev/login
* `rails c`
* `Freee.sync #Freeeのデータをローカルに保存`
* `Kntn.sync #ローカルに保存されたFreeeのデータをkintoneにアップロード`
