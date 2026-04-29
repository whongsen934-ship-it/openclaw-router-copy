# OpenClaw Router

A local cost-optimizing model router for OpenClaw.

This project runs as a localhost proxy between OpenClaw and the Anthropic-compatible Messages API. It scores each request by complexity and routes it to the cheapest capable model tier.

> This repository is a modified copy of the MIT-licensed `iblai-openclaw-router` project. The public-facing name has been changed to `openclaw-router`, while the original MIT copyright notice is preserved in `LICENSE`.

## Features

- Local Node.js proxy for OpenClaw
- Zero runtime dependencies
- Anthropic Messages API compatible
- Supports Anthropic and OpenRouter-style endpoints
- Routes requests to LIGHT, MEDIUM, or HEAVY model tiers
- Config-driven scoring rules in `config.json`
- Hot reloads config changes
- `/health` and `/stats` endpoints
- systemd install and uninstall scripts

## How it works

```text
OpenClaw  ->  localhost:8402  ->  Anthropic / OpenRouter
              |
              v
       weighted complexity scorer
              |
              v
       LIGHT / MEDIUM / HEAVY model routing
```

The router scores recent user messages, not the large OpenClaw system prompt. This keeps routine tasks from being incorrectly routed to the most expensive model.

## Quick start

```bash
git clone https://github.com/whongsen934-ship-it/openclaw-router-copy.git router
cd router
bash scripts/install.sh
```

Then use this model in OpenClaw:

```text
openclaw-router/auto
```

## Manual run

```bash
ANTHROPIC_API_KEY=sk-ant-your-key node server.js
```

Default port:

```text
http://127.0.0.1:8402
```

Health check:

```bash
curl http://127.0.0.1:8402/health
```

Stats:

```bash
curl http://127.0.0.1:8402/stats
```

## OpenClaw provider config

```text
/config set models.providers.openclaw-router.baseUrl http://127.0.0.1:8402
/config set models.providers.openclaw-router.api anthropic-messages
/config set models.providers.openclaw-router.apiKey passthrough
/config set models.providers.openclaw-router.models [{"id":"auto","name":"OpenClaw Router (auto)","reasoning":true,"input":["text","image"],"contextWindow":200000,"maxTokens":8192}]
```

Restart OpenClaw after registering the provider.

## Customize models

Edit `config.json`:

```json
{
  "models": {
    "LIGHT": "claude-4-5-haiku-20241022",
    "MEDIUM": "claude-sonnet-4-6",
    "HEAVY": "claude-opus-4-6"
  }
}
```

## Uninstall

```bash
bash scripts/uninstall.sh
```

## License

MIT. Original copyright notice is preserved in `LICENSE`.
