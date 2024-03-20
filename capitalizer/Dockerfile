# To run locally:
#
# docker build -t capitalizer --build-arg DART_VERSION=3.2.0 .
# docker run -it --rm -e "PROJECT=$PROJECT" -e "GOOGLE_APPLICATION_CREDENTIALS=/app/keys/key.json" -v /Users/user/dart-pubsub-gke-demo/keys/pubsub.json:/app/keys/key.json --name capitalizer capitalizer
# docker stop capitalizer

ARG DART_VERSION
FROM dart:${DART_VERSION} AS build

WORKDIR /app

COPY . /app
RUN dart pub get
RUN mkdir /app/bin
RUN dart compile exe lib/main.dart -o /app/bin/server

FROM scratch

COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/

CMD ["/app/bin/server"]
