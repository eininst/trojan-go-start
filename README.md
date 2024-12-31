# trojan-go-start
## 简介
`trojan-go-start` 是一个用于快速部署和配置 `trojan-go` 的脚本工具。`trojan-go` 是基于 Go 语言开发的 Trojan 协议实现，旨在提供高性能、安全的网络代理服务，广泛用于科学上网和隐私保护。


## 安装

```shell
source <(curl -Ls https://raw.githubusercontent.com/eininst/trojan-go-start/main/install.sh)
```

## Cmd
| 命令       | 说明                   |
|------------|----------------------|
| start      | 启动 caddy 和 trojan-go |
| stop       | 停止 caddy 和 trojan-go |
| tlog       | 查看 trojan-go 运行日志    |
| clog       | 查看 caddy 运行日志        |
| tstart     | 运行 trojan-go         |
| tstop      | 停止 trojan-go         |
| trestart   | 重启 trojan-go         |
| caddy start | 运行 caddy             |
| caddy stop | 停止 caddy             |
| caddy reload| 重启 caddy             |
| schema| 获取URI连接地址            |


### 特性
- **快速安装**：一键安装 `trojan-go`，简化部署过程。
- **自动配置**：自动生成和配置必要的配置文件。
- **环境变量支持**：通过环境变量灵活配置域名、端口等参数。
- **自动获取证书**：集成 Let's Encrypt，自动获取和更新 SSL 证书。
- **Systemd 支持**：提供 Systemd 服务管理，轻松启动、停止和重启服务。
- **日志管理**：集成日志记录，方便排查问题。


### Trojan-Go 对抗 GFW 的效果

1. **伪装流量**：
   Trojan-Go 使用 TLS（传输层安全协议）加密通信流量，和正常的 HTTPS 流量非常相似，这使得它能够有效伪装自己，不容易被深度包检测（DPI）技术发现。由于流量加密且与常见的 HTTPS 流量相似，它通常不会引起 GFW 的注意。

2. **动态端口与域名支持**：
   Trojan-Go 支持通过配置多个域名和端口来增加混淆性。GFW 主要通过黑名单和深度包检测等方式识别代理流量，因此多变的域名和端口可以进一步提升规避封锁的能力。

3. **集成 Let's Encrypt 证书**：
   Trojan-Go 能够通过自动获取和更新 SSL 证书（集成 Let's Encrypt），确保通信使用的是可信证书，这样能有效降低被中间人攻击或被识别为非正常流量的风险。

4. **抗封锁性**：
   在多种情况下，Trojan-Go 可以对抗 GFW 的封锁。它的抗封锁效果通常比 Shadowsocks 和 V2Ray 更强，因为其流量更难被区分和检测。对于 GFW 的封锁，Trojan-Go 可以通过流量特征、加密方式、证书伪装等手段增强抗干扰性。

4. **GFW主动检测**：
   Trojan可以正确识别非Trojan协议的流量。与Shadowsocks等代理不同的是，此时Trojan不会断开连接，而是将这个连接代理到一个正常的Web服务器。在GFW看来，该服务器的行为和一个普通的HTTPS网站行为完全相同，无法判断是否是一个Trojan代理节点, 配置(`fallback_addr`,`fallback_port`)


## websocket选项
在正常的直接连接代理节点的情况下，开启这个选项不会改善你的链路速度（甚至有可能下降），也不会提升你的连接安全性。
你只应该在需要利用CDN进行中转，或利用nginx,caddy等服务器根据路径分发的情况下，使用websocket



## Client
> See [Releases](https://github.com/eininst/trojan-go-start/releases)

[//]: # (Raksmart)
[//]: # (https://help.mints7.cc)

## License

*MIT*