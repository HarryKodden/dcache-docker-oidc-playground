# dcache Docker Infrastructure

This project provides a Docker-based infrastructure for running the dcache service. It includes all necessary configurations and scripts to set up and manage the dcache environment efficiently.

Refer: https://agenda.infn.it/event/33041/contributions/182741/attachments/98027/135484/dCachePresentation.pdf

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
