# NAME:     bec/participa
# VERSION:  1.1.0

FROM buildpack-deps:xenial

LABEL \
  cat.bcnencomu.participa.description="Docker image to run BeC's Participa platform" \
  cat.bcnencomu.participa.vendor="Adab1ts" \
  cat.bcnencomu.participa.version="1.1.0"

MAINTAINER Carles Muiños "carles@adabits.org"

# Base
## add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN useradd participa -s /bin/bash -m -U

RUN \
  apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  ghostscript \
  libicu55 \
  nodejs \
  sqlite3 \
  wkhtmltopdf \
&& rm -rf /var/lib/apt/lists/*

# Ruby
ENV RUBY_VERSION 2.3.3
ENV RUBY_HOME /usr/local/ruby
RUN \
  set -ex \
  && mkdir -p /usr/local/etc \
  && { \
      echo 'install: --no-document'; \
      echo 'update: --no-document'; \
     } >> /usr/local/etc/gemrc \
  && RUBY_SRC="$(mktemp -d)" \
  && git clone https://github.com/rbenv/ruby-build.git $RUBY_SRC \
  && $RUBY_SRC/install.sh \
  && rm -rf $RUBY_SRC \
  && mkdir -p $RUBY_HOME \
  && ruby-build $RUBY_VERSION $RUBY_HOME/$RUBY_VERSION \
  && ln -s $RUBY_HOME/$RUBY_VERSION $RUBY_HOME/default

ENV PATH $RUBY_HOME/default/bin:$PATH
RUN gem install bundler --no-document

# PhantomJS
ENV PHANTOMJS_VERSION 2.1.1
RUN \
  set -ex \
  && wget -q -O phantomjs.tar.bz2 https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-${PHANTOMJS_VERSION}-linux-x86_64.tar.bz2 \
  && mkdir -p /usr/local/share/phantomjs \
  && tar -xjf phantomjs.tar.bz2 -C /usr/local/share/phantomjs --strip-components=1 \
  && rm phantomjs.tar.bz2 \
  && ln -s /usr/local/share/phantomjs/bin/phantomjs /usr/local/bin/phantomjs

# Participa
ARG APP_HOME
ENV APP_HOME ${APP_HOME:-/app}

WORKDIR $APP_HOME

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 5 --retry 3
COPY . ./

RUN chown -R participa:participa ./
USER participa

EXPOSE 3000

CMD ["/bin/bash"]
