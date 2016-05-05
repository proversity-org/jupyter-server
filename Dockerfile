#Installs Jupyter Notebook and IPython kernel from the current branch
# Another Docker container should inherit with `FROM jupyter/notebook`
# to run actual services.

# For RVM support - ultimately do out own solution here.

FROM jupyter/notebook

#FROM tzenderman/docker-rvm:latest

ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

# Install base system libraries.
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /etc/dpkg/dpkg.cfg.d/02apt-speedup

# Update aptitude
RUN apt-get update

# Install software 
RUN apt-get install -y git supervisor libgmp3-dev libpng-dev libjpeg8-dev libfreetype6-dev

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

RUN echo "More cheap"

# USING TOKENS ###################################################
ARG DEPLOYMENT_TOKEN
RUN git clone https://$DEPLOYMENT_TOKEN:x-oauth-basic@github.com/proversity-org/edx-api-jupyter.git /tmpapp/
RUN mkdir /home/sifu/
RUN cp -R /tmpapp/* /home/sifu/
RUN cp -R -r /tmpapp/. /home/sifu/
RUN chown root:root -R /home/sifu/

#################################################################

WORKDIR /home/sifu

# Install rvm, default ruby version and bundler.
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 && \
    curl -L https://get.rvm.io | /bin/bash -s stable && \
    echo 'source /etc/profile.d/rvm.sh' >> /etc/profile && \
    /bin/bash -l -c "rvm requirements;" && \
    rvm install $(cat .ruby-version) && \
    /bin/bash -l -c "rvm use --default $(cat .ruby-version) && \
    gem install bundler"

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

# Set as environment variables
ENV BUNDLE_GEMFILE /home/sifu/Gemfile
ENV RAILS_ENV production

# Install Sifu gems
RUN bundle install --gemfile=/home/sifu/Gemfile

RUN bundle exec rake db:migrate

# Alow for arugments to sifu & notebook (server ip & port etc)

# Set up supervisor config -- move this up later
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Perhaps set this from some other environment variable
# like the EB ENV public IP variable
ENV DOCKER_IP 0.0.0.0

RUN bundle update rails_api_auth
RUN git pull origin master

WORKDIR /notebooks

RUN echo "c.NotebookApp.tornado_settings = { 'headers': { 'Content-Security-Policy': \"\",'Access-Control-Allow-Origin':\"http://0.0.0.0:8000\",'Access-Control-Allow-Headers':\"origin, content-type,X-Requested-With, X-CSRF-Token\",'Access-Control-Expose-Headers':\"*\",'Access-Control-Allow-Credentials':\"true\",'Access-Control-Allow-Methods':\"PUT, DELETE, POST, GET OPTIONS\"}}" >> /root/.jupyter/jupyter_notebook_config.py

EXPOSE 3334
EXPOSE 3335

CMD ["/usr/bin/supervisord"]
#ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/myapp/supervisord.conf"]
