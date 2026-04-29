# Examples 示例

呢個目錄提供幾個測試 OpenClaw Router 嘅請求 payload。

## 啟動 router

```bash
ANTHROPIC_API_KEY=sk-ant-your-key node server.js
```

或者用 Docker Compose：

```bash
docker compose up --build
```

## 測試簡單請求

```bash
bash examples/test-router.sh examples/simple-request.json
```

呢類請求通常會偏向 LIGHT 模型。

## 測試代碼請求

```bash
bash examples/test-router.sh examples/code-request.json
```

呢類請求通常會偏向 MEDIUM 或 HEAVY，視乎配置同內容複雜度。

## 測試推理請求

```bash
bash examples/test-router.sh examples/reasoning-request.json
```

呢類請求通常會偏向 HEAVY 模型。

## 查看統計

```bash
curl http://127.0.0.1:8402/stats
```

可以睇到請求總數、各層級模型分佈、估算成本同節省比例。
