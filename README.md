# OpenClaw Router

OpenClaw Router 係一個喺本機運行嘅 OpenClaw 模型路由器，目標係喺唔改變原有 OpenClaw 使用方式嘅前提下，幫每一次模型請求自動選擇「夠用而且更低成本」嘅模型。佢會放喺 OpenClaw 同 Anthropic-compatible Messages API 之間，作為一個 localhost proxy 接收請求、評估任務複雜度、替換模型字段，然後再轉發到 Anthropic 或 OpenRouter 等上游模型服務。

對於實驗室、數據監測、定時告警、Git 倉庫維護同多 Agent 自動化任務嚟講，唔係每個請求都需要最高級模型。好多任務其實只係狀態檢查、日誌摘要、簡單轉發、通知生成或者格式整理；只有少部分任務需要深度推理、架構分析、複雜代碼修復或者大上下文處理。OpenClaw Router 就係為咗將呢兩類任務分開，避免所有請求都打到最貴模型，從而降低長期運行成本。

> 本倉庫係基於 MIT License 項目 `iblai-openclaw-router` 修改而成。公開項目名稱已改為 `openclaw-router`，但原始 MIT 版權聲明已按授權要求保留喺 `LICENSE` 入面。

## 核心價值

- **本機代理**：服務預設只喺 `127.0.0.1:8402` 運行，OpenClaw 請求先進入本機 router，再由 router 轉發到你自己配置嘅模型供應商。
- **成本優化**：根據任務複雜度將請求分成 LIGHT、MEDIUM、HEAVY 三個層級，簡單任務走低成本模型，複雜任務先走高能力模型。
- **低侵入接入**：OpenClaw 只需要新增一個模型 provider，之後就可以使用 `openclaw-router/auto`。
- **配置驅動**：模型、成本、關鍵詞、分數權重、分界線全部集中喺 `config.json`，唔需要改主程序。
- **適合長期任務**：特別適合 cron jobs、subagents、實驗室數據監測、告警檢查、Git issue triage、日誌分析等高頻但唔一定高難度嘅任務。

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
- 提供 systemd、Docker、Docker Compose 多種部署方式
- 提供 examples 測試 payload，方便快速驗證

## 工作原理

```text
OpenClaw  ->  localhost:8402  ->  Anthropic / OpenRouter
              |
              v
       14 維加權複雜度評分器
              |
              v
       LIGHT / MEDIUM / HEAVY 模型路由
              |
              v
       替換請求 model 字段並轉發
```

Router 主要評估最近幾條用戶消息，而唔會直接評估 OpenClaw 龐大嘅 system prompt。咁做好重要，因為 OpenClaw 嘅 system prompt 通常又長又包含好多工具、規則同技術詞，如果直接納入評分，普通任務都可能被誤判成 HEAVY，導致成本失控。

評分器會綜合多個維度，例如 token 數量、代碼特徵、推理關鍵詞、技術術語、多步驟任務、問題數量、命令式動詞、約束條件、輸出格式、領域詞、Agent 任務特徵同轉發類特徵。最後會將加權分數映射到三個模型層級：

| 層級 | 適合任務 | 例子 |
|---|---|---|
| LIGHT | 簡單、短、低推理任務 | 狀態檢查、簡單摘要、通知、轉發、問候 |
| MEDIUM | 一般結構化任務 | issue 整理、配置生成、普通代碼、文檔更新 |
| HEAVY | 高推理或大上下文任務 | 根因分析、架構設計、複雜 debug、策略分析 |

當請求包含多個推理關鍵詞、超大上下文，或者信心不足時，router 會使用保守策略，將任務升級到更穩妥嘅模型層級。

## 適合場景

### 實驗室數據監測

可以用 OpenClaw cron job 定期檢查數據源、日誌、報告文件或者 Git 倉庫狀態。簡單心跳檢查、缺失字段檢查、日誌摘要會走 LIGHT；異常原因分析、監測規則設計、指標變化解釋會走 MEDIUM 或 HEAVY。

### Git 項目維護

適合用於 issue triage、PR 摘要、README 更新、配置檢查、變更日誌生成等任務。普通整理工作唔需要每次都用最高級模型，但深度代碼審查可以自動升級。

### Agent 後台任務

subagent、cron job、通知、收件箱檢查等高頻任務，長期累積會產生可觀模型成本。Router 可以將呢啲日常任務分流到更低成本模型。

### 多模型供應商實驗

如果你使用 OpenRouter，可以將 LIGHT / MEDIUM / HEAVY 指向唔同供應商模型，例如低成本 Gemini、Claude Sonnet、OpenAI reasoning model 等，用同一套路由邏輯做混合模型調度。

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

## Docker Compose 運行

```bash
cp .env.example .env
# 修改 .env 入面嘅 ANTHROPIC_API_KEY
docker compose up --build -d
```

查看日誌：

```bash
docker logs -f openclaw-router
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
- `relayKeywords`：轉發、通知、收件箱、日程、簡單狀態類任務，會偏向 LIGHT
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

需要注意：成本統計係根據輸入文本估算，主要用嚟觀察趨勢同對比基準。實際帳單仍然應以 Anthropic、OpenRouter 或其他模型供應商後台為準。

## 測試示例

```bash
bash examples/test-router.sh examples/simple-request.json
bash examples/test-router.sh examples/code-request.json
bash examples/test-router.sh examples/reasoning-request.json
```

你可以通過 router 日誌觀察請求被分配到 LIGHT、MEDIUM 定 HEAVY。

## 項目結構

```text
server.js                         Router 主程序
config.json                       模型、成本、評分規則配置
scripts/install.sh                systemd 安裝腳本
scripts/uninstall.sh              卸載腳本
examples/                         測試請求示例
docs/                             中文香港文檔
.github/workflows/ci.yml          GitHub Actions 語法檢查
Dockerfile                        Docker 鏡像配置
docker-compose.yml                Docker Compose 配置
```

## 卸載

```bash
bash scripts/uninstall.sh
```

卸載後建議重啟 OpenClaw，並確認冇有 cron job 或 subagent 繼續使用 `openclaw-router/auto`。

## 授權

本項目使用 MIT License。原始版權聲明已保留喺 `LICENSE` 文件中。
