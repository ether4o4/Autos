# Auto OS integration contract

## Design rules
1. Keep model runtime, tools, device automation, UI and voice independently replaceable.
2. Local HTTP binds to 127.0.0.1. Never expose an unauthenticated inference server on Wi-Fi.
3. All tool executions require allowlisted capabilities; request user approval for irreversible actions.
4. Tool results include status, timestamp, target, and verification evidence.
5. The router cannot claim success from a model's text alone.

## Planned modules
- `inference`: llama.cpp health, model discovery, chat and tool schema adapters.
- `agent`: NullClaw workspace, provider config, file and shell tools.
- `device`: ARTEMIS Flash/Pro driver, ADB/accessibility connection, screenshot grounding.
- `orchestrator`: intent routing, budgets, timeouts, retries, user confirmation, task journal.
- `voice`: push-to-talk, STT, TTS, interrupt/cancel.
- `ui`: Open-Mine integration.

## First end-to-end test
User requests opening a harmless app. Router obtains permission, ARTEMIS observes UI and opens app, checker verifies foreground app, assistant reports result. If observation or action fails, report failure without pretending completion.

## Milestones
- M0: reproducible Termux shortcuts and health check.
- M1: direct Gemma chat and latency benchmark.
- M2: NullClaw real file-write/read test.
- M3: ARTEMIS authorized ADB and verified UI interaction.
- M4: router linking inference and one authorized tool.
- M5: voice loop.
- M6: Open-Mine polished front end.

Status: M0 scripts authored, **not device-tested from this repository**; M1–M6 incomplete.
