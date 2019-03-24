FROM bitwalker/alpine-elixir-phoenix:1.8.0 AS build
WORKDIR /app
COPY . .
RUN ./build_prod.sh

FROM bitwalker/alpine-elixir-phoenix:1.8.0
WORKDIR /app
COPY --from=build /app/twitter_feed.tar.gz .
RUN tar -zxf twitter_feed.tar.gz && rm -f twitter_feed.tar.gz && mkdir /app/logs && chmod 777 -R /app/logs

ENTRYPOINT ["bin/twitter_feed"]
CMD ["foreground"]
