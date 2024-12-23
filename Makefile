.PHONY: setup
setup: install-brew install-mint install-swiftformat setup-git-hooks

.PHONY: install-brew
install-brew:
	@which brew > /dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

.PHONY: install-mint
install-mint:
	@which mint > /dev/null || brew install mint

.PHONY: install-swiftformat
install-swiftformat:
	@which swiftformat > /dev/null || brew install swiftformat

.PHONY: setup-git-hooks
setup-git-hooks:
	mkdir -p .git/hooks
	echo '#!/bin/bash\nsh scripts/swift-format-mp.sh' > .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit
