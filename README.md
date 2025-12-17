# dCache docker OIDC Playground

This project provides a Docker-based infrastructure for running the dcache service. It includes all necessary configurations and scripts to set up and manage the dcache environment efficiently.

The setup includes a OAUTH-Proxy container (for OIDC handling), a NGINX Proxy, a dCache Container with Postgres database and redis cache store. Also included is a WhoAmi container to inspect the header values available upon successful OIDC authentication

For questions and recommendations please contact me:
harry.kodden(-at-)surf.nl

Inspiration found at
https://agenda.infn.it/event/33041/contributions/182741/attachments/98027/135484/dCachePresentation.pdf

## Prerequisites

Before you begin, ensure you have the following installed:

- Docker
- Docker Compose

## Getting Started

To set up the dcache Docker container infrastructure, follow these steps:

1. **Clone the Repository**

   Clone this repository to your local machine:

   ```
   git clone https://github.com/HarryKodden/dcache-docker-oidc-playground.git
   cd dcache-docker-oidc-playground
   ```

2. **Configure Environment Variables**

   Create a `.env` file in the root directory if it does not exist, and populate it with the necessary environment variables. You can refer to the example provided in the `.env.example` file.

3. **Build the Docker Image**

   Navigate to the `docker` directory and build the Docker image:

   ```
   docker compose build
   ```

4. **Run the Docker Container**

   Use Docker Compose to start the dcache service:

   ```
   docker-compose up
   ```

   This command will start the dcache service along with any defined dependencies.

## Usage

Once the container is running, you can interact with the dcache service as per your requirements. Refer to the `config/dcache.conf` file for configuration options and adjust them as necessary.

## Stopping the Service

To stop the dcache service, you can use:

```
docker-compose down
```

## Contributing

If you would like to contribute to this project, please fork the repository and submit a pull request with your changes.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.# dcache-docker-oidc-playground

## OIDC Mapping and authzdb

A few notes to reproduce the OIDC → local user mapping used in this playground:

- **Map OIDC subject to a local user:** edit `etc/dcache/multi-mapfile.oidc` and add a mapping using the `oidc:` predicate. Example:

   oidc:b0c68753b34d78922a820503d18c046692641e3d@AS username:user uid:1000 gid:1000,true

   This maps the OIDC `sub` principal (as produced by the gPlazma OIDC plugin) to the local `user` account.

- **Ensure issuer string matches:** the `iss` value in the incoming JWT must exactly match the provider entry in `etc/dcache/layouts/mylayout.conf` (no trailing slash mismatches).

- **Provide authzdb authorization entries:** create `./etc/grid-security/storage-authzdb` on the host and add authorize entries for the mapped local user/principal so authzdb validation succeeds. Then mount the folder into the container (example `docker-compose.yml` bind:

   ./etc/grid-security:/etc/grid-security:ro

   Before mounting you may see `NoSuchFileException: /etc/grid-security/storage-authzdb` in the dCache logs.

These three items are sufficient to ensure gPlazma will accept the OIDC token, map the identity to a single `username:` principal, and allow authzdb to validate the mapped account.
