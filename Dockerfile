# syntax=docker/dockerfile:1.0.0-experimental
FROM ruby:2.4-alpine as base

#Building stage
ENV APP_HOME /app

RUN mkdir $APP_HOME
RUN addgroup -g 1000 -S ruby && \
    adduser -u 1000 -S ruby -G ruby
WORKDIR $APP_HOME
RUN apk add --no-cache libstdc++

COPY Gemfile .
COPY Gemfile.lock .

#Dependences
FROM base AS dependencies
RUN apk add --no-cache g++ musl-dev make && bundle install --without development test

#Test
FROM base AS test
COPY . .
RUN apk add --no-cache g++ musl-dev make && bundle install  && rspec

# app container
FROM base as app
WORKDIR /app

COPY --from=base /etc/passwd /etc/passwd
COPY --from=dependencies /usr/local/bundle /usr/local/bundle
COPY . .

# Security analisys (docker build --target security --ssh default --secret id=aquasec.key,src=aquasec.key -t sinatra:sec .)
##Dirty image
##FROM dependencies as security
###clean image
#FROM app as security
#ADD https://get.aquasec.com/microscanner .
#COPY helpers/microscanner.sh .
#RUN chmod +x microscanner
#RUN chmod +x microscanner.sh
#RUN --mount=type=secret,id=aquasec.key ./microscanner.sh
## install ssh client and git
#RUN apk add --no-cache openssh-client git
## download public key for github.com
#RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
## clone our private repository
#RUN --mount=type=ssh git clone git@github.com:aquasecurity/microscanner.git microscanner_src
##Demo docker run -ti sinatra:sec ls microscanner_src && docker run -ti sinatra:sec cat /run/secrets/aquasec.key)

FROM app as release
USER ruby
ENV PORT 4567
EXPOSE 4567
CMD ["ruby", "myapp.rb"]
