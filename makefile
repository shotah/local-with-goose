.PHONY: help prereqs serve serve-foreground stop model chat session setup-shell

# Other tags are in the README. Try one with: make session MODEL=devstral:24b
MODEL ?= qwen3-coder:30b
CTX ?= 65536

.DEFAULT_GOAL := help

help:
	@echo "prereqs   Install Ollama and the Goose CLI"
	@echo "serve     Start Ollama with a $(CTX) context and quantized KV cache (background by default)"
	@echo "serve-foreground  Start Ollama in foreground mode (useful for debugging)"
	@echo "stop      Stop the background Ollama server"
	@echo "model     Pull $(MODEL) (about 19 GB)"
	@echo "chat      Pull the model if needed, then open an Ollama chat"
	@echo "session   Pull the model if needed, then open a Goose session on it"
	@echo ""
	@echo "Installs the Goose CLI (block-goose-cli), not the desktop app."
	@echo "Quit Docker before serve. Its memory comes out of the same 48 GB."

prereqs:
	brew install ollama
	brew install block-goose-cli

# Run Ollama server in background by default
serve:
	OLLAMA_FLASH_ATTENTION=1 OLLAMA_KV_CACHE_TYPE=q8_0 OLLAMA_CONTEXT_LENGTH=$(CTX) \
		ollama serve &

# Run Ollama server in foreground (useful for debugging)
serve-foreground:
	OLLAMA_FLASH_ATTENTION=1 OLLAMA_KV_CACHE_TYPE=q8_0 OLLAMA_CONTEXT_LENGTH=$(CTX) \
		ollama serve

# Stop the server started by `make serve`
stop:
	@pkill -x ollama && echo "Stopped Ollama" || echo "Ollama is not running"

model:
	ollama pull $(MODEL)

chat: model
	ollama run $(MODEL)

# WORKSPACE_PATH overrides the directory saved by `make setup-shell`.
session: model
	@dir="$(WORKSPACE_PATH)"; \
	if [ -z "$$dir" ]; then dir="$${GOOSE_WORKING_DIR:-.}"; fi; \
	cd "$$dir" && GOOSE_PROVIDER=ollama GOOSE_MODEL="$(MODEL)" goose session

# Goose reads GOOSE_PROVIDER and GOOSE_MODEL from the environment.
# It starts the session in the current directory, so the shell function
# enters GOOSE_WORKING_DIR before launching goose.
setup-shell:
	@echo "Setting up default Goose environment in your shell..."
	@echo "# Goose default settings" > ~/.goose-env-temp
	@echo "export GOOSE_PROVIDER=\"ollama\"" >> ~/.goose-env-temp
	@echo "export GOOSE_MODEL=\"$(MODEL)\"" >> ~/.goose-env-temp
	@echo "export GOOSE_WORKING_DIR=\"$(shell pwd)\"" >> ~/.goose-env-temp
	@echo 'goose() { (cd "$$GOOSE_WORKING_DIR" && command goose "$$@"); }' >> ~/.goose-env-temp
	@echo "" >> ~/.goose-env-temp
	@if grep -q "# Goose default settings" ~/.zshrc; then \
		echo "Updating existing Goose configuration..."; \
		sed -i.bak '/# Goose default settings/,/^$$/d' ~/.zshrc && \
		cat ~/.goose-env-temp >> ~/.zshrc && \
		rm -f ~/.goose-env-temp; \
	else \
		echo "Adding new Goose configuration..."; \
		cat ~/.goose-env-temp >> ~/.zshrc && \
		rm -f ~/.goose-env-temp; \
	fi
	@echo ""
	@echo "Goose environment configured. Open a new terminal."
	@echo "goose from any directory uses $(MODEL) on Ollama and starts in $(shell pwd)."
	@echo "command goose stays in the current directory."
