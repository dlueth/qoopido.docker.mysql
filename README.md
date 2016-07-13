# recommended directory structure #
Like with my other containers I encourage you to follow a unified directory structure approach to keep things simple & maintainable, e.g.:

```
project root
  - docker_compose.yaml
  - config
    - mysql
      - conf.d
        - ...
  -data 
    - mysql
      - logs
      - database
        - dump.sql
```

# Example docker-compose.yaml #
```
db:
  image: qoopido/mysql:latest
  ports:
   - "3306:3306"
  volumes:
   - ./config:/app/config
   - ./data/mysql:/app/data
```

# Or start container manually #
```
docker run -d -P -t -i -p 3306:3306 \
	-v [local path to config]:/app/config \
	-v [local path to data]:/app/data \
	--name db qoopido/mysql:latest
```

# Credentials #
```root``` is restricted to access from localhost and does not have any password. ```admin``` is provided for general access using ```fyoDBafo``` as password.

# Database import/export #
This container will create a file named ```dump.sql``` in ```/app/data/database``` on first execution and will export a fresh dump whenever the container gets stopped. If the file exists it will get imported when the container is started again.

Both im- and export will take some time but have major advantages regarding git or svn versioning. For bigger databases please make sure to add e.g. ```-t 600``` (default is 10, afterwards docker force-kills the container) option to ```docker-compose up``` as well as ```docker stop``` and ```docker-compose stop``` to ensure the dump can be imported/exported successfully before container shutdown.

# Configuration #
Any files under ```/app/config``` will be symlinked into the container's filesystem beginning at ```/etc/mysql```. This can be used to overwrite the container's default mysql configuration with a custom, project specific configuration.

If you need a custom shell script to be run on start or stop (e.g. to set symlinks) you can do so by creating the file ```/app/config/up.sh``` or ```/app/config/down.sh```.