FROM bitwalker/alpine-elixir-phoenix:1.9.0 AS build
WORKDIR /app
COPY . .
RUN ./build_prod.sh

FROM bitwalker/alpine-elixir-phoenix:1.9.0
WORKDIR /app
COPY --from=build /app/_build/prod/rel/twitter_feed .
RUN mkdir /app/logs && chmod 777 -R /app/logs

CMD ["bin/twitter_feed", "start"]
