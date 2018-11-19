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

# Release container
FROM base as relese
WORKDIR /app

COPY --from=base /etc/passwd /etc/passwd
COPY --from=dependencies /usr/local/bundle /usr/local/bundle
COPY . .

USER ruby
ENV PORT 4567
EXPOSE 4567
CMD ["ruby", "myapp.rb"]
