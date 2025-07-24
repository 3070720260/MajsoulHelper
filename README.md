# Majsoul Helper

一个集成了雀魂 AI (Akagi) 和皮肤解锁 (MajsoulMax) 的辅助工具，通过 Docker 容器化部署，方便使用。

## 🐳 Docker 使用方式

```bash
docker pull arthals/majsoul-helper
```

配置项：

### 🔌 端口映射

| 容器端口 | 宿主机端口 | 服务 | 用途 |
| :--- | :--- | :--- | :--- |
| `23410` | `23410` | MajsoulMax | **(需要暴露/反代)** 游戏主代理入口 |
| `7880` | - | Akagi | (内部端口) AI 计算服务，不对外暴露 |
| `3001` | `3001` | Server | **(需要暴露/反代)** 前端渲染所需的后端服务器 |
| `4173` | `4173` | Frontend | **(需要暴露/反代)** 前端预览页面 |

### 🔑 认证

参见 [docker-compose.yml](docker-compose.yml) 中的环境变量设置。

- **入口鉴权**：通过环境变量 `PROXY_USERNAME` 和 `PROXY_PASSWORD` 设置代理认证用户名和密码，需要给 `majsoulmax` 设置。
- **更新鉴权**：通过环境变量 `AKAGI_AUTH_USERNAME` 和 `AKAGI_AUTH_PASSWORD` 设置 Akagi 发送往前端服务器 `/update` 的鉴权用户名和密码，需要同时给 server 和 akagi 设置。

### 🛠️ 启动服务

```bash
docker compose up -d
```

### 🌟 配置 & 使用

对于手机来讲，分流的操作完全类似于 MajsoulMax 的配置，你可以参考 [这篇教程](https://arthals.ink/blog/majsoul)

为了让流量能被正确代理，您需要信任 `mitmproxy` 的根证书。这个证书会在启动服务后自动生成，并保存在 `./app/mitm/mitmproxy-ca.pem` 文件中。

详细教程请参考：[信任 mitmproxy 证书](https://arthals.ink/blog/majsoul#%E4%BF%A1%E4%BB%BB%E8%AF%81%E4%B9%A6)

信任完成后，在手机上建立代理节点，参考：[代理配置](https://arthals.ink/blog/majsoul#%E4%BB%A3%E7%90%86%E9%85%8D%E7%BD%AE)

1. 类型为 `HTTP`，地址为你的服务器，端口为 `majsoulmax` 的端口（默认 `23410`）。
2. 如果有鉴权，需要设置用户名和密码。
3. 为软件分流到上述节点，具体操作可参考上述博文。

分流完成后，你还需要在前端网页中填写后端 `server` 的地址（默认 `http://127.0.0.1:3001`），从而启动前端展示。

如果你想要分离 AI 计算和前端网页，你可以移除 frontend 服务，但要保证 server、akagi、majsoulmax 在一起运行。

你可以使用类似这样的命令进行端口转发：

```bash
ssh -f -N \
    -L 0.0.0.0:23410:localhost:23410 \
    -L 0.0.0.0:3001:localhost:3001 \
    -L 0.0.0.0:4173:localhost:4173 \
    ssh_server
```

### 🔗 数据链路

1.  **流量入口**：游戏客户端的流量通过系统代理设置，指向服务器的 `23410` 端口，进入 `MajsoulMax` 服务。
2.  **皮肤解锁**：`MajsoulMax` 作为第一层 MITM 代理，对游戏流量进行拦截和修改，实现皮肤等资源的解锁。
3.  **AI 分析**：`MajsoulMax` 将处理后的流量通过上游代理（Upstream Proxy）模式转发到 `http://akagi:7880`，即 `Akagi` 服务。
4.  **AI 计算**：`Akagi` 作为第二层 MITM 代理，对游戏核心数据进行分析，调用 AI 模型进行计算，得出推荐操作。
5.  **结果推送**：`Akagi` 将计算出的 AI 推荐结果通过 HTTP POST 请求发送给 `Server` 的 `http://server:3001/update` 后端服务器，更新推荐。
6.  **前端渲染**：`Frontend` 前端页面通过 HTTP GET 轮询从 `Server` 的 `http://server:3001/recommandations` 后端服务器获取最新的 AI 推荐，并利用了 html2canvas 将 HTML 绘制成 Canvas，然后使用 WebRTC 形成 LiveStream，从而能够实时渲染直播流，以画中画的形式开启。

## 📜 许可证

本项目基于 [GPL-3.0](LICENSE) 许可证开源。