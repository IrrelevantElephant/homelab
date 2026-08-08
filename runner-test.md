# Add Test API and Forgejo Image Pipeline

## Summary

Create a small Go HTTP service under `resources/test-api` and a Forgejo Actions workflow that builds and publishes it as `git.giulia-harry.dev/harry/homelab/test-api`. Forgejo workflows are discovered from `.forgejo/workflows`, and the nested image name will associate it with the homelab repository. [Forgejo workflow docs](https://forgejo.org/docs/latest/user/actions/overview/) [Forgejo registry docs](https://forgejo.org/docs/latest/user/packages/container/)

## Implementation Changes

- Add a Go 1.26 module using only the standard library.
- Serve HTTP on port `8080`.
- Implement `GET /` returning:
  ```json
  {
    "message": "test-api is running",
    "time": "<current UTC time in RFC3339 format>"
  }
  ```
- Return `405 Method Not Allowed` for non-GET requests.
- Add a multi-stage Dockerfile that:
  - Uses the current stable Go 1.26 Alpine builder.
  - Produces a static Linux binary.
  - Runs as a non-root user in a minimal `scratch` image.
  - Exposes port `8080` and includes the Forgejo source OCI label.
- Add a focused `.dockerignore`.

## Forgejo Workflow

- Add `.forgejo/workflows/test-api.yaml`.
- Trigger on every push to `main`.
- Run on the existing `docker` runner label and check out the repository with Forgejo’s checkout action.
- Install the Docker CLI in the runner’s Debian job container and use the already-mounted Docker socket.
- Authenticate to `git.giulia-harry.dev` with:
  - `secrets.REGISTRY_USERNAME`
  - `secrets.REGISTRY_TOKEN`
- Build from `resources/test-api` and push both:
  - `git.giulia-harry.dev/harry/homelab/test-api:${FORGEJO_SHA}`
  - `git.giulia-harry.dev/harry/homelab/test-api:latest`
- Document that `REGISTRY_TOKEN` must be a Forgejo personal access token with the minimum `write:package` scope. [Forgejo token scope docs](https://forgejo.org/docs/latest/user/authentication/token-scope/)

## Test Plan

- Build the image locally and confirm it runs as a non-root container.
- Request `/` and verify the JSON message and a current, parseable UTC timestamp.
- Request `/` with a non-GET method and verify HTTP 405.
- Validate the workflow YAML and confirm it targets the existing `docker` runner.
- After pushing to `main`, verify the workflow succeeds and both SHA and `latest` tags appear in Forgejo’s container registry.

## Assumptions

- No Kubernetes deployment, Service, or ArgoCD application for `test-api` is included; this change stops at building and publishing the image.
- The Forgejo repository has Actions enabled and can access the instance-level runner already defined in `resources/forgejo/runner`.
- The repository secrets will be configured in Forgejo outside version control.
- Existing unrelated files, including `updatecli.d/`, remain untouched.
- No automated tests are required (unit/integration etc)
