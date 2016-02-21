#!/usr/bin/env bash

docker run --rm \
  --entrypoint "genkey.sh" \
  -v "$HOME"/.alpine/conf:/opt/conf \
  -v "$HOME"/.alpine/keys:/opt/keys \
  resnullius/alpine-devel
