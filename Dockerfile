FROM 353198996426.dkr.ecr.us-west-2.amazonaws.com/proversity-docker-jupyter:latest

# For .ebeextension solution to build args problem.
COPY .deployment_token /tmp/.deployment_token

ENV DB_NAME production
ENV RDS_USERNAME root
ENV RDS_PASSWORD secretsecret
ENV RDS_PORT 3306

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

RUN git pull origin master

# Prepare the database
RUN /bin/bash -l -c "bundle exec rake db:migrate"

# Perhaps set this from some other environment variable
# like the EB ENV public IP variable
ENV DOCKER_IP 0.0.0.0

RUN /bin/bash -l -c "bundle update rails_api_auth"

# Set up supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Supervirsor stuff: Set up loggin for now
RUN mkdir -p /var/log/supervisor

WORKDIR /notebooks

EXPOSE 3334 3335

CMD ["/usr/bin/supervisord"]
#ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/myapp/supervisord.conf"]
