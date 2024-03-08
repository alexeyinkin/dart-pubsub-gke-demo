# To run locally:
#
# docker build -t capitalizer .
# docker run -it --rm -e "PROJECT=$PROJECT" -v /Users/user/dart-pubsub-gke-demo/keys/pubsub.json:/app/keys/key.json --name capitalizer capitalizer
# docker stop capitalizer

FROM dart:stable AS build

WORKDIR /app

COPY . /app
RUN dart pub get
RUN mkdir /app/bin
RUN dart compile exe lib/main.dart -o /app/bin/server

FROM scratch

# When running the container, mount the key to this path:
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/keys/key.json

COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/

CMD ["/app/bin/server"]
