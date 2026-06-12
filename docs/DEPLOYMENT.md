# 部署说明

PWA 版本完成后，部署目标是 `pwa/` 目录内的静态文件。

## 服务器要求

- 静态文件托管即可。
- 不需要数据库。
- 不需要后端常驻进程。
- CPU 压力很低，计算在用户浏览器本地完成。
- 建议开启 HTTPS。

## GitHub Pages

适合开源项目演示。

1. 将代码推送到 GitHub。
2. 在仓库 Settings -> Pages 中启用 Pages。
3. 选择部署分支和 `pwa/` 或构建输出目录。

## Cloudflare Pages / Vercel / Netlify

适合自动部署。

- 构建命令可以为空。
- 输出目录指向 `pwa/`。

## Nginx

将 `pwa/` 文件复制到静态站点目录。

```nginx
server {
  listen 443 ssl;
  server_name example.com;
  root /var/www/aluminum-profile-designer/pwa;
  index index.html;
}
```
