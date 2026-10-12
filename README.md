# 影视服 · 观影服务平台

**MediaDock — Self-hosted Media Service Portal**

影视服为自托管媒体服务提供统一的观影门户，集成影视库预览、影片搜索、求片订阅、套餐展示、订单管理和卡密交付。黑金界面搭配可编辑公告、使用教程及线路状态，让用户从了解片库到购买、领取和使用服务，都能在同一个入口完成。

支持对接 Emby、NextEmby、NextFind 和 TMDB，并保留闲鱼、小红书渠道模块。服务地址、域名、Token、平台账号、商品和付款入口均由部署者自行配置。平台不附带影片、媒体服务账号、CDN 或支付渠道。

**当前版本：1.0.0 · 部署资料已发布，容器镜像待提供。**

本仓库公开项目介绍、部署模板及使用说明，**不包含应用源码、账号或业务数据**。仅下载这些文件还不能启动应用，需先取得维护者提供的容器镜像及拉取权限。

- [下载 v1.0.0 部署资料](https://github.com/daidaiya7/media-dock-release/releases/tag/v1.0.0)
- [配置清单](docs/CONFIGURATION.md) · [使用指南](docs/USAGE.md)
- [使用问题与镜像获取咨询](https://github.com/daidaiya7/media-dock-release/issues)（请勿发送凭据）

## 功能

- 影视库封面、搜索、海报与详情预览。
- 求片申请、管理员审核和兼容服务订阅对接。
- 套餐、购买提醒、订单核对及卡密领取。
- 闲鱼与小红书渠道适配，使用部署者自己的账号。
- 首页公告、简介、教程与热门影片缓存。
- 服务端监测和用户浏览器的 HTTPS 响应时间检测。
- 独立数据卷与凭据卷，便于备份和迁移。

## Docker 部署

以下步骤适用于已取得可用镜像的部署者。安装 Docker 与 Docker Compose v2，下载并解压发行页的部署资料，或克隆本仓库：

```sh
git clone https://github.com/daidaiya7/media-dock-release.git
cd media-dock-release
```

```sh
cp .env.example .env
```

编辑 `.env`，将 `MEDIADOCK_IMAGE` 改为维护者提供的镜像及版本。私有镜像仓库使用你自己的只读拉取凭据登录，不要索取或共用维护者的管理 Token。首次部署先保留本机访问设置。

```sh
docker compose pull
docker compose up -d
docker compose ps
```

访问 `http://127.0.0.1:59189/admin` 初始化管理员密码。默认用户名为 `admin`，可通过 `MEDIADOCK_ADMIN_USERNAME` 修改；没有通用初始密码。远程服务器可先通过 SSH 隧道初始化：

```sh
ssh -L 59189:127.0.0.1:59189 user@your-server
```

初始化完成后，填写自己的服务及凭据，再开放公网 HTTPS。默认套餐均禁用，需要核对价格、模板和交付方式后再启用。

## 公开访问

在 `.env` 设置自己的公开域名和反向代理 IP：

```dotenv
MEDIADOCK_PUBLIC_BASE_URL=https://media.example.com
MEDIADOCK_REQUIRE_HTTPS=1
MEDIADOCK_TRUSTED_PROXIES=172.18.0.1
MEDIADOCK_NEXTEMBY_URL=https://nextemby.example.com
```

以上域名和代理 IP 均为示例。填写容器实际可访问的 NextEmby 地址；代理 IP 填容器实际看到的连接来源，不要填 `*`。宿主机 Nginx 经 Docker 映射端口连接时，来源通常是 Docker 网络网关，需结合实际部署确认。

配置有效 TLS 证书，并参考 [Nginx 示例](deploy/nginx.conf.example) 配置反向代理，再执行 `docker compose up -d` 应用环境变量。

## 使用与数据

详见 [使用指南](docs/USAGE.md) 和 [配置清单](docs/CONFIGURATION.md)。首次使用请验证自己的完整测试订单，从登记、核对到发卡和领取。

- `mediadock-data` 卷保存数据库、配置和缓存。
- `mediadock-secrets` 卷保存连接凭据和卡密加密密钥。

备份与迁移必须保留两个卷，实际卷名通常带 Compose 项目前缀。不要执行 `docker compose down -v`，它会删除业务数据及密钥。不要把实例的 `.env`、凭据、订单数据库、备份或日志提交到 GitHub。

## 发行与来源

计划以容器镜像分发应用，当前发行包仅包含部署资料。本仓库不提供应用源码，也不表示镜像具有加密或防逆向能力。镜像持有人可提取分析其中的程序文件；需要保密的业务逻辑应由维护者托管。

应用包含第三方及上游代码，随发行保留其 [许可证](LICENSE) 和 [来源声明](NOTICE)。上游已有的许可权利不因源码仓库私有而取消。
