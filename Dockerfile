FROM 353198996426.dkr.ecr.us-west-2.amazonaws.com/proversity-docker-jupyter:latest

# For .ebeextension solution to build args problem.
COPY .deployment_token /tmp/.deployment_token

# USING TOKENS ###################################################
# Waiting for AWS to support build args in EB Docker deploys.
#ARG DEPLOYMENT_TOKEN
RUN git clone https://$(cat /tmp/.deployment_token):x-oauth-basic@github.com/proversity-org/edx-api-jupyter.git /tmpapp/
RUN mkdir /sifu/
RUN cp -R /tmpapp/* /sifu/
RUN cp -R -r /tmpapp/. /sifu/
RUN chown root:root -R /sifu/
#################################################################

WORKDIR /sifu

# Install Sifu gems
RUN /bin/bash -l -c "bundle install"

# Prepare the database
RUN /bin/bash -l -c "bundle exec rake db:migrate"

# Perhaps set this from some other environment variable
# like the EB ENV public IP variable
ENV DOCKER_IP 0.0.0.0

RUN /bin/bash -l -c "bundle update rails_api_auth"
RUN git pull origin master

WORKDIR /notebooks

EXPOSE 3334
EXPOSE 3335

CMD ["/usr/bin/supervisord"]
#ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/myapp/supervisord.conf"]
