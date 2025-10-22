.PHONY: build switch update test search

# The first word of MAKECMDGOALS is the target itself
# The rest of MAKECMDGOALS are considered additional "targets" by make,
# which we'll then interpret as our arguments.
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

build:
	nix build -v .#darwinConfigurations.simple.system

switch: build
	sudo ./result/sw/bin/darwin-rebuild switch --flake .#simple

update:
	nix flake update

test:
ifndef ARGS
	$(error Missing package name. Usage: make test <package-name>)
endif
	nix-shell -p "$(ARGS)"

search:
ifndef ARGS
	$(error Missing package name. Usage: make search <package-name>)
endif
	nix search nixpkgs "$(ARGS)"

# This special target ensures that any "arguments" (which make sees as targets)
# that don't have explicit rules won't cause an error.
# It effectively makes them "do nothing" targets.
%::
	@true
