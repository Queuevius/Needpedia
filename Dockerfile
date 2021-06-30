FROM ruby:2.6.4

WORKDIR /workspace

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg -o /root/yarn-pubkey.gpg && apt-key add /root/yarn-pubkey.gpg
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN curl -sL https://deb.nodesource.com/setup_12.x | /bin/bash -
RUN apt-get update && apt-get install -y --no-install-recommends nodejs yarn

RUN apt-get update && \
  apt-get install -qq -y --no-install-recommends && \
  rm -rf /var/lib/apt/lists/*


COPY Gemfile ./
COPY Gemfile.lock ./

RUN apt install shared-mime-info
RUN gem install mimemagic -v '0.3.10' --source 'https://rubygems.org/'
RUN gem install rails bundler
RUN bundle install

COPY ../../.rvm/gems/ruby-2.6.3/gems/popper_js-1.16.0/assets/javascripts ./
RUN chmod +x /workspace/bin/rails
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | /bin/bash -


RUN chmod +x /workspace/bin/start.sh
EXPOSE 3000
# Start the application server
ENTRYPOINT [ "/bin/bash","./bin/start.sh" ]
