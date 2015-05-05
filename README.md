# _Phalcon2_ and _Apache2_ docker container
Docker container with Phalcon2 framework working with Apache2 (and XDebug)

## How to use this image

### Using _docker run_
    docker run -p "8080:80" -d -v /var/www:/var/www antonienko/phalcon2-apache2 

### Using _docker compose_

    develweb:
      image: antonienko/phalcon2-apache2
      ports:
        - "8080:80"
      volumes:
        - /var/www:/var/www/

You can change the default configuration files provided together with the Dockerfile
