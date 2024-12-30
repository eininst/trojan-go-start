# trojan-go-start
trojan-go-start

## 安装

```bash
make install host=yourdomain.com
```
`or`

```bash
curl -sSL https://raw.githubusercontent.com/eininst/trojan-go-start/main/install.sh | sh -s -- yourhost youremail
```

## config

`configs` -> yourdomain.com.json

```json
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": 12345,
  "remote_addr": "127.0.0.1",
  "remote_port": 443,
  "password": [
    "xxxxxxxxxx"
  ],
  "ssl": {
    "cert": "/etc/trojan-go/fullchain.pem",
    "key": "/etc/trojan-go/privkey.pem",
    "sni": "",
    "fallback_port": 443,
    "fallback_addr": "127.0.0.1"
  },
  "websocket": {
    "enabled": true,
    "path": "/ws"
  }
}
```

## Run
> make start


## More
> See [Makefile](/Makefile)

## License

*MIT*