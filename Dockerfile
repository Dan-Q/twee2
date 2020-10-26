# USAGE:
# docker run --rm -it -v $(pwd):/work [image] build inputfile.twee index.html
# Replace [image] with the appropriate image name

FROM ruby:2.7

WORKDIR /app

COPY . /app

RUN apt update && apt install -y nodejs
RUN bundle install &&\
    gem build twee2.gemspec &&\
    gem install ./twee2-0.5.0.gem &&\
    rm Gemfile.lock

WORKDIR /work
ENTRYPOINT ["twee2"]

