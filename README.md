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
```text
While it is generally recommended to only have one process per container, there are some instances where not having multiple processes per container
would break the 'run anywhere' semantics associated with Docker. Cases that fit this model might be when an app communicates through an ssh tunnel or proxy.

In our case we really need authentication & proxying to be handled by Sifu, so it makes sense to have them run in the same container. This behaviour can be easily
achieved by using supervisor.

More to come ...


```