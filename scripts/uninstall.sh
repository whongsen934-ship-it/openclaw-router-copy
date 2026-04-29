#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="openclaw-router"
PROVIDER_NAME="openclaw-router"
ROUTER_DIR="$HOME/.openclaw/workspace/router"

echo "Removing openclaw-router..."

if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
  sudo systemctl stop "$SERVICE_NAME"
  echo "  ✓ Service stopped"
fi

if systemctl is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
  sudo systemctl disable "$SERVICE_NAME"
fi

if [ -f "/etc/systemd/system/$SERVICE_NAME.service" ]; then
  sudo rm "/etc/systemd/system/$SERVICE_NAME.service"
  sudo systemctl daemon-reload
  echo "  ✓ Systemd unit removed"
fi

if [ -d "$ROUTER_DIR" ]; then
  rm -rf "$ROUTER_DIR"
  echo "  ✓ Router files removed from $ROUTER_DIR"
fi

OPENCLAW_JSON="$HOME/.openclaw/openclaw.json"
if [ -f "$OPENCLAW_JSON" ] && command -v python3 &> /dev/null; then
  python3 - "$OPENCLAW_JSON" "$PROVIDER_NAME" << 'PYEOF'
import json, sys

config_path, provider_name = sys.argv[1], sys.argv[2]
with open(config_path) as f:
    cfg = json.load(f)

changed = False
providers = cfg.get("models", {}).get("providers", {})
for key in [provider_name, "smart-router"]:
    if key in providers:
        del providers[key]
        changed = True
        print(f"  ✓ Removed {key} provider from openclaw.json")

if not providers and "models" in cfg:
    cfg["models"].pop("providers", None)
    if not cfg.get("models"):
        cfg.pop("models", None)

models_allowlist = cfg.get("agents", {}).get("defaults", {}).get("models", {})
for model_id in [f"{provider_name}/auto", "smart-router/auto"]:
    if model_id in models_allowlist:
        del models_allowlist[model_id]
        changed = True
        print(f"  ✓ Removed {model_id} from model allowlist")

if changed:
    with open(config_path, "w") as f:
        json.dump(cfg, f, indent=2)
        f.write("\n")
else:
    print("  ✓ openclaw.json already clean")
PYEOF
fi

MODELS_JSON="$HOME/.openclaw/agents/main/agent/models.json"
if [ -f "$MODELS_JSON" ] && command -v python3 &> /dev/null; then
  python3 - "$MODELS_JSON" "$PROVIDER_NAME" << 'PYEOF'
import json, sys

models_path, provider_name = sys.argv[1], sys.argv[2]
with open(models_path) as f:
    data = json.load(f)

changed = False
providers = data.get("providers", {})
for key in [provider_name, "smart-router"]:
    if key in providers:
        del providers[key]
        changed = True

if changed:
    with open(models_path, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
    print("  ✓ Cleaned up cached models.json")
PYEOF
fi

echo ""
echo "  ⚠ Restart OpenClaw to apply changes:"
echo "    openclaw gateway restart"
echo ""
echo "  If any cron jobs or subagents used openclaw-router/auto, switch them to a direct model."
echo ""
echo "Done."
