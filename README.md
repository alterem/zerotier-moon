# zerotier-moon
🌕 一步创建 ZeroTier Moon 的 Docker 镜像。

此镜像简化了使用 Docker 设置 ZeroTier Moon 节点的过程。

## 🐳 Docker

```bash
docker run -d \
  --cap-add=NET_ADMIN --cap-add=SYS_ADMIN \
  --device=/dev/net/tun \
  --name zerotier-moon \
  --restart unless-stopped \
  -p 9993:9993/udp \
  -v zerotier-one:/var/lib/zerotier-one \
  ghcr.io/alterem/zerotier-moon:latest
```

## 📦 Docker Compose

```yaml
services:
  zerotier-moon:
    image: ghcr.io/alterem/zerotier-moon:latest
    container_name: zerotier-moon
    restart: always
    cap_add:
      - NET_ADMIN
      - SYS_ADMIN
    devices:
      - /dev/net/tun
    ports:
      - 9993:9993/udp
    command:
      - -p 9993
    volumes:
      - ./zerotier-one:/var/lib/zerotier-one
```

🌐 **参数说明:**
- `-4 <ipv4_address>`: 指定 ZeroTier Moon 的公网 IPv4 地址。如果未指定，脚本将尝试自动检测。
- `-6 <ipv6_address>`: 指定 ZeroTier Moon 的公网 IPv6 地址。如果未指定，脚本将尝试自动检测。
- `-p <port>`: 指定 ZeroTier Moon 的端口。如果未指定，默认为 9993。

注意: 必须至少成功获取到一个公网 IPv4 或 IPv6 地址（通过手动指定或自动检测），否则脚本将退出。`-p` 参数是可选的。

✨ 成功设置后，日志输出应如下所示：

```
IPv4 address: xxx.xxx.xxx.xxx
stableEndpoints: "xxx.xxx.xxx.xxx/9993"
Your ZeroTier moon id is [your_moon_id], you could orbit moon using "zerotier-cli orbit [your_moon_id] [your_moon_id]"
```
