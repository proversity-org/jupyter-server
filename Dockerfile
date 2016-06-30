FROM 353198996426.dkr.ecr.us-west-2.amazonaws.com/proversity-docker-jupyter:latest

# Prepare the database
RUN /bin/bash -l -c "bundle exec rake db:migrate"
RUN /bin/bash -l -c "bundle update rails_api_auth"

# Set up supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Supervirsor stuff: Set up loggin for now
RUN mkdir -p /var/log/supervisor

# SET UP ENV VARS
ENV DOCKER_IP 0.0.0.0
#ENV DB_NAME production
#ENV RDS_USERNAME root
#ENV RDS_PASSWORD secretsecret
#ENV RDS_PORT 3306
#ENV EDX_HOSTNAME:
#ENV EDX_OAUTH2_CLIENT_ID:
#ENV EDX_OAUTH2_CLIENT_SECRET:
#ENV EDX_OAUTH2_CLIENT_REDIRECT_URI:
#ENV EDX_OAUTH2_FORCE_SSL: false

COPY overrides.yml /var/tmp/overrides.yml
RUN 

WORKDIR /notebooks
EXPOSE 3334 3335

CMD ["/usr/bin/supervisord"]
#ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/myapp/supervisord.conf"]
