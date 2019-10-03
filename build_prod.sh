#!/bin/bash
source .env.sh
mix deps.get
cd assets
npm i --no-audit
npm run build
cd ..
MIX_ENV=prod mix do phx.digest, release
