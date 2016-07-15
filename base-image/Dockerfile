#Installs Jupyter Notebook and IPython kernel from the current branch
# Another Docker container should inherit with `FROM jupyter/notebook`
# to run actual services.

FROM jupyter/notebook

RUN pip2 install --upgrade ipywidgets==5.0.0
RUN pip2 install jupyter_nbextensions_configurator
RUN pip2 install widgetsnbextension
RUN pip2 install --upgrade https://github.com/ipython-contrib/IPython-notebook-extensions/tarball/master
RUN jupyter nbextension enable -y widgetsnbextension

#RUN echo "c.Exporter.template_path = [os.path.join(jupyter_data_dir(), 'templates')] c.Exporter.preprocessors = [\"pre_codefolding.CodeFoldingPreprocessor\",\"pre_pymarkdown.PyMarkdownPreprocessor\"] c.NbConvertApp.postprocessor_class = \"post_embedhtml.EmbedPostProcessor\""

#RUN echo "c.NotebookApp.nbserver_extensions = ['nbextensions']" >> /root/.jupyter/jupyter_notebook_config.py

# rvm stuff
ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

# rvm stuff: Install base system libraries.
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl git supervisor libgmp3-dev libpng-dev libjpeg8-dev libfreetype6-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /etc/dpkg/dpkg.cfg.d/02apt-speedup


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

# For .ebeextension solution to build args problem.
COPY .deployment_token /tmp/.deployment_token

# USING TOKENS ###################################################
# Waiting for AWS to support build args in EB Docker deploys.
#ARG DEPLOYMENT_TOKEN
RUN git clone https://github.com/proversity-org/edx-notebookauth-sifu.git /tmpapp/
RUN mkdir /sifu/
RUN cp -R /tmpapp/* /sifu/
RUN cp -R -r /tmpapp/. /sifu/
RUN chown root:root -R /sifu/
#################################################################

WORKDIR /sifu

# Install Sifu gems
RUN /bin/bash -l -c "bundle install"
