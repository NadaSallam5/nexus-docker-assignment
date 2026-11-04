# nexus-docker-assignment

## What I did, step by step

### 1. Postgres with a volume
I created a Docker network called `nexus-net` so my containers could find each other by name. Then I started Postgres 15 with a named volume called `pgdata`. My instructor said a volume or a bind mount would both be fine. I chose a named volume because Docker manages it for me and I avoid folder permission problems.

### 2. Nexus connected to Postgres
I created a volume called `nexus-data` and started the `sonatype/nexus3` container on the same network. I used the `NEXUS_DATASTORE_*` environment variables to point Nexus to my `postgres-db` container instead of its built-in database. I exposed port 8081 for the web page and port 5000 for the Docker registry. I opened port 5000 from the start, because a container's ports can't be changed after it is created.

### 3. Docker registry in Nexus
I logged in to Nexus at `http://localhost:8081` and created a `docker (hosted)` repository called `docker-hosted` with an HTTP connector on port 5000. I also needed the Docker Bearer Token Realm to be active so `docker login` would work.

### 4. Dockerizing an app
I wrote a very small Flask app that returns "Hello from my Nexus registry!". I wrote a `Dockerfile` that starts from `python:3.12-slim`, installs Flask and runs the app. I built it as `flask-app:1.0` and tested it locally before pushing.

### 5. Push, delete and pull
I logged in with `docker login localhost:5000`, tagged the image as `localhost:5000/flask-app:1.0` and pushed it. Then I deleted both local tags with `docker rmi`, so the image existed only inside Nexus. Finally I ran `docker pull localhost:5000/flask-app:1.0`. The digest of the pulled image matched the one I had deleted, which proved the image came back from my own registry.

## Problems I ran into and how I fixed them

- **My VM froze when Nexus started.** The VM only had 3.3 GB of RAM and no swap. I added a 4 GB swap file, and Nexus started fine.
- **After a VM reset my containers were stopped.** I used `docker ps -a` to check what survived. The containers, volumes and network were all still there, so I only had to start them again, Postgres first.
- **I locked myself out of Nexus.** I saved the Realms page without the Local Authenticating Realm in the active list, and login failed with "belongs to a disabled realm". I fixed it by updating the `realm_configuration` table in Postgres and restarting Nexus.
- **Postgres said "too many clients already".** Nexus was using almost all the database connections. I stopped Nexus, made the change in Postgres, then started Nexus again.
- **My first Flask test failed with "connection reset".** I ran `curl` before Flask had finished starting. Adding a `sleep 5` before the test fixed it.

## What I learned

- A named volume keeps data even if the container is deleted.
- Containers on the same Docker network can reach each other by container name.
- A container's published ports are fixed when it is created.
- The start of an image name (`localhost:5000/...`) decides which registry it is pushed to.
- Nexus needs a lot of memory, so I should check RAM before running it.
- Always keep the Local Authenticating Realm active in Nexus.

## Project structure

    flask-app/     My Flask app, requirements.txt and Dockerfile
    scripts/       setup.sh with the commands I used
    docs/          Screenshots of my work

## Note

The passwords in this repo (`nexus123`) are only for my local lab. I would never use them in production.
