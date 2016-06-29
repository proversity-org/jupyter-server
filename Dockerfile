FROM 353198996426.dkr.ecr.us-west-2.amazonaws.com/proversity-docker-jupyter:latest

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
