# Auto OS — Autos

**Android-first, provider-agnostic personal AI operating layer.** One repository for the Jarvis assistant, local inference, agent tooling, phone automation, and Open-Mine interface.

> Status: **integration blueprint / work in progress**. Gemma local inference and its OpenAI-compatible endpoint have been demonstrated on a Samsung Galaxy S24 Ultra. NullClaw agent tool execution, ARTEMIS device automation, voice workflow, and end-to-end integration are **not yet verified**. This repository documents the actual state; it does not claim a finished product.

**Latest checkpoint (2026-10-20):** ARTEMIS setup completed and OpenRouter was configured, but Wi-Fi-dependent wireless debugging, ADB pairing, and first UI action are pending. See [installation status](docs/STATUS.md).\n\n## Vision

Speak or type a command → interpret intent → select an authorized tool → perform the action → verify the outcome → respond. Support local, cloud, and hybrid inference with configurable privacy, cost, latency, and clear user control.

```text
Voice / Text / Open-Mine UI
             |
        Auto OS router
             |
     Model provider adapter
       /            \
 Local runtimes   Cloud APIs
 llama.cpp etc.  OpenAI, Anthropic, Google,
                 xAI, OpenRouter, and
                 compatible endpoints
       \            /
       Reasoning / vision / speech
             |
    Tool orchestration / permissions
         /               \
     NullClaw           ARTEMIS
     Files/shell        Phone UI/ADB
         \               /
          Verify + report
```

## What exists

| Component | Demonstrated | Outstanding |
| --- | --- | --- |
| Gemma 4 E2B Aggressive Q4_K_P | GGUF loaded with llama.cpp; `/v1/chat/completions` returned READY | Stable shell chat; speed/temperature benchmark; template warning |
| Qwen 3.5 2B / 4B | CPU generation benchmarks: 21.7 / 10.0 tok/s in earlier runs | Quality and tool-call tests |
| Qwen 2.5 Coder 3B | GGUF found in Termux | Benchmark and integration |
| NullClaw | Installed, configured for local endpoint | `ApiError`, tool-call validation, native Android build |
| ARTEMIS | Source cloned; uv dependency work performed; setup reported successful; OpenRouter configured in local `.env` | Confirm runtime dependencies, Wi-Fi/wireless debugging, authorized ADB connection, supported vision provider, first verified tap |
| Open-Mine | API connection and streaming response previously observed | Message-template compatibility, tool wiring, full integration |
| Jarvis voice | Design goal | Wake/press-to-talk, STT, TTS, permissions, interruption |

## Phone-first quick start

Prerequisites: Termux, `llama-cpp`, `curl`, and a **separately downloaded** compatible GGUF at `~/models/gemma4/Gemma-4-E2B-Uncensored-HauhauCS-Aggressive-Q4_K_P.gguf`.

```bash
pkg install -y llama-cpp curl
git clone https://github.com/ether4o4/Autos.git ~/Autos
cd ~/Autos
bash scripts/install-termux-shortcuts.sh
```

Termux session 1: `llama-serve`  
Termux session 2: `gemma-gateway`

`gemma-gateway` is **direct llama.cpp chat**, not NullClaw. Both scripts use localhost without an API key for compatibility with `llama-cli --server-base`. Do not expose port 8080 to other network interfaces. Use Ctrl+C to stop the server; if port 8080 is occupied, inspect the existing process before restarting.

For a no-server baseline:
```bash
llama-cli -m ~/models/gemma4/Gemma-4-E2B-Uncensored-HauhauCS-Aggressive-Q4_K_P.gguf -c 4096 -t 4 -n 512
```

## Architecture and responsibilities

- **Auto OS router:** intent classification, model/tool selection, explicit confirmation for risky actions, retries, task state, and audit trail. Not implemented.
- **Model provider adapter:** user-selectable local or hosted models, with task-based routing and fallback. Support OpenAI, Anthropic, Google Gemini, xAI Grok, OpenRouter, and custom OpenAI-compatible endpoints; add other providers through adapters. Availability and specific model features depend on each provider's API. No single model is the permanent core.\n- **Local inference:** llama.cpp/GGUF (Gemma, Qwen, and other compatible models), plus future optional local runtimes. A model does not automatically have file or device access.\n- **Cloud and hybrid inference:** configurable API credentials, model selection, privacy policy, budget limits, vision and speech capabilities, and local-first/cloud-fallback routing. Credentials remain on device, never in the repository.
- **NullClaw:** optional tool-execution layer for files and shell, isolated workspace, tool permissions. Must prove a write/read round trip before integration.
- **ARTEMIS:** Google mobile automation framework; Flash reactive loop and Pro plan/verify loop. Requires a working ADB/control path and compatible visual perception; a text-only GGUF alone cannot interpret screenshots.
- **Open-Mine:** future UI, knowledge and memory library, model configuration, and task console.
- **Voice:** microphone → speech-to-text → router → action → text-to-speech, with permission boundaries.

## Acceptance tests (do not mark complete without evidence)

1. **Inference:** server health and authenticated/unauthed policy match; model answers; latency measured.
2. **Chat:** two-session launch works after Termux restart; no NullClaw dependency.
3. **NullClaw:** file written and read back through actual tools; API and context errors resolved.
4. **ARTEMIS:** ADB device listed as authorized; UI observed; harmless action performed and verified.
5. **Router:** tool chosen appropriately; failed action reported; destructive operations require confirmation.
6. **Voice:** user speech triggers verified action and spoken completion.
7. **Open-Mine:** UI invokes same backend and displays results without prompt-template errors.

## Known issues and decisions

- NullClaw previously returned `ApiError` and `ContextLengthExceeded`; a manual `curl` response of 200 does not prove the agent path works.
- Gemma's older GGUF chat template caused compatibility warnings; llama.cpp applied a workaround.
- ARTEMIS ADB daemon failed to connect to TCP 5037 during initial Termux setup. By October 20 setup reported success, but Wi-Fi was unavailable for wireless debugging; ADB and UI control remain unverified.
- A prior Zig-based NullClaw rebuild failed due to a Linux-musl vs Android target mismatch. Avoid running opaque repair payloads.
- A server `-c 8192` rejected requests exceeding 8,900 tokens; `-c 16384` was subsequently used, but memory and tool overhead still need testing.
- Do not commit GGUF weights, API keys, Telegram tokens, device IDs, private memory, or logs with secrets.

## Repository plan

```text
scripts/                 Termux setup and launch
docs/ARCHITECTURE.md     Milestones, boundaries, and integration contracts
.gitignore              Exclude local models, credentials, logs
README.md               Blueprint and current status
```

**Next integration order:** reliable provider-selectable chat (local and cloud) → NullClaw tools → ARTEMIS device action → router → voice → Open-Mine UI. Keep every milestone testable before adding the next.

## Provider selection (planned)

| Provider | Connection | Notes |
| --- | --- | --- |
| Local llama.cpp | Local OpenAI-compatible endpoint | GGUF models, offline use |
| OpenAI | Official API | Text, tools, and eligible multimodal models |
| Anthropic | Official API | Text and tool-use models |
| Google Gemini | Gemini API | Text and eligible multimodal models |
| xAI Grok | xAI API | Provider-specific models and features |
| OpenRouter | OpenRouter API | Routes across supported hosted models |
| Custom | OpenAI-compatible base URL | Self-hosted or third-party services |

Provider selection must be configurable per task (chat, coding, vision, voice, tool calling), with capability checks, cost and latency preferences, credential storage, fallback behavior, and explicit permission before sending private data to external services. **These adapters are a design requirement, not an implemented feature.**
