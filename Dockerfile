FROM elixir:1.14.4-alpine

RUN apk update
RUN apk add --upgrade postgresql15-client build-base
RUN apk add git inotify-tools make protobuf-dev

ENV APP_HOME /recurrences_client
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY . $APP_HOME

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# set build ENV
ENV MIX_ENV="dev"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

RUN mix escript.install hex protobuf

ENV PATH="${PATH}:/root/.mix/escripts"

CMD ["mix", "phx.server"]
