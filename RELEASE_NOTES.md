# Release Notes

## v0.1.0 - Initial Release

OpenClaw Router 第一個公開版本，提供本機模型路由、成本估算、OpenClaw provider 接入、systemd 安裝腳本、Docker 部署及中文香港文檔。

### 主要功能

- 本機 Node.js proxy，預設監聽 `127.0.0.1:8402`
- 兼容 Anthropic Messages API
- 支援 Anthropic 及 OpenRouter-style 上游接口
- 根據請求複雜度自動路由到 LIGHT / MEDIUM / HEAVY 模型層級
- `config.json` 集中管理模型、成本、關鍵詞、權重及分界線
- 支援配置熱更新，修改 `config.json` 後無需重啟
- 提供 `/health` 健康檢查接口
- 提供 `/stats` 成本統計接口
- 提供 systemd 安裝及卸載腳本
- 提供 Dockerfile 及 Docker Compose
- 提供 examples 測試請求
- 提供 GitHub Actions CI 語法檢查

### 文檔

- README.md 中文香港主說明
- docs/README.zh-HK.md 補充說明
- docs/DEPLOY.zh-HK.md 部署指南
- docs/CONFIG.zh-HK.md 配置指南
- docs/TROUBLESHOOTING.zh-HK.md 疑難排解
- CONTRIBUTING.md 貢獻指南
- SECURITY.md 安全政策
- CHANGELOG.md 更新日誌

### 使用方式

```bash
git clone https://github.com/whongsen934-ship-it/openclaw-router-copy.git router
cd router
bash scripts/install.sh
```

或直接運行：

```bash
ANTHROPIC_API_KEY=sk-ant-your-key node server.js
```

Docker Compose：

```bash
cp .env.example .env
docker compose up --build -d
```

### OpenClaw 模型 ID

```text
openclaw-router/auto
```

### License

MIT License。原始版權聲明已保留。
