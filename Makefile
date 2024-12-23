.PHONY: setup
setup: install-mint bootstrap setup-git-hooks

.PHONY: install-mint
install-mint:
	@which mint > /dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/yonaskolb/Mint/master/install.sh)"

.PHONY: bootstrap
bootstrap:
	@mint bootstrap

.PHONY: setup-git-hooks
setup-git-hooks:
	mkdir -p .git/hooks
	echo '#!/bin/bash\nsh scripts/swift-format-mp.sh' > .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit