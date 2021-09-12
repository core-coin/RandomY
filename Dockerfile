FROM alpine:3
WORKDIR randomy
COPY . randomy/
RUN apk add --no-cache cmake make gcc g++ musl-dev
RUN cd randomy && mkdir build && cd build && cmake -DARCH=native .. && make
CMD ["tail","-f"]
