
FROM ruby:3.0.0
RUN apt-get update && apt-get install -y  wget

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update -qq \
&& apt-get install -y postgresql-client-14
ADD . /Rails-Docker
WORKDIR /Rails-Docker

RUN gem install bundler
RUN bundle config set force_ruby_platform true
RUN bundle install
EXPOSE 3000
CMD ["bash"]