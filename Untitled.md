ec2


```
sudo yum install -y git openssl-devel gcc-c++ make
git clone git://github.com/creationix/nvm.git .nvm
. .nvm/nvm.sh

nvm install v0.12.0
nvm use v0.12.0
npm install -g yo grunt-cli gulp bower
```

アピアリーズ
<REQ>
HTTP/1.1
POST
https://api-datastore.appiaries.com/v1/tkn/_sandbox/authv1/

X-APPIARIES-TOKEN: app6e4274db9cdc6324c803ed3e6e
Content-Type: application/json
Content-Length: 47(可変)
Cache-Control: no-cache
Connection: keep-alive

{
"login_id":"hogehogetaro",
"pw":"00000000",
}

<RES>
201 Created

{"_token":"strca44e5148e3323bfd0c738bb9f","_id":"d50dc70903cd4caf17618182cea","user_id":"d50dc70903cd4caf17618182cea"}
