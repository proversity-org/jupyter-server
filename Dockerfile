#Installs Jupyter Notebook and IPython kernel from the current branch
# Another Docker container should inherit with `FROM jupyter/notebook`
# to run actual services.

FROM jupyter/notebook
FROM tzenderman/docker-rvm:latest

# Update aptitude with new repo
RUN apt-get update

# Install software 
RUN apt-get install -y git supervisor ruby-dev libgmp3-dev

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

# Install package dependencies
RUN /bin/bash -l -c "rvm install $(cat .ruby-version) --verify-downloads"
RUN /bin/bash -l -c "rvm use $(cat .ruby-version) --default"

RUN rvm requirements

# Install Bundler

RUN /bin/bash -l -c "ruby --version"

RUN /bin/bash -l -c "gem install bundler"

RUN /bin/bash -l -c "bundle config --global silence_root_warning 1"

RUN /bin/bash -l -c "bundle install"

# --gemfile=/home/sifu/Gemfile"

# Alow for arugments to sifu & notebook (server ip & port etc)

# Set as environment variables
