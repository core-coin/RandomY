FROM alpine:3.14 as builder
WORKDIR randomy
COPY . randomy/
RUN apk add cmake make gcc g++ musl-dev
RUN cd randomy && mkdir build && cd build && cmake .. && make -j4
CMD ["tail", "-f"]
