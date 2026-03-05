.PHONY: setup check-brew install-tools setup-git-hooks install-fastlane test format clean

# Initial setup with all required tools
setup: check-brew install-tools setup-git-hooks install-fastlane

# Verify Homebrew installation
check-brew:
	@which brew > /dev/null || (echo "Please install Homebrew first: https://brew.sh" && exit 1)

# Install required development tools
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

# Configure Git hooks for automated formatting
setup-git-hooks:
	mkdir -p .git/hooks
	echo '#!/bin/bash\nsh scripts/swift-format-mp.sh' > .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit

# Install Fastlane dependencies
install-fastlane:
	@echo "📦 Installing Fastlane dependencies..."
	@if [ ! -f "Gemfile" ]; then \
		echo "⚠️ Gemfile not found. Please add Fastlane to your project first."; \
		exit 1; \
	fi
	@if ! command -v bundle >/dev/null 2>&1; then \
		echo "Installing Bundler..." && \
		gem install bundler; \
	fi
	@bundle install --path vendor/bundle

# Run tests using Fastlane
test:
	@echo "🧪 Running tests with Fastlane..."
	@bundle exec fastlane testes

# Format Swift code according to project standards
format:
	@sh scripts/swift-format-mp.sh

# Clean up all installed tools and generated files
clean:
	@echo "Cleaning git hooks..."
	@rm -f .git/hooks/pre-commit
	@echo "Removing SwiftFormat..."
	@brew uninstall swiftformat || true
	@echo "Removing SwiftLint..."
	@brew uninstall swiftlint || true
	@echo "Cleaning test output..."
	@rm -rf fastlane/test_output
	@rm -rf fastlane/xcov_output
	@echo "✅ Clean completed successfully!"