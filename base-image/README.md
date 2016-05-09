## Set up a registry
1) Retrieve the docker login command that you can use to authenticate your Docker client to your registry:
aws ecr get-login --region us-west-2

2) Run the docker login command that was returned in the previous step.
3) Build your Docker image using the following command. For information on building a Docker file from scratch see the instructions here. You can skip this step if your image is already built:
docker build -t proversity-docker-jupyter .

4) After the build completes, tag your image so you can push the image to this repository:
docker tag proversity-docker-jupyter:latest 353198996426.dkr.ecr.us-west-2.amazonaws.com/proversity-docker-jupyter:latest

5) Run the following command to push this image to your newly created AWS repository:
docker push 353198996426.dkr.ecr.us-west-2.amazonaws.com/proversity-docker-jupyter:latest

Images inheriting from this repo image will use 353198996426.dkr.ecr.us-west-2.amazonaws.com/proversity-docker-jupyter:latest

