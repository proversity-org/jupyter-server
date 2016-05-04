#Installs Jupyter Notebook and IPython kernel from the current branch
# Another Docker container should inherit with `FROM jupyter/notebook`
# to run actual services.

FROM jupyter/notebook

# For RVM support - ultimately do out own solution here.
FROM tzenderman/docker-rvm:latest

# Update aptitude
RUN apt-get update

# Install software 
RUN apt-get install -y git supervisor libgmp3-dev

# Set up loggin for now
RUN mkdir -p /var/log/supervisor

# USING DEPLOY KEYS ###############################################

# Make ssh dir
#RUN mkdir /root/.ssh/

# Copy over private key, and set permissions
#ADD id_rsa /root/.ssh/id_rsa
#RUN export GIT_SSH=/usr/bin/ssh
#RUN git clone git@github.com:proversity-org/edx-api-jupyter.git

##################################################################

# USING TOKENS ###################################################
ARG DEPLOYMENT_TOKEN

RUN git clone https://$DEPLOYMENT_TOKEN:x-oauth-basic@github.com/proversity-org/edx-api-jupyter.git /tmpapp/
RUN mkdir /home/sifu/
RUN cp -R /tmpapp/* /home/sifu/
RUN cp -R -r /tmpapp/. /home/sifu/
RUN chown root:root -R /home/sifu/

#################################################################

WORKDIR /home/sifu

# Install ruby using RVM
RUN /bin/bash -l -c "rvm install $(cat .ruby-version) --verify-downloads"
RUN /bin/bash -l -c "rvm use $(cat .ruby-version) --default"
RUN /bin/bash -l -c "rvm list"
RUN rvm requirements

# run docker env for ruby apps
RUN /bin/bash -l -c "source .docker-ruby-version"

RUN echo $RUBY-VERSION

ENV GEM_HOME /usr/local
ENV PATH /usr/local/rvm/gems/ruby-2.2.3/bin:$PATH
ENV PATH /usr/local/rvm/rubies/ruby-2.2.3/bin:$PATH

# Install Bundler
RUN ruby --version
RUN gem install bundler
RUN bundle config --global silence_root_warning 1

# Install Sifu gems
RUN bundle install --gemfile=/home/sifu/Gemfile

# Alow for arugments to sifu & notebook (server ip & port etc)

#RUN /bin/bash -l -c "which bundle"
#RUN /bin/bash -l -c "cp $(which ruby) /usr/bin/"

# Set up supervisor config -- move this up later
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set as environment variables
CMD ["/usr/bin/supervisord"]
#ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/myapp/supervisord.conf"]
