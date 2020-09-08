HOSTNAME = $(shell hostname)

ifndef HOSTNAME
 $(error Hostname unknown)
endif

switch:
	sudo nixos-rebuild switch --flake .#${HOSTNAME} -L

build:
	nixos-rebuild build --flake .#${HOSTNAME} -L

update:
	jq --raw-output '.nodes.root.inputs | keys | .[]' < flake.lock | \
		xargs -n1 -P1 nix flake update --update-input
