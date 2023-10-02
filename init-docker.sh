#!/bin/bash
if ! command -v docker
then
    echo "Docker not be found. Please install it!"
    exit
fi
echo "BUILDING"
docker compose build
echo "INITIALIZING DATABASE"
docker compose up -d db
echo "WAITING... "
sleep 5s
echo "Creating database"
docker compose run --rm backend mix ecto.create
echo "Running migrations"
docker compose run --rm backend mix ecto.migrate
echo "Running backend and grpc server"
docker compose up -d backend
echo "Visit localhost:4000"
