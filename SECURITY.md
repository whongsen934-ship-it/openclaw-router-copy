# 安全政策

OpenClaw Router 會處理模型請求同 API Key，所以請特別注意安全配置。

## 支援版本

目前主分支 `main` 為主要維護版本。

## 敏感資料

請勿提交以下資料到 GitHub：

- Anthropic API Key
- OpenRouter API Key
- `.env` 文件
- OpenClaw 本機認證文件
- 日誌中包含嘅私密請求內容

## 建議配置

- 使用環境變量提供 `ANTHROPIC_API_KEY`
- 只喺本機 `127.0.0.1` 監聽 router 服務
- 如果部署到容器或伺服器，請使用防火牆限制訪問
- 定期檢查 `journalctl` 或 Docker logs，確認無暴露敏感內容

## 回報安全問題

如果你發現安全問題，請優先用私密渠道聯絡維護者，避免直接公開漏洞細節。

## 免責聲明

本項目按 MIT License 以「現狀」提供。使用者需要自行保護 API Key、模型請求內容及部署環境。
