# trojan-go-start
## 简介
`trojan-go-start` 是一个用于快速部署和配置 `trojan-go` 的脚本工具。`trojan-go` 是基于 Go 语言开发的 Trojan 协议实现，旨在提供高性能、安全的网络代理服务，广泛用于科学上网和隐私保护。

## 特性
- **快速安装**：一键安装 `trojan-go`，简化部署过程。
- **自动配置**：自动生成和配置必要的配置文件。
- **环境变量支持**：通过环境变量灵活配置域名、端口等参数。
- **自动获取证书**：集成 Let's Encrypt，自动获取和更新 SSL 证书。
- **Systemd 支持**：提供 Systemd 服务管理，轻松启动、停止和重启服务。
- **日志管理**：集成日志记录，方便排查问题。

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