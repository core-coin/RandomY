FROM alpine:3.14 as builder
WORKDIR randomy
COPY . randomy/
RUN apk add cmake make gcc g++ musl-dev
RUN cd randomy && mkdir build && cd build && cmake .. && make -j4
RUN ls randomy/build

FROM scratch
COPY --from=builder /randomy/randomy/build/librandomx.a /usr/local/bin/
CMD ["tail", "-f"]
