# 配置說明

OpenClaw Router 嘅主要配置集中喺 `config.json`。

## models

```json
{
  "models": {
    "LIGHT": "claude-4-5-haiku-20241022",
    "MEDIUM": "claude-sonnet-4-6",
    "HEAVY": "claude-opus-4-6"
  }
}
```

- `LIGHT`：適合簡單查詢、狀態檢查、通知、轉發等任務
- `MEDIUM`：適合一般代碼、配置、文件整理、Agent 任務
- `HEAVY`：適合深度推理、架構分析、疑難排錯、大上下文任務

## costs

`costs` 用於估算成本同節省比例。數值代表每 100 萬 token 成本。

```json
{
  "costs": {
    "claude-sonnet-4-6": {
      "input": 3.0,
      "output": 15.0
    }
  }
}
```

## scoring

`scoring` 係路由判斷嘅核心。

### tokenThresholds

```json
{
  "tokenThresholds": {
    "simple": 80,
    "complex": 800
  }
}
```

短請求會偏向 LIGHT，長請求會提高模型層級。

### keywords

常見關鍵詞分類：

- `simpleKeywords`：簡單任務，降低分數
- `relayKeywords`：轉發、通知、狀態類任務，降低分數
- `codeKeywords`：代碼類任務，提高分數
- `technicalKeywords`：技術及工程類任務，提高分數
- `reasoningKeywords`：推理分析類任務，大幅提高分數
- `agenticKeywords`：多步 Agent 操作，提高分數
- `formatKeywords`：要求 JSON、表格、Markdown 等格式時提高分數

### boundaries

```json
{
  "boundaries": {
    "lightMedium": 0.0,
    "mediumHeavy": 0.35
  }
}
```

- 分數低於 `lightMedium`：LIGHT
- 分數介乎兩者之間：MEDIUM
- 分數高於 `mediumHeavy`：HEAVY

## 建議調整

如果你想更慳成本，可以提高 `mediumHeavy`，令更多任務留喺 MEDIUM。

如果你想更保守、更重視效果，可以降低 `mediumHeavy`，令更多任務進入 HEAVY。

如果你主要跑數據監測、告警、日誌摘要，可以增加 `simpleKeywords` 同 `relayKeywords`。
