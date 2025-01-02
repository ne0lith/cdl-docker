
# Unofficial CyberDropDownloader Docker Image

## Before proceeding
This is ENTIRELY unofficial. Do NOT ask for support from the dev(s) of cyberdrop-dl-patched.


### GHCR / Dockerhub Repos (amd64/arm64)
```
docker pull ghcr.io/ne0lith/cdl-docker:latest
```

```
docker pull ne0lith/cdl-docker:latest
```

## Docker run command

```
docker run -it \
  --name cdl-docker \
  -v $(pwd)/AppData:/cyberdrop-dl/AppData \
  -v $(pwd)/Downloads:/cyberdrop-dl/Downloads \
  ne0lith/cdl-docker:latest \
  cyberdrop-dl
```

## Docker-Compose configuration

```yaml
version: '3'

services:
  cdl-docker:
    container_name: cdl-docker
    image: ne0lith/cdl-docker:latest
    volumes:
      - /path/to/AppData:/cyberdrop-dl/AppData
      - /path/to/Downloads:/cyberdrop-dl/Downloads
    restart: no
    stdin_open: true
    tty: true
    # You can override the default command by changing the following line
    command: ["cyberdrop-dl"]
```

## Docker-Compose configuration for NAS support

```yaml
version: '3'

services:
  cdl-docker:
    container_name: cdl-docker
    image: ne0lith/cdl-docker:latest
    # this allows us to use this on a nas, even though it is unsupported
    # downside is your cyberdrop.db file has to remain local to the container host
    volumes:
      - /path/to/local/AppData/Cache:/cyberdrop-dl/AppData/Cache
      - /path/to/nas/Appdata/Configs:/cyberdrop-dl/AppData/Configs
      - /path/to/nas/Downloads:/cyberdrop-dl/Downloads
    restart: no
    stdin_open: true
    tty: true
    # You can override the default command by changing the following line
    command: ["cyberdrop-dl"]
```
