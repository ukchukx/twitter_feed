FROM bitwalker/alpine-elixir-phoenix:1.11.4 AS build
WORKDIR /app
COPY . .
ENV MIX_ENV=prod
RUN cd apps/twitter_feed; mix do deps.get, deps.compile
RUN ./build_prod.sh

FROM alpine:3.14
WORKDIR /app
ENV MIX_ENV=prod
RUN apk update && apk --no-cache --update add bash openssl
WORKDIR /app
COPY --from=build /app/_build/prod/rel/twitter_feed .

ENTRYPOINT ["bin/twitter_feed"]
CMD ["start"]
