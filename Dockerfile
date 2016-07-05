FROM 353198996426.dkr.ecr.us-west-2.amazonaws.com/proversity-docker-jupyter:latest

# SET UP ENV VARS
ENV DOCKER_IP 0.0.0.0
COPY docker_envs /tmp/docker_envs

RUN /bin/bash -l -c "echo \"source /tmp/docker_envs\" >> /etc/bash.bashrc"

# Prepare the database
RUN /bin/bash -l -c "source /tmp/docker_envs && bundle exec rake db:migrate"
RUN /bin/bash -l -c "source /tmp/docker_envs && bundle update rails_api_auth"

# Set up supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Supervirsor stuff: Set up loggin for now
RUN mkdir -p /var/log/supervisor

RUN sudo apt-get install -y cifs-utils nfs-common

WORKDIR /notebooks

EXPOSE 3334 3335

CMD ["/usr/bin/supervisord"]
#ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/myapp/supervisord.conf"]
