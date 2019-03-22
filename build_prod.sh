#!/bin/bash
mix deps.get
cd assets
npm install --no-audit
npm run build
cd ..
MIX_ENV=prod mix do phx.digest, release
# Copy to root for use by SemaphoreCI and Docker
cp ./_build/prod/rel/twitter_feed/releases/1.0.0/twitter_feed.tar.gz .
