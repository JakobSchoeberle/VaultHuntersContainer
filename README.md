# VaultHuntersContainer
A Containerized Vault Hunters (Third Edition) Server

## Running 
1. Launch the containers with the terminal.

    ```bash
    $ docker build . -t vaulthunters

    $ docker run -p 25565:25565 -p 24454:24454 vaulthunters
    ```

    or

    ```bash
    $ podman build -t vaulthunters -f Dockerfile

    $ podman run -p 25565:25565 -p 24454:24454 vaulthunters
    ```
    