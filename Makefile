IMAGE      := forecast-reliability-testing
DOCKER_RUN := docker run --rm -v "$(CURDIR)":/app -w /app

.PHONY: help build lock test shell

help:  ## List targets
	@grep -E '^[a-z]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-8s %s\n", $$1, $$2}'

build:  ## Build the dev image; dependencies come from uv.lock
	docker build --target dev -t $(IMAGE):dev .

lock:  ## Re-resolve dependencies after editing pyproject.toml; rewrites uv.lock
	docker build --target base -t $(IMAGE):base .
	$(DOCKER_RUN) -u app $(IMAGE):base uv lock

test:  ## Run the smoke tests inside the container
	$(DOCKER_RUN) $(IMAGE):dev pytest tests/smoke -v -s

shell:  ## Open a bash shell inside the container
	$(DOCKER_RUN) -it $(IMAGE):dev bash
