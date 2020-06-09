#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix

node2nix \
  --nodejs-10 \
  --input aw-webui-deps.json \
  --composition aw-webui-deps.nix \
  --output aw-webui-packages.nix \
  --no-copy-node-env

node2nix \
  --nodejs-10 \
  --input aw-client-deps.json \
  --composition aw-client-deps.nix \
  --output aw-client-packages.nix \
  --no-copy-node-env
