# OpenClaw Router

OpenClaw Router 係一個喺本機運行嘅模型路由器，用嚟幫 OpenClaw 自動選擇成本更低、但能力足夠嘅模型。

呢個項目會作為 localhost 代理服務，放喺 OpenClaw 同 Anthropic-compatible Messages API 之間。每次請求進入 router 之後，系統會根據任務複雜度評分，然後自動路由到 LIGHT、MEDIUM 或 HEAVY 模型層級。

> 本倉庫係基於 MIT License 項目 `iblai-openclaw-router` 修改而成。公開項目名稱已改為 `openclaw-router`，但原始 MIT 版權聲明已按授權要求保留喺 `LICENSE` 入面。

## 功能特點

- 本機 Node.js 代理服務，適合 OpenClaw 使用
- 零運行依賴，只使用 Node.js 標準庫
- 兼容 Anthropic Messages API
- 支援 Anthropic 及 OpenRouter 類型接口
- 根據請求複雜度自動路由到 LIGHT、MEDIUM、HEAVY 模型
- 評分規則集中喺 `config.json`，方便自訂
- 支援配置熱更新，修改配置後無需重啟服務
- 提供 `/health` 健康檢查接口
- 提供 `/stats` 成本及路由統計接口
- 提供 systemd 安裝及卸載腳本

## 工作原理

```text
OpenClaw  ->  localhost:8402  ->  Anthropic / OpenRouter
              |
              v
       加權複雜度評分器
              |
              v
       LIGHT / MEDIUM / HEAVY 模型路由
```

Router 主要評估最近幾條用戶消息，而唔會直接評估 OpenClaw 龐大嘅 system prompt。咁做可以避免普通任務被誤判成高複雜度任務，從而減少不必要嘅高價模型調用。

## 快速開始

```bash
git clone https://github.com/whongsen934-ship-it/openclaw-router-copy.git router
cd router
bash scripts/install.sh
```

安裝完成之後，可以喺 OpenClaw 入面使用以下模型：

```text
openclaw-router/auto
```

## 手動運行

```bash
ANTHROPIC_API_KEY=sk-ant-your-key node server.js
```

預設端口：

```text
http://127.0.0.1:8402
```

健康檢查：

```bash
curl http://127.0.0.1:8402/health
```

查看統計：

```bash
curl http://127.0.0.1:8402/stats
```

## OpenClaw 模型提供者配置

喺 OpenClaw session 入面執行以下配置：

```text
/config set models.providers.openclaw-router.baseUrl http://127.0.0.1:8402
/config set models.providers.openclaw-router.api anthropic-messages
/config set models.providers.openclaw-router.apiKey passthrough
/config set models.providers.openclaw-router.models [{"id":"auto","name":"OpenClaw Router (auto)","reasoning":true,"input":["text","image"],"contextWindow":200000,"maxTokens":8192}]
```

完成配置之後，請重啟 OpenClaw，等新模型提供者生效。

## 自訂模型

修改 `config.json`：

```json
{
  "models": {
    "LIGHT": "claude-4-5-haiku-20241022",
    "MEDIUM": "claude-sonnet-4-6",
    "HEAVY": "claude-opus-4-6"
  }
}
```

你亦可以將模型改成 OpenRouter 上嘅模型 ID，只要目標接口兼容 Anthropic Messages API 格式即可。

## 自訂評分規則

`config.json` 入面包含 token 數量、代碼關鍵詞、推理關鍵詞、技術詞、多步驟任務、輸出格式等評分維度。你可以根據自己嘅 OpenClaw 使用場景調整：

- `simpleKeywords`：普通查詢、狀態檢查、通知類任務，會偏向 LIGHT
- `technicalKeywords`：技術、部署、架構、數據處理類任務，會偏向 MEDIUM 或 HEAVY
- `reasoningKeywords`：深度分析、推理、權衡類任務，會偏向 HEAVY
- `agenticKeywords`：需要 Agent 多步操作嘅任務，會提高模型層級
- `boundaries`：控制 LIGHT / MEDIUM / HEAVY 分界線
- `confidenceThreshold`：控制低信心判斷時是否回退到 MEDIUM

## 成本統計

Router 會記錄請求數、各模型層級分佈、估算成本及基準成本。可以透過以下接口查看：

```bash
curl http://127.0.0.1:8402/stats
```

返回內容會包含 `total`、`byTier`、`estimatedCost`、`baselineCost` 同 `savings` 等字段，用嚟觀察路由後節省咗幾多模型成本。

## 卸載

```bash
bash scripts/uninstall.sh
```

卸載後建議重啟 OpenClaw，並確認冇有 cron job 或 subagent 繼續使用 `openclaw-router/auto`。

## 授權

本項目使用 MIT License。原始版權聲明已保留喺 `LICENSE` 文件中。
