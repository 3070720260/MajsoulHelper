# Majsoul Helper

一个集成了雀魂 AI（[Akagi](https://github.com/shinkuan/Akagi)）和皮肤解锁（[MajsoulMax](https://github.com/Avenshy/MajsoulMax)）的辅助工具，通过 Docker 容器化部署，并以前端进行展示，方便移动端使用。

上述两个 Repo 在镜像里都进行了一定的修改，以适配 Docker 容器化部署，具体来说：

1. 使用修改的 [MajsoulMax](https://github.com/zhuozhiyongde/MajsoulMax)，增加 HTTP Auth 和上游代理
2. 使用修改的 [Akagi](https://github.com/zhuozhiyongde/Akagi)，移除了原有的 TUI，直接将结果推送到后端服务器

## 🐳 Docker 使用方式

```bash
docker pull arthals/majsoul-helper
docker pull arthals/majsoul-helper-frontend
```

配置项：

### 🔌 端口映射与代理配置

| 容器端口 | 宿主机端口 | 服务 | 用途 |
| :--- | :--- | :--- | :--- |
| `23410` | `23410` | MajsoulMax | **(需要暴露/反代)** 游戏主代理入口 |
| `7880` | - | Akagi MITM | (内部端口) AI 解析计算服务，不对外暴露 |
| `8765` | `8765` | Akagi DataServer | **(需要暴露/反代)** 前端渲染所需的后端，用于推送 AI 推荐结果 |
| `80` | `80` | Frontend | **(需要暴露/反代)** 前端预览页面 |

`majsoulmax` 服务需要通过 GitHub 更新依赖，所以你可能需要为之设置 `http_proxy` 和 `https_proxy` 环境变量，如 `http_proxy=http://172.17.0.1:7890`。具体参见示例 `docker-compose.yml`。

同时，考虑到多账号分离部署的情况，你可以为 `majsoulmax` 设置上游代理，如 `http://akagi-1:7880`（默认 `http://akagi:7880`），从而实现多账号分离部署。

### 🔑 认证

**入口鉴权**：通过环境变量 `PROXY_USERNAME` 和 `PROXY_PASSWORD` 设置代理认证用户名和密码，需要给 `majsoulmax` 设置。

### 🛠️ 启动服务

```bash
docker compose up -d
```

所需操作的配置文件和日志都会生成在 `./app` 目录下，不过为了编辑、查看这些文件，你可能需要首先执行：

```bash
sudo chmod -R 777 ./app
```

注意，一定要使用挂载卷来挂载 `majsoulmax` 的 `proto` 目录，否则首次启动服务器后，`config` 会更新而实际的依赖并未更新，会导致后续如果重启服务（如修改配置），依赖的实际版本和 `config` 记录的版本不一样，导致错误。这可能体现在某些新皮肤、角色（如 Saber）没有，或者直接导致程序出错。

### 🌟 配置 & 使用

对于手机来讲，分流的操作完全类似于 MajsoulMax 的配置，你可以参考 [这篇教程](https://arthals.ink/blog/majsoul)

为了让流量能被正确代理，您需要信任 `mitmproxy` 的根证书。这个证书会在启动服务后自动生成，并保存在 `./app/mitm/mitmproxy-ca.pem` 文件中。

详细教程请参考：[信任 mitmproxy 证书](https://arthals.ink/blog/majsoul#%E4%BF%A1%E4%BB%BB%E8%AF%81%E4%B9%A6)

信任完成后，在手机上建立代理节点，参考：[代理配置](https://arthals.ink/blog/majsoul#%E4%BB%A3%E7%90%86%E9%85%8D%E7%BD%AE)

1. 类型为 `HTTPS`，地址为你的服务器，端口为 `majsoulmax` 的端口（默认 `23410`），设置 `skip-cert-verify` 为 `True`
2. 如果有鉴权，需要设置用户名和密码。
3. 为软件分流到上述节点，具体操作可参考上述博文。

参考配置如下。

Clash：

```yaml
proxies:
    - name: MajsoulAI
      port: 23410
      server: your server ip
      tls: true
      type: http
      skip-cert-verify: true
      username: 'PROXY_USERNAME'
      password: 'PROXY_PASSWORD'
proxy-groups:
    - name: 🀄 雀魂麻将
      proxies:
          - MajsoulAI
          - DIRECT
      type: select
rules:
    - DOMAIN-KEYWORD,majsoul,🀄 雀魂麻将
    - DOMAIN-KEYWORD,maj-soul,🀄 雀魂麻将
    - DOMAIN-KEYWORD,catmjstudio,🀄 雀魂麻将
    - DOMAIN-KEYWORD,catmajsoul,🀄 雀魂麻将
    - IP-CIDR,146.66.155.0/24,🀄 雀魂麻将
    - IP-CIDR,185.25.182.18/32,🀄 雀魂麻将
    - IP-CIDR,203.107.63.200/32,🀄 雀魂麻将
```

Surge：

```text
[Proxy]
MajsoulAI = https, your_server_ip, 23410, username, password, skip-cert-verify=true

[Proxy Group]
🀄 雀魂麻将 = select, MajsoulAI, DIRECT

[Rule]
DOMAIN-KEYWORD,majsoul,🀄 雀魂麻将
DOMAIN-KEYWORD,maj-soul,🀄 雀魂麻将
DOMAIN-KEYWORD,catmjstudio,🀄 雀魂麻将
DOMAIN-KEYWORD,catmajsoul,🀄 雀魂麻将
IP-CIDR,146.66.155.0/24,🀄 雀魂麻将
IP-CIDR,185.25.182.18/32,🀄 雀魂麻将
IP-CIDR,203.107.63.200/32,🀄 雀魂麻将
```

分流完成后，你还需要在前端网页中填写后端 `server` 的地址（默认 `ws://127.0.0.1:3001`），从而启动前端展示，注意 `https` 网页必须使用 `wss` 协议。

如果你想要分离 AI 计算和前端网页，你可以单独部署 [frontend 服务](https://github.com/zhuozhiyongde/AkagiFrontend)，但要保证 akagi、majsoulmax 在一起运行。

你可以使用类似这样的命令进行端口转发：

```bash
ssh -f -N \
    -L 0.0.0.0:23410:localhost:23410 \
    -L 0.0.0.0:8765:localhost:8765 \
    ssh_server
```

### 🔗 数据链路

1.  **流量入口**：游戏客户端的流量通过系统代理设置，指向服务器的 `23410` 端口，进入 `MajsoulMax` 服务。
2.  **皮肤解锁**：`MajsoulMax` 作为第一层 MITM 代理，对游戏流量进行拦截和修改，实现皮肤等资源的解锁。
3.  **AI 分析**：`MajsoulMax` 将处理后的流量通过上游代理（Upstream Proxy）模式转发到 `http://akagi:7880`，即 `Akagi` 服务。
4.  **AI 计算**：`Akagi` 作为第二层 MITM 代理，对游戏核心数据进行分析，调用 AI 模型进行计算，得出推荐操作。
5.  **结果推送**：`Akagi` 将计算出的 AI 推荐结果直接推送给 `DataServer` 服务，该服务会为所有已经建立的 WebSocket 连接推送最新的 AI 推荐结果。
6.  **前端渲染**：`Frontend` 前端页面通过 WebSocket (`ws://<DataServer_IP>:8765`) 从 `DataServer` 实时接收最新的 AI 推荐，并利用了 html2canvas 将 HTML 绘制成 Canvas，然后使用 WebRTC 形成 LiveStream，从而能够实时渲染直播流，以画中画的形式开启。

## 📜 许可证

本项目基于 [GNU General Public License v3.0](LICENSE) 许可证开源。