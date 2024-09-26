# fika-spt-server-docker
Clean and easy way to run SPT + Fika server in docker, with the flexibility to modify server files as you wish

## Why?
Existing SPT Dockerfiles seem to leave everything, including building the image with the right sources, up to the user to manage.
I aim to provide a fully pre-packaged SPT Docker image with optional Fika mod that is as plug-and-play as possible. All you need is
- a working docker installation
- a directory to contain your serverfiles, or an existing server directory.
The image has everything else you need to run an SPT Server, with Fika if desired.

## Features
- Reuse an existing installation of SPT! Just mount your existing SPT server folder
- Prepackaged images versioned by SPT version. Images are hosted in ghcr and come prebuilt with a working SPT server binary, and the latest Fika servermod is downloaded and installed on container startup
- Configurable running user and ownership of server files
- (Optional) Auto updates SPT or Fika if we detect a version mismatch

# Releases
The image build is triggered off commits to master and hosted on ghcr
```
docker pull ghcr.io/zhliau/fika-spt-server-docker:latest
```

# Running
See the example docker-compose for a more complete definition
```yaml
services:
  fika-server:
    image: ghcr.io/zhliau/fika-spt-server-docker:latest
    ports:
      - 6969:6969
    volumes:
      # Set this to an empty directory, or a directory containing your existing SPT server files
      - ./path/to/server/files:/opt/server
```

If you want to run the server as a different user than root, set UID and GID
```yaml
services:
  fika-server:
    image: ghcr.io/zhliau/fika-spt-server-docker:latest
    # ...
    environment:
      # Provide the uid/gid of the user to run the server, or it will default to 0 (root)
      # You can get your host user's uid/gid by running the id command
      - UID=1000
      - GID=1000
```

If you want to automatically install Fika, set `INSTALL_FIKA` to `true`
```yaml
services:
  fika-server:
    image: ghcr.io/zhliau/fika-spt-server-docker:latest
    # ...
    environment:
      # ...
      - INSTALL_FIKA=true
```

## Using an existing installation
If you want to migrate to this docker image with an existing SPT install:
> [!WARN]
> MAKE BACKUPS OF YOUR EXISTING SPT SERVER FILES.
- Set your volume mount to your existing SPT server directory (the dir containing the SPT.Server.exe file)
- If you don't have Fika yet, you can provide a `INSTALL_FIKA` env var to tell the container to install the server mod for you
- Run the container, optionally specify if you want the container to auto update the SPT server files or fika server mod via the `AUTO_UPDATE_SPT` and `AUTO_UPDATE_FIKA` env vars

## Updating SPT/Fika versions
Enable auto updates by setting the correct environment variables
```yaml
services:
  fika-server:
    image: ghcr.io/zhliau/fika-spt-server-docker:latest
    # ...
    environment:
      # ...
      - AUTO_UPDATE_SPT=true
      - AUTO_UPDATE_FIKA=true
```

### When fika updates servermod
- Pull the image
- Restart the container

The image will validate your Fika server mod version matches the image's expected version, and if not it will
- Back up the entire Fika server mod including configs to a `backups/fika` directory in the mounted server directory
- Install the expected fika server mod version
- Copy your old fika config.jsonc into the server mod config directory

### When SPT updates
- Update the image version tag
- Restart the container

The image will validate that your SPT version in the serverfiles matches the image's expected SPT version, and if not it will
- Back up the entire `user/` directory to a `backups/spt/` directory in the mounted server directory
- Install the right version of SPT

> [!NOTE]
> The user directory in your existing files are left untouched! Please make sure you validate that the SPT version you are running works with your installed mods and profiles!
> You may want to start by removing all mods and validating them one by one

# Environment Variables
None of these env vars are required, but they may be useful.
| Env var            | Default | Description |
| ------------------ | ------- | ----------- |
| `UID`              | 1000    | The userID to use to run the server binary. This user is created in the container on runtime |
| `GID`              | 1000    | The groupID to assign when creating the user running the server binary. This has no effect if no UID is provided and no user is created |
| `INSTALL_FIKA`     | false   | Whether you want the container to automatically install/update fika servermod for you |
| `FIKA_VERSION`     | v2.2.8  | Override the fika version string to grab the server release from. The release URL is formatted as `https://github.com/project-fika/Fika-Server/releases/download/$FIKA_VERSION/fika-server.zip` |
| `AUTO_UPDATE_SPT`  | false   | Whether you want the container to handle updating SPT in your existing serverfiles |
| `AUTO_UPDATE_FIKA` | false   | Whether you want the container to handle updating Fika server mod in your existing serverfiles |
| `TAKE_OWNERSHIP`   | true    | If this is set to false, the container will not change file ownership of the server files. Make sure the running user has permissions to access these files |


# Troubleshooting
## Why are there files owned by root in my server files?
If you don't want the root user to run SPT server, make sure you provide a userID/groupID to the image to use to run the server.
If none are provided, it defaults to uid 0 which is the root user.
Running the server with root will mean anything the server writes out is created by the root user.

## Development
### Building
```
# Server binary built using SPT Server 3.9.8 git tag, image tagged as fika-spt-server:1.0
$ VERSION=1.0 SPT_SHA=3.9.8 ./build
```
