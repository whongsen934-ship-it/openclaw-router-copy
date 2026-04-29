# 疑難排解

呢份文件整理 OpenClaw Router 常見問題同處理方法。

## 1. 服務無法啟動

先檢查 Node.js：

```bash
node -v
```

再檢查語法：

```bash
node --check server.js
```

如果使用 systemd：

```bash
systemctl status openclaw-router
journalctl -u openclaw-router -n 50
```

## 2. 提示 ANTHROPIC_API_KEY not set

代表未配置 API Key。

臨時運行：

```bash
ANTHROPIC_API_KEY=sk-ant-your-key node server.js
```

systemd 方式：

```bash
sudo systemctl edit openclaw-router
```

加入：

```ini
[Service]
Environment=ANTHROPIC_API_KEY=sk-ant-your-key
```

然後重啟：

```bash
sudo systemctl daemon-reload
sudo systemctl restart openclaw-router
```

## 3. health 接口無回應

```bash
curl http://127.0.0.1:8402/health
```

如果無回應，檢查：

- 服務是否已啟動
- 端口是否被佔用
- `ROUTER_PORT` 是否改過
- 防火牆是否阻擋本機訪問

## 4. OpenClaw 顯示 model not allowed

通常係 OpenClaw 未重新載入模型配置。

請重啟 OpenClaw：

```bash
openclaw gateway restart
```

或者喺 OpenClaw 入面重新載入配置：

```text
/config reload
```

如果你有 model allowlist，請確認包含：

```text
openclaw-router/auto
```

## 5. 路由統計一直為 0

確認 OpenClaw provider 指向正確地址：

```text
http://127.0.0.1:8402
```

再查看 stats：

```bash
curl http://127.0.0.1:8402/stats
```

如果 total 仍然係 0，代表請求可能未經過 router。

## 6. OpenRouter 無法使用

如果你使用 OpenRouter，請確認：

- `ANTHROPIC_API_KEY` 實際填入 OpenRouter Key
- `config.json` 有配置 `apiBaseUrl`
- model ID 使用 OpenRouter 格式，例如 `openai/gpt-4.1-mini`

## 7. 配置修改無生效

`config.json` 支援熱更新，通常 2 秒內會重新載入。

如果改咗環境變量，例如 `ANTHROPIC_API_KEY` 或 `ROUTER_PORT`，需要重啟服務：

```bash
sudo systemctl restart openclaw-router
```
