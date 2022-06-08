#!/bin/sh
mix deps.get
cd assets
npm i --no-audit
npm run build
cd ..
mix do phx.digest, release
