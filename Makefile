SHELL := /bin/bash
.DEFAULT_GOAL := help

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m

.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make $(BLUE)<target>$(NC)\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(BLUE)%-20s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: validate
validate: ## Validate all OpenAPI specifications
	@echo "$(BLUE)Validating OpenAPI specs...$(NC)"
	@docker run --rm -v ${PWD}:/spec \
		openapitools/openapi-generator-cli validate \
		-i /spec/user-service/openapi.yaml
	@echo "$(GREEN)All specs are valid.$(NC)"

.PHONY: docs
docs: ## Generate HTML documentation
	@echo "$(BLUE)Generating API documentation...$(NC)"
	@mkdir -p docs
	@docker run --rm -v ${PWD}:/spec \
		openapitools/openapi-generator-cli generate \
		-i /spec/user-service/openapi.yaml \
		-g html2 \
		-o /spec/docs/user-service
	@echo "$(GREEN)Docs generated: docs/user-service/index.html$(NC)"
	@open docs/user-service/index.html 2>/dev/null || echo "Open docs/user-service/index.html in browser"

.PHONY: generate-all
generate-all: ## Generate and build SDKs for all services and languages
	@echo "$(BLUE)Starting autonomous SDK generation...$(NC)"
	@chmod +x scripts/generate-all-sdks.sh
	@./scripts/generate-all-sdks.sh
	@echo "$(GREEN)All SDKs generated and built.$(NC)"

.PHONY: clean
clean: ## Remove generated files
	@echo "$(YELLOW)Cleaning generated files...$(NC)"
	@rm -rf sdks/ generated/ docs/
	@echo "$(GREEN)Cleanup complete.$(NC)"
