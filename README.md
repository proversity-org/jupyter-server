# Jupyter Notebook Docker deployment with Sifu wrapper

#### Regarding Access Tokens

```text
Access tokens need to be generated in github against a user's profile.
The access token must be added to the elastic beanstalk environment variables,
this can be done via API or via AWS console.

The docker build will reference the access token environment variable
during its build and will be able to clone prviate repos.
```

## Build
```bash
# For the base image
docker build --build-arg -t proversity/base-notebook
# For the final image
docker build --build-arg DEPLOYMENT_TOKEN=$DEPLOYMENT_TOKEN -t proversity/notebook .
```

## Running
```bash
docker run -d --name proversity.jupyter.cont -p 8888:8888 -v "$(pwd):/notebooks" jupyter/notebook
docker exec -it proversity.jupyter.cont bash
OR
docker run -it --rm --name proversity.jupyter.cont -p 8889:8889 -v "$(pwd):/notebooks" jupyter/notebook
```
You can leave volume binding out if needed:
```bash
-v "$(pwd):/notebooks"
```
You need to expose port numbers in the run command as well:
```bash
-p portno:portno -p portno:portno
```
If you're running apps locally, and you want to test your Docker container, it can be useful to allow the container
to run on the host system's network stack; add the following flag to the docker run command:
```bash
--net="host"
```
For example, if your edx app is running on 0.0.0.0:8000, any apps inside the container can now access 0.0.0.0:8000
#### A note on running multiple processes in a container

While it is generally recommended to only have one process per container, there
are some instances where not having multiple processes per container would break
the 'run anywhere' semantics associated with Docker. Cases that fit this model
might be when an app communicates through an ssh tunnel or proxy.

In our case we really need authentication & proxying to be handled by Sifu, so
it makes sense to have them run in the same container. This behaviour can be easily
achieved by using supervisor.

More to come ...

## .ebexentions
An ebextension is needed to set the environment variable DEPLOYMENT_KEY
which is set when creating the EB environment. The ebextension pre-
deployment hook will gather this value, and add it to a file, that can
be used as part of the build process until such a time as when AWS supports
EB build args for their docker deployments.

### ebextenions deployment components overview

#### 01_eb_files.config
This ebextension is a pre-deployment hook that is executed before any other hooks
in ```/opt/elasticbeanstalk/hooks/appdeploy/pre/```. It runs an eb get-config
command that returns the environment variable DEPLOYMENT_TOKEN. This env variable
is then placed in a file for the Docker build process to use. It is anticipated that
this could be removed eventually once AWS supports the Docker --build-arg flag
in Dockerrun.aws.json (v1 & v2) configrations.

#### 02_eb_files.config
This ebextension is a post-deployment hook that is executed after the Docker
deployment has succeeded. It is used to update the Nginx configuration on
the EB instance(s) so that Nginx proxies requests over ports 3334 & 3335 to the
Sifu & Jupyter Notebook server processes running in the Docker container respectively.

The Nginx configuration features a straightforward configuration file: ```/etc/nginx/nginx.conf```
that includes directives from ```/etc/nginx/conf.d/``` & ```/etc/nginx/sites-available```.

The hook, updates the contents of sites-available with virtual host proxy
configurations for Sifu and Jupyter Notebooks, that are kept in a hidden .nginx
folder under .ebextensions. It then goes on to pull a list of running container
ID's, choosing the latest running ID as an argument to ```docker inspect``` to
obtain the IP of the Docker container. It updates the configuration file in ```/etc/nginc/conf.d/```
to include upstream pass configurations for each virtual host.

As a simple example a virtual host may have the following definitions:
```text
.
.
.
server {
       listen 3334;
        .
        .
        .
       location / {
           proxy_pass            http://sifu;
        .
        .
        .
       }
}
```
Then the upstream configuration will look like:
```text
upstream jupyter {
        server 172.17.0.2:3334;
        keepalive 256;
}
.
.
.
```  
Where 127.17.0.2 is the IP of the Docker container.

#### 03_eb_files.config
Is a enact-deployment hook at removes our additions to the nginx sites-available
folder, to prevent the initial eb deployment from complaining. There might be a
better way to structure our ebextensions such this is not needed, but it is fine
as a work around for now.

## Load balancer listener & instance ports
The load balancer must have two listeners configured on ports 3334 and 3335.
The Instance security group must have ports 3334 and 3335 open as a custom tcp rule.


