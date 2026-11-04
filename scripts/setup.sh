#!/bin/bash
# Commands used in the assignment (lab passwords only)

docker network create nexus-net

docker run -d --name postgres-db --network nexus-net \
  -e POSTGRES_USER=nexus -e POSTGRES_PASSWORD=nexus123 -e POSTGRES_DB=nexus \
  -v pgdata:/var/lib/postgresql/data postgres:15

docker volume create nexus-data
docker run -d --name nexus --network nexus-net \
  -p 8081:8081 -p 5000:5000 \
  -v nexus-data:/nexus-data \
  -e NEXUS_DATASTORE_NEXUS_JDBCURL=jdbc:postgresql://postgres-db:5432/nexus \
  -e NEXUS_DATASTORE_NEXUS_USERNAME=nexus \
  -e NEXUS_DATASTORE_NEXUS_PASSWORD=nexus123 \
  -e NEXUS_DATASTORE_NEXUS_NAME=nexus \
  sonatype/nexus3

# In the Nexus UI: create docker (hosted) repo "docker-hosted" with HTTP port 5000

cd flask-app
docker build -t flask-app:1.0 .
docker login localhost:5000
docker tag flask-app:1.0 localhost:5000/flask-app:1.0
docker push localhost:5000/flask-app:1.0

docker rmi localhost:5000/flask-app:1.0 flask-app:1.0
docker pull localhost:5000/flask-app:1.0
