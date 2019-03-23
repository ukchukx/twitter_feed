#!/bin/bash
source .env
./stop.sh
docker-compose up -d
