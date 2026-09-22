# Simple Node.js Express App

A small, beginner-friendly Node.js Express application that listens on port 3000 and exposes a `/health` endpoint. The project is Dockerized and uses GitHub Actions for CI/CD (build, deploy, and rollback workflows).

## Features

- Express server
- Health check endpoint at `/health`
- Runs on port 3000
- Docker-ready with a simple `Dockerfile`
- Basic GitHub Actions workflows for CI/CD

## Prerequisites

- Node.js (v16+/v18+ recommended)
- npm
- Docker (to run in a container)
- Git (to clone the repo)

## Installation

1. Clone the repository:

   git clone <repo-url>
   cd ai-devops-course

2. Install dependencies:

   npm ci

Note: `npm ci` is recommended for reproducible installs. If you don't have a `package-lock.json`, you can use `npm install` instead.

## Run locally

Start the app with node:

```
node index.js
```

Then open http://localhost:3000/health in your browser or run:

```
curl http://localhost:3000/health
```

You should receive a simple 200 response (for example, `{ "status": "ok" }`) if the endpoint is implemented as expected.

## Run with Docker

Build the image:

```bash
docker build -t ai-devops-course:latest .
```

Run the container:

```bash
docker run --rm -p 3000:3000 ai-devops-course:latest
```

Visit `http://localhost:3000/health` to verify the app is running. The `--rm` flag removes the container after it stops (keeps your environment clean).

## CI/CD (GitHub Actions)

This project includes GitHub Actions workflows that demonstrate a simple CI/CD pipeline:

- Build: The workflow builds the Docker image to ensure the project builds successfully in CI.
- Test: (If present) run unit or integration tests defined in `package.json`.
- Deploy: A workflow that can push the built image to a container registry or perform a deployment step.
- Rollback: A workflow that triggers a rollback to a previous stable version in case of a failed deployment.

Notes for beginners:

- The repository may contain `.github/workflows/*.yaml` files. These define the CI/CD steps executed by GitHub Actions.
- A simple workflow might build the Docker image, run it on the runner to smoke-test the container, and then push the image to a registry.
- Rollback workflows usually reference a previous image tag or release and redeploy it.

## Health check

The app exposes a `/health` endpoint on port 3000. Use it in CI to verify the container is healthy before promoting or pushing a release.

Example smoke-check in CI (simplified):

```bash
# start container in background
CONTAINER=$(docker run -d -p 3000:3000 ai-devops-course:latest)
sleep 2
# verify HTTP 200
curl --fail http://localhost:3000/health
# cleanup
docker stop "$CONTAINER"
docker rm "$CONTAINER"
```

## Environment & ports

- The app listens on port `3000`. When running in Docker, map `-p 3000:3000` to expose the app to your host.
- For production, configure environment variables as your app requires. Do not commit secrets to the repository.

## Troubleshooting

- If `npm ci` fails, try `npm install` and ensure your Node.js/npm versions are compatible.
- If Docker build fails, check the `Dockerfile` for missing files and ensure the build context is correct. Use `.dockerignore` to keep the build context small.

## Contributing

Small improvements and bug fixes are welcome. Open a pull request with a clear description of your change.

## License

Choose a license for your project (e.g., MIT) and add a `LICENSE` file if you plan to share the project publicly.
# AI-Devops-project
