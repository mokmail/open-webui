
ifneq ($(shell which docker-compose 2>/dev/null),)
    DOCKER_COMPOSE := docker-compose
else
    DOCKER_COMPOSE := docker compose
endif

# Compose files / service names used by the rebrand stack
REBRAND_FILE    := docker-compose.rebrand.yaml
REBRAND_COMPOSE := $(DOCKER_COMPOSE) -f $(REBRAND_FILE)
OIKB_CONTAINER  := oikb-rebrand

install:
	$(DOCKER_COMPOSE) up -d

remove:
	@chmod +x confirm_remove.sh
	@./confirm_remove.sh

start:
	$(DOCKER_COMPOSE) start
startAndBuild: 
	$(DOCKER_COMPOSE) up -d --build

stop:
	$(DOCKER_COMPOSE) stop

update:
	# Calls the LLM update script
	chmod +x update_ollama_models.sh
	@./update_ollama_models.sh
	@git pull
	$(DOCKER_COMPOSE) down
	# Make sure the ollama-webui container is stopped before rebuilding
	@docker stop open-webui || true
	$(DOCKER_COMPOSE) up --build -d
	$(DOCKER_COMPOSE) start

# ---------------------------------------------------------------------------
# Rebrand stack (open-webui-rebrand + oikb daemon)
# ---------------------------------------------------------------------------
rebrand-start:
	$(REBRAND_COMPOSE) up -d

rebrand-build:
	$(REBRAND_COMPOSE) up -d --build

rebrand-stop:
	$(REBRAND_COMPOSE) stop

rebrand-restart:
	$(REBRAND_COMPOSE) restart

rebrand-down:
	$(REBRAND_COMPOSE) down

rebrand-logs:
	$(REBRAND_COMPOSE) logs -f

rebrand-status:
	$(REBRAND_COMPOSE) ps

# ---------------------------------------------------------------------------
# oikb — sync the knowledge bases defined in ./.oikb.yaml
# The oikb service must be running first (see rebrand-start).
# ---------------------------------------------------------------------------
# Read the Open WebUI API key from .env so docker exec invocations authenticate.
OIKB_API_KEY := $(shell grep -E '^OPEN_WEBUI_API_KEY=' .env 2>/dev/null | cut -d= -f2- | tr -d "'\"")

oikb-sync:
	@echo "Syncing all sources from .oikb.yaml ..."
	@docker exec -e OPEN_WEBUI_URL=http://open-webui-rebrand:8080 \
		-e OPEN_WEBUI_API_KEY=$(OIKB_API_KEY) \
		$(OIKB_CONTAINER) oikb sync

oikb-sync-source:
	@if [ -z "$(source)" ]; then echo "Usage: make oikb-sync-source source=<name>"; exit 1; fi
	@echo "Syncing source '$(source)' ..."
	@docker exec -e OPEN_WEBUI_URL=http://open-webui-rebrand:8080 \
		-e OPEN_WEBUI_API_KEY=$(OIKB_API_KEY) \
		$(OIKB_CONTAINER) oikb sync --name $(source)

oikb-diff:
	@echo "Previewing changes for all sources (dry-run) ..."
	@docker exec -e OPEN_WEBUI_URL=http://open-webui-rebrand:8080 \
		-e OPEN_WEBUI_API_KEY=$(OIKB_API_KEY) \
		$(OIKB_CONTAINER) oikb sync --dry-run

oikb-validate:
	@docker exec $(OIKB_CONTAINER) oikb validate

oikb-history:
	@docker exec $(OIKB_CONTAINER) oikb history

oikb-ls:
	@docker exec $(OIKB_CONTAINER) oikb ls

oikb-logs:
	@docker logs -f $(OIKB_CONTAINER)

.PHONY: install remove start startAndBuild stop update \
        rebrand-start rebrand-build rebrand-stop rebrand-restart rebrand-down rebrand-logs rebrand-status \
        oikb-sync oikb-sync-source oikb-diff oikb-validate oikb-history oikb-ls oikb-logs

