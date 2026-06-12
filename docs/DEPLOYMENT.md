# 部署说明

当前主线是 PWA 静态网页应用。部署时只需要发布 `pwa/` 目录，不需要后端服务。

## 服务器要求

- 静态文件托管即可。
- 不需要数据库。
- 不需要 Node、Java、Flutter 常驻运行。
- CPU 压力很低，计算在用户浏览器本地完成。
- 建议开启 HTTPS。

## 本地预览

```powershell
python -m http.server 4173 -d pwa
```

访问：

```text
http://localhost:4173
```

## GitHub Pages

适合开源项目演示。

1. 推送代码到 GitHub。
2. 在仓库 `Settings -> Pages` 中启用 Pages。
3. 选择部署分支。
4. 如果 GitHub Pages 不能直接选择 `pwa/`，可后续增加 GitHub Actions，把 `pwa/` 发布到 Pages。

## Cloudflare Pages / Vercel / Netlify

- Build command：留空。
- Output directory：`pwa`。

## Nginx

将 `pwa/` 文件复制到静态站点目录：

```nginx
server {
  listen 443 ssl;
  server_name your-domain.example;
  root /var/www/aluminum-profile-designer/pwa;
  index index.html;
}
```
