# Local coder

A local coding model on this Mac: an Apple M5 Pro with 48 GB of unified memory and 307 GB/s of memory bandwidth.

The default model is **[Qwen3-Coder-30B-A3B-Instruct](https://huggingface.co/Qwen/Qwen3-Coder-30B-A3B-Instruct)** at 4-bit, served by [Ollama](https://ollama.com/). The tag [`qwen3-coder:30b`](https://ollama.com/library/qwen3-coder:30b) is the Q4_K_M quant, about 19 GB. It is a mixture of experts: 30.5B parameters resident, 3.3B active on each token. There is no 32B-A3B tag. The dense 32B in the Qwen3 family is [`qwen3:32b`](https://ollama.com/library/qwen3:32b), a general model, not this coder.

Quit Docker before loading a model. Docker's 16 GB reservation comes out of the same 48 GB. macOS lives in that memory too, so a weight file near 40 GB is the edge, and a file past 48 GB does not fit.

## Plan

1. Install Ollama and the Goose CLI with `make prereqs`. That is `block-goose-cli`, the compiled binary, not the desktop app.
2. Start the tuned Ollama server with `make serve`. It sets a 64K context, flash attention, and a q8 KV cache so the context fits next to a 19 GB weight file. Goose sends its tool list on every turn, and a short context truncates that list. The model then cannot see its tools. [This setup guide](https://aifoss.dev/blog/goose-ollama-self-hosted-setup-guide-2026/) is the write-up of that failure.
3. In another terminal, `make chat`. This pulls the model on first run and opens a plain chat. Use it to check speed and whether the answers are good enough before the agent is in the loop.
4. `make session` opens Goose on the same model (`GOOSE_PROVIDER=ollama`, `GOOSE_MODEL=qwen3-coder:30b`). [Ollama's own Goose page](https://docs.ollama.com/integrations/goose) is the same wiring.
5. Try one small, reviewable change. If the model edits the wrong files or forgets the middle of a long task, lower the context or split the task. To try a different model, pass `MODEL`:

```bash
make chat MODEL=devstral:24b
make session MODEL=qwen2.5-coder:32b
```

## Models

Sizes are the Ollama download. A dense model rereads the whole file for every token, so a 20 GB file is about 15 tokens per second on this machine and a 40 GB file is about half that. The default model keeps 19 GB resident and only reads the active experts, so it is faster than the dense 32B.

| Preference | Tag | Download | Notes |
|---|---|---|---|
| Goose, the default | `qwen3-coder:30b` | 19 GB | 30.5B total, 3.3B active. Long tool lists come out as XML, which Goose parses. |
| Dense code, one reply | `qwen2.5-coder:32b` | 20 GB | All 32B parameters active. Stronger single answers, about 15 tokens per second. Tool calls come out as bare JSON, which Goose prints and does not run. |
| Same coder, use the spare RAM | `qwen2.5-coder:32b-instruct-q8_0` | 35 GB | Closer to the original weights. Slower. Same bare-JSON tool calls. Fits if Docker is quit. |
| Faster, still a coder | `qwen2.5-coder:14b` | 9 GB | Dense 14B. Leaves a long context next to the weights. Weaker on hard code than the 32B. |
| Dense agent | `devstral:24b` | 14 GB | Built to use tools and edit a repo. Apache 2.0. 128K context. |
| Many languages | `codestral:22b` | 13 GB | 22B, fill-in-the-middle, 80+ languages. The license is not Apache. Read it before using the output at work. |
| Python only | `codellama:34b-python` | 19 GB | 2023 fine-tune on an extra 100B tokens of Python. Same download as the dense 32B coder, and weaker at Python than that coder. |
| Biggest file that can load | `llama3.3:70b` | 43 GB | Dense 70B, general model, about 8 tokens per second. Loads only with Docker quit and a short context. |
| Does not fit | `qwen3-coder-next` | 52 GB | 80B total, 3B active. The 4-bit file is larger than this Mac. The 2-bit and 3-bit files fit and are the low-quality quants. |

There is no current Go-only model at this size. Go is already in the training mix of `qwen2.5-coder` and `codestral`. A language-only model is not faster unless it has fewer parameters, and the Python-only tag above is the same 19 GB as a general coder from two years later. For Python or Go on a speed budget, `qwen2.5-coder:14b` is the efficient pull. For a hard problem in either language, use the 32B coder or the default.

## Why Goose

The CLI is Rust. `brew install block-goose-cli` installs that binary. There is no Node, Bun, or Python runtime in the agent process, so the resident set stays with the weights and the KV cache instead of a second language runtime. [One comparison](https://terminalblog.com/blog/goose-rust-agent-why-it-matters/) measured about 45 MB for Goose against about 280 MB for the Node-based Claude Code CLI. Those are that author's numbers, and they are the same kind of gap as a 30 MB static binary against a 200–300 MB JavaScript runtime.

[Block gave the project to the Agentic AI Foundation](https://aaif.io/blog/running-goose-fully-offline-on-a-dgx-spark) at the Linux Foundation in April 2026, in the same gift as MCP and AGENTS.md. The agent loop, the file edits, and the shell can run with nothing leaving the machine. The repo is [aaif-goose/goose](https://github.com/aaif-goose/goose), Apache 2.0.

The Ollama provider is written for this class of model. With a long tool list, Qwen3-Coder prints tool calls as XML. Goose's provider [parses that XML](https://github.com/aaif-goose/goose/commit/584f710fadcb0dd4243c9131e73aacbe6f0c5573) instead of dropping the turn. Qwen2.5-Coder prints the same call as bare JSON, which Goose shows and does not run. A [local-agent review](https://stackbrief.dev/article/goose-review) makes the other half of the case: the model is yours, including an Ollama model, and a provider change is a config change.

## Documentation

For more information about extending Goose capabilities, see:
- [Goose Extensions and Custom MCP Packages](docs/goose-extensions.md)
- [Security Considerations](docs/security-considerations.md)

## Rules and Guidelines

Goose can be configured with safety rules and coding standards to ensure responsible behavior. Example rule files are provided in the `rules/` directory:

- [Example Coding Rules](rules/example-coding-rules.md) - General coding standards and guidelines
- [Safety Rules](rules/safety-rules.md) - System integrity and operational safety constraints

These rules help establish boundaries for Goose's behavior and ensure consistent, safe operation.

## Environment Configuration

To enable additional capabilities like web search:
1. Create a `.env` file from the example: `cp .env.example .env`
2. Configure your environment variables in the `.env` file
3. Restart Goose for changes to take effect

## Sources

- [Qwen3-Coder-30B-A3B-Instruct](https://huggingface.co/Qwen/Qwen3-Coder-30B-A3B-Instruct) — model card for the default
- [qwen3-coder:30b](https://ollama.com/library/qwen3-coder:30b) — the Ollama quant this makefile pulls
- [Qwen2.5-Coder-32B-Instruct](https://huggingface.co/Qwen/Qwen2.5-Coder-32B-Instruct) — the dense coder
- [Devstral](https://ollama.com/library/devstral) — the dense agent
- [Code Llama](https://ollama.com/library/codellama:python) — the Python-only fine-tune
- [Ollama](https://github.com/ollama/ollama) — server
- [Goose](https://github.com/aaif-goose/goose) — harness, Rust CLI
- [Install the CLI](https://goose-docs.ai/docs/getting-started/installation) — `brew install block-goose-cli`
- [Ollama and Goose](https://docs.ollama.com/integrations/goose) — provider setup
- [Fully offline on your own machine](https://aaif.io/blog/running-goose-fully-offline-on-a-dgx-spark) — Linux Foundation write-up
- [Self-hosted Goose and Ollama](https://aifoss.dev/blog/goose-ollama-self-hosted-setup-guide-2026/) — context window, or the tools never arrive
- [Why the Rust agent](https://terminalblog.com/blog/goose-rust-agent-why-it-matters/) — startup and memory comparison
- [Goose review](https://stackbrief.dev/article/goose-review) — bring-your-own-model, local path

## Commands

```bash
make prereqs
make serve          # background; make stop to quit
make stop
make chat           # second terminal, model only
make session        # second terminal, Goose on that model
make session MODEL=devstral:24b
```

## Using Goose with Other Repositories

By default, `make session` will run Goose within this repository. To use Goose with other repositories:

### Option 1: Path Argument (Recommended for One-off Use)
```bash
# Set workspace path for a single session
make session WORKSPACE_PATH=/path/to/your/repo

# Or set MODEL and WORKSPACE together
make session MODEL=qwen2.5-coder:32b WORKSPACE_PATH=/path/to/your/repo
```

### Option 2: Persistent Configuration via `make setup-shell`
`make setup-shell` appends this to `~/.zshrc`. Goose reads the provider and model from the environment. A new session uses the process working directory, so the function enters `GOOSE_WORKING_DIR` before launching `goose`.

```bash
# Goose default settings
export GOOSE_PROVIDER="ollama"
export GOOSE_MODEL="qwen3-coder:30b"
export GOOSE_WORKING_DIR="/path/to/your/repo"
goose() { (cd "$GOOSE_WORKING_DIR" && command goose "$@"); }
```

Open a new terminal, then run `goose` from any directory. `command goose` stays in the current directory.

### Option 3: Create a Local Makefile
Create a `Makefile` in your target repository that includes:
```makefile
# Include this repo's makefile for reuse
include /path/to/local-coder/Makefile

# Set specific defaults for this repository
WORKSPACE_PATH ?= $(shell pwd)
```

This allows you to leverage the local-coder setup while working from any directory.
