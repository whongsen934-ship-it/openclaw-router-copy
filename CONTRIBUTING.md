# 貢獻指南

多謝你有興趣參與 OpenClaw Router。呢個項目目標係保持簡潔、可本機部署、容易改配置，同時盡量減少運行依賴。

## 開發原則

- 優先保持零運行依賴
- 配置集中喺 `config.json`
- 唔好喺代碼入面硬編碼 API Key
- 所有敏感資料應該透過環境變量傳入
- 修改路由邏輯時，請同步更新 README 或 docs

## 本地開發

```bash
git clone https://github.com/whongsen934-ship-it/openclaw-router-copy.git
cd openclaw-router-copy
cp .env.example .env
npm run check
```

手動運行：

```bash
ANTHROPIC_API_KEY=sk-ant-your-key node server.js
```

## 提交 Pull Request 前

請先執行：

```bash
npm run check
```

並確認以下內容：

- `server.js` 語法無錯
- `config.json` 係有效 JSON
- README 或 docs 已更新
- 無提交 `.env`、API Key、日誌或本機配置

## Commit 建議

可以使用清晰短句：

```text
Add Docker deployment guide
Tune routing thresholds
Update Hong Kong Chinese docs
Fix OpenClaw provider registration
```

## License

提交內容會以 MIT License 發佈。原始 MIT 版權聲明需要保留。
