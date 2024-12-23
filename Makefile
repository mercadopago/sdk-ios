.PHONY: setup
setup:  check-brew install-tools setup-git-hooks

.PHONY: check-brew
check-brew:
	@which brew > /dev/null || (echo "Please install Homebrew first: https://brew.sh" && exit 1)

.PHONY: install-tools
install-tools:
	@echo "Checking SwiftFormat..."
	@if ! command -v swiftformat >/dev/null 2>&1; then \
		echo "Installing SwiftFormat..." && \
		brew install swiftformat; \
	else \
		echo "SwiftFormat already installed"; \
	fi
	@echo "Checking SwiftLint..."
	@if ! command -v swiftlint >/dev/null 2>&1; then \
		echo "Installing SwiftLint..." && \
		brew install swiftlint; \
	else \
		echo "SwiftLint already installed"; \
	fi

.PHONY: setup-git-hooks
setup-git-hooks:
	mkdir -p .git/hooks
	echo '#!/bin/bash\nsh scripts/swift-format-mp.sh' > .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit
	
	
.PHONY: clean
clean:
	@echo "Cleaning git hooks..."
	@rm -f .git/hooks/pre-commit
	@echo "Removing SwiftFormat..."
	@brew uninstall swiftformat || true
	@echo "Removing SwiftLint..."
	@brew uninstall swiftlint || true
	@echo "✅ Cleaned successfully!"

.PHONY: format
format:
	@sh scripts/swift-format-mp.sh
