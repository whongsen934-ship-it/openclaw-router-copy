# OpenClaw Router 中文香港說明

OpenClaw Router 係一個本機模型路由服務，主要用途係幫 OpenClaw 根據任務複雜度，自動選擇更合適、更慳成本嘅模型。

## 適合場景

- 實驗室數據監測
- Cron 定時任務
- 子 Agent 任務
- Git 倉庫維護
- 日誌摘要
- 告警檢查
- 代碼分析及修復

## 基本流程

```text
OpenClaw 請求
  -> 本機 Router 8402 端口
  -> 複雜度評分
  -> 選擇 LIGHT / MEDIUM / HEAVY 模型
  -> 轉發到 Anthropic 或 OpenRouter
```

## 安裝

```bash
git clone https://github.com/whongsen934-ship-it/openclaw-router-copy.git router
cd router
bash scripts/install.sh
```

## 使用

```text
/model openclaw-router/auto
```

## 查看狀態

```bash
curl http://127.0.0.1:8402/health
```

## 查看成本統計

```bash
curl http://127.0.0.1:8402/stats
```

## 修改模型

打開 `config.json`，修改：

```json
{
  "models": {
    "LIGHT": "claude-4-5-haiku-20241022",
    "MEDIUM": "claude-sonnet-4-6",
    "HEAVY": "claude-opus-4-6"
  }
}
```

## 卸載

```bash
bash scripts/uninstall.sh
```
