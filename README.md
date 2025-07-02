I need a runner ... 

# Build
```
nix build .#darwinConfigurations.simple.system
```

# Switch
```
sudo ./result/sw/bin/darwin-rebuild switch --flake .#simple
```

# Update inputs
```
nix flake update
```

Then run `build` then `switch`
