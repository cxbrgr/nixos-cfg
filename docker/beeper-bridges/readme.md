# Self-Hosted Beeper Bridges (Docker)

A containerized deployment for Beeper Bridges using `bbctl`.

## References
- **Documentation:** https://developers.beeper.com/bridges/self-hosting
- **Bridge Manager:** https://github.com/beeper/bridge-manager

## Prerequisites
- Docker Engine
- Docker Compose

## Setup

1. **Build the Image**

    Build the local image containing dependencies (Python, FFmpeg) and the `bbctl` binary.

    ```bash
    docker compose build
    ```

2. **Authenticate**

    Run the ephemeral manager container to log in. This authorizes the installation with your Beeper account.

    ```bash
    docker compose run --rm manager login
    ```

    Follow the on-screen prompts to enter your email and login code.

3. **Start Bridges**

    Launch the configured bridges in the background.

    ```bash
    docker compose up -d
    ```

4. **Connect Services**

    Open your Beeper Desktop application. You will see a new chat from the bridge bot (e.g., "WhatsApp Bridge"). Follow the chat instructions to pair your account.

## Maintenance

Updating Bridges update frequently. Rebuild the image to fetch the latest bbctl binary and bridge versions.