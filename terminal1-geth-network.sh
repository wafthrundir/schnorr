#!/bin/bash

. scripts/colors.sh


trap "popd; yellow 'geth network stopped.'" EXIT
pushd docker

yellow 'Starting geth network...'
docker compose down --remove-orphans && docker compose build && docker compose up