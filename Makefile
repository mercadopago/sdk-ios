.PHONY: setup
setup: check-brew install-swiftformat setup-git-hooks

.PHONY: check-brew
check-brew:
	@which brew > /dev/null || (echo "Please install Homebrew first: https://brew.sh" && exit 1)

.PHONY: install-swiftformat
install-swiftformat:
	@which swiftformat > /dev/null || brew install swiftformat

.PHONY: setup-git-hooks
setup-git-hooks:
	mkdir -p .git/hooks
	echo '#!/bin/bash\nsh swift-format-mp.sh' > .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit