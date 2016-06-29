# Jupyter Notebook Docker deployment with Sifu

This system is a scalable deployment of Jupyter Notebook Docker Containers on
AWS Elastic Beanstalk.

Authentication is handled the Sifu API from the Xblock. Sifu uses Edx as Oauth 2
authenticator. Once authenticated user notebooks can be created, destroyed, and served through Sifu. Eventually,
accessing the Jupyter Notebook server will be restricted to the iframe it is served in
as well as other security modifications.

Each Docker container on an EB instance will use mounted volumes based off of the AWS
Elastic File System service. This means each container has the same access to
user notebooks ensuring high availability across Docker containers.

#### Regarding Access Tokens

Access tokens need to be generated in github against a user's profile.
The access token must be added to the elastic beanstalk environment variables,
this can be done via API or via AWS console, but in our scenario this must be done
at environment creation time, using the eb cli command:

```bash
eb create --envvars DEPLOYMENT_TOKEN=$DEPLOYMENT_TOKEN
eb create --envvars DEPLOYMENT_TOKEN=$DEPLOYMENT_TOKEN --database
```

The docker build will reference the access token environment variable
during its build and will be able to clone prviate repos.

## Ports
Jupyter Notebook is always run on port 3335, and Sifu on 3334. In future the option
to change these will be provided. But it speaks to the deployment process as a
whole rather than just a software configuration. It would require not only updating
software configurations, but also updating the ebexentions that set up the Nginx
environment as well as listeners and security group ports.

## Build
```bash
cd base-image
# For the base image
docker build --build-arg -t proversity/base-notebook

cd ..
# For the final image
docker build --build-arg DEPLOYMENT_TOKEN=$DEPLOYMENT_TOKEN -t proversity/notebook .
```

Build arguments are currently not supported by AWS Elastic Beanstalk, therefore for
the time being you must ensure the deployment token exists in the project directory
in a file called .deployment_token. When running the above command you may then
leave out --build-arg. It is kept for future reference.

## Running
The following examples are illustrations mostly for the purpose of running the
Docker container locally.

```bash
docker run -d --name proversity.jupyter.cont -p 3334:3334 -p 3335:3335 -v "$(pwd):/notebooks" jupyter/notebook
docker exec -it proversity.jupyter.cont bash
OR
docker run -it --rm --name proversity.jupyter.cont -p 3334:3334 -p 3335:3335 -v "$(pwd):/notebooks" jupyter/notebook
```
You can leave volume binding out if not needed:
```bash
-v "$(pwd):/notebooks"
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

Supervisor configuration exists in the root of this project, and is passed into
Docker during the build process. CMD is then set to run supervisor on Docker run.

The supervisor is run in nodaemon mode, it starts the Sifu app server, and then the
Jupyter Notebook server respectively.

```text
bundle exec puma -C /sifu/config/puma.rb /sifu/config.ru

jupyter notebook --no-browser --port=3335 --ip=$DOCKER_IP
```

In future we should be able to remove the DOCKER_IP variable, as it appears all
server processes default to use 0.0.0.0 as their IP, and anyway mapping between
Docker container IP on the EB host and the Docker container host IP is done automatically.
Note in this instance getting Docker to run using the host's network stack is not
appropriate, it might only be appropriate if you are doing debugging on your local
machine.

## .ebexentions

### .ebextensions deployment components overview

#### 01_eb_files.config
This ebextension is a pre-deployment hook that is executed before any other hooks
in ```/opt/elasticbeanstalk/hooks/appdeploy/pre/```.

It runs an eb get-config command that returns the environment variable DEPLOYMENT_TOKEN. This env variable
is then placed in a file for the Docker build process to use.

It is anticipated that this could be removed eventually once AWS supports the Docker --build-arg flag
in Dockerrun.aws.json (v1 & v2) configurations.

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
The upstream configuration will then look like:
```text
upstream sifu {
        server 172.17.0.2:3334;
        keepalive 256;
}
.
.
.
```  
Where 127.17.0.2 is the IP of the Docker container.

#### 03_eb_files.config
This deployment hook is an enact-deployment hook at removes our additions to the nginx sites-available
folder, to prevent the subsequent eb deployments from failing. There might be a
better way to structure our ebextensions such this is not needed, but it is fine
as a work around for now.

#### resources.config

The load balancer must have two listeners configured on ports 3334 and 3335. In
addition its security group must also allow for Ingress & Egress from these ports.
The resources.config ebextension ensures these ports are properly configured for
the EB instance security group, the EB load balancer security group and that the EB load balancer listens on them.

#### Note on ECR - permissions
Permissions must be set on an ECR, so that Elastic Beanstalk may use it.
This can be done in the console, but should really be handled in the script below.

It is a role not a user that needs permission: arn:aws:iam::<account#>:role/aws-elasticbeanstalk-ec2-role

In particular it is the elasticbeanstalk-ec2-role that needs permission.

#### Future automated deployments
In future this project will perform the following automatically in a deployment script:

-- automatic creation of IAM user for access to S3 buckets
-- automatic creation of S3 bucket specific to this deploy
-- automatic update of the credentials in environment.config
-- automatically mount file system to docker

1. Check AWS CLI & EB CLI installed, and credentials exist.
2. Check status of container registry in Oregon (us-west-2).
3. Create registry if it does not exist & set permissions
4. Get docker-ecr login details.
5. Login for the user (these login sessions expire).
6. Make sure the image build is up to date, otherwise build.
7. Upload to the registry.
8. In region North California, allow a user to use an existing application or create a new one.
9. Allow the user to use an existing environment or create a new one.
10. Check if .deployment_token exists in project directory root or as an environment variable.
11. Ask the user for a deployment token if needed and handle the updating of .deployment_token.
12. Ask the user to specify ports.
13. Update .ebextensions and save the extra config in a .ports file. (This is ignored by git).
14. Deploy.
