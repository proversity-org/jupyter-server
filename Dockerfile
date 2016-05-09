#Installs Jupyter Notebook and IPython kernel from the current branch
# Another Docker container should inherit with `FROM jupyter/notebook`
# to run actual services.

FROM jupyter/notebook

RUN pip install --upgrade ipywidgets==5.0.0
RUN jupyter nbextension enable -y widgetsnbextension

RUN echo "c.NotebookApp.tornado_settings = { 'headers': { 'Content-Security-Policy': \"\",'Access-Control-Allow-Origin':\"*\",'Access-Control-Allow-Headers':\"origin, content-type,X-Requested-With, X-CSRF-Token\",'Access-Control-Expose-Headers':\"*\",'Access-Control-Allow-Credentials':\"true\",'Access-Control-Allow-Methods':\"PUT, DELETE, POST, GET OPTIONS\"}}" >> /root/.jupyter/jupyter_notebook_config.py

RUN echo "c.Exporter.template_path = [os.path.join(jupyter_data_dir(), 'templates')] c.Exporter.preprocessors = [\"pre_codefolding.CodeFoldingPreprocessor\",\"pre_pymarkdown.PyMarkdownPreprocessor\"] c.NbConvertApp.postprocessor_class = \"post_embedhtml.EmbedPostProcessor\""

RUN echo "c.NotebookApp.nbserver_extensions = ['nbextensions']" >> /root/.jupyter/jupyter_notebook_config.py

# rvm stuff
ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

# rvm stuff: Install base system libraries.
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl git supervisor libgmp3-dev libpng-dev libjpeg8-dev libfreetype6-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /etc/dpkg/dpkg.cfg.d/02apt-speedup

# USING DEPLOY KEYS ###############################################
# Make ssh dir
#RUN mkdir /root/.ssh/

# Copy over private key, and set permissions
#ADD id_rsa /root/.ssh/id_rsa
#RUN export GIT_SSH=/usr/bin/ssh
#RUN git clone git@github.com:proversity-org/edx-api-jupyter.git

##################################################################

RUN touch /tmp/.ruby-version && touch /tmp/.docker-ruby-version
COPY .ruby-version /tmp/.ruby-version
COPY .docker-ruby-version /tmp/.docker-ruby-version

# Install rvm, default ruby version and bundler.
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 && \
    curl -L https://get.rvm.io | /bin/bash -s stable && \
    echo 'source /etc/profile.d/rvm.sh' >> /etc/profile && \
    /bin/bash -l -c "rvm requirements;" && \
    rvm install $(cat /tmp/.ruby-version) --verify-downloads && \
    /bin/bash -l -c "rvm use --default $(cat /tmp/.ruby-version) && \
    gem install bundler"


# Install ruby using RVM
#RUN /bin/bash -l -c "rvm install $(cat /tmp/.ruby-version) --verify-downloads"
#RUN /bin/bash -l -c "rvm use $(cat /tmp/.ruby-version) --default"
RUN rvm requirements

# run docker env for ruby apps
RUN /bin/bash -l -c "source /tmp/.docker-ruby-version"

RUN echo $RUBY_VERSION

ENV GEM_HOME /usr/local
ENV PATH /usr/local/rvm/gems/ruby-$RUBY_VERSION/bin:$PATH
ENV PATH /usr/local/rvm/rubies/ruby-$RUBY_VERSION/bin:$PATH

RUN rvm list

# Install Bundler
RUN /bin/bash -l -c "gem install bundler"
RUN /bin/bash -l -c "bundle config --global silence_root_warning 1"

# Set sifu environment variables
ENV BUNDLE_GEMFILE /sifu/Gemfile
ENV RAILS_ENV production

# Try and cleanup some cruft
RUN apt-get autoremove

# USING TOKENS ###################################################
ARG DEPLOYMENT_TOKEN
RUN git clone https://$DEPLOYMENT_TOKEN:x-oauth-basic@github.com/proversity-org/edx-api-jupyter.git /tmpapp/
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

# Set up supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Supervirsor stuff: Set up loggin for now
RUN mkdir -p /var/log/supervisor

CMD ["/usr/bin/supervisord"]
#ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/myapp/supervisord.conf"]
