# Docker Unison - With Group ID
We extended the base image to also utilize unisons support for defining a sync GROUP_ID, because we had issues with file permissions.

The package currently uses unison 2.48.4. 

## Usage

This image is the unison-image for [docker-sync](https://github.com/EugenMayer/docker-sync) and published on [eugenmayer/unison](https://hub.docker.com/r/eugenmayer/unison/)
A lot of credits go to [mickaelperrin](https://github.com/mickaelperrin) - most of the work has been done by him.

## What does it do ?

This image simply runs an unison server on the internal port `5000` with the specified user/uid. If the user/uid doesn't
exist, it is created/modified on startup.

## Documetation

You can configure how unison runs by using the following ENV variables:
 
 - `VOLUME` specifies the directory created in the container to store the synced files, `/data` by default
 - `OWNER_UID` specifies **the ID of the user** on which the unison process run and the owner of the synced files.
 - `GROUP_ID` specifies **the ID of the group** on which the unison process run and the group of the synced files.
 - `MAX_INOTIFY_WATCHES` increases the limit of inotify watches if you need to sync folders with lots of files. 

## Credits
- Big thanks at [mickaelperrin](https://github.com/mickaelperrin) for putting hard work into getting this production ready

## License
What the others did, so:
This docker image is licensed under GPLv3 because Unison is licensed under GPLv3 and is included in the image. See LICENSE.

## Use in Docker-Compose like:
```
    unison:  
        image: 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-dev-unison:latest
        depends_on:
            - apache-php
        environment:  
            - APP_VOLUME=/var/www/html/ 
            - OWNER_UID=1000
            - GROUP_ID=33
        volumes_from:
            - apache-php
        ports:  
            - "${APP_UNISON_PORT}:5000"
```
