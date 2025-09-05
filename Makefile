.PHONY: lint tf-init tf-fmt tf-validate clean

lint:
	@echo "Running ruff and shellcheck..."
	@ruff check .
	@find . -type f -name "*.sh" -print0 | xargs -0 -r shellcheck

TF_DIRS := $(shell find . -type f -name "*.tf" -printf '%h\n' | sort -u)

tf-init:
	@for d in $(TF_DIRS); do \
		echo "terraform init ($$d)"; \
		terraform -chdir=$$d init -backend=false -input=false -no-color; \
	done

tf-fmt:
	@for d in $(TF_DIRS); do \
		echo "terraform fmt -check ($$d)"; \
		terraform -chdir=$$d fmt -check -no-color; \
	done

tf-validate: tf-init
	@for d in $(TF_DIRS); do \
		echo "terraform validate ($$d)"; \
		terraform -chdir=$$d validate -no-color; \
	done

clean:
	@echo "Cleaning up .terraform directories..."
	@find . -type d -name ".terraform" -exec rm -rf {} +
	@find . -type f -name ".terraform"* -exec rm -f {} +
	@echo "Cleanup complete."
