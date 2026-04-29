# 部署說明

呢份文件記錄 OpenClaw Router 常見部署方式。

## 方式一：直接用 Node.js 運行

```bash
cp .env.example .env
export ANTHROPIC_API_KEY=sk-ant-your-key
node server.js
```

檢查：

```bash
curl http://127.0.0.1:8402/health
```

## 方式二：用安裝腳本部署到 systemd

```bash
bash scripts/install.sh
```

查看服務狀態：

```bash
systemctl status openclaw-router
```

查看日誌：

```bash
journalctl -u openclaw-router -f
```

重啟服務：

```bash
sudo systemctl restart openclaw-router
```

## 方式三：Docker Compose

先準備環境變量：

```bash
cp .env.example .env
```

修改 `.env` 入面嘅：

```env
ANTHROPIC_API_KEY=sk-ant-your-key
```

啟動：

```bash
docker compose up --build -d
```

查看日誌：

```bash
docker logs -f openclaw-router
```

停止：

```bash
docker compose down
```

## OpenClaw 配置

```text
/config set models.providers.openclaw-router.baseUrl http://127.0.0.1:8402
/config set models.providers.openclaw-router.api anthropic-messages
/config set models.providers.openclaw-router.apiKey passthrough
/config set models.providers.openclaw-router.models [{"id":"auto","name":"OpenClaw Router (auto)","reasoning":true,"input":["text","image"],"contextWindow":200000,"maxTokens":8192}]
```

完成之後，請重啟 OpenClaw。
