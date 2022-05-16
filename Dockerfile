FROM golang:1.18 AS build
ENV CGO_ENABLED=0
WORKDIR /go/src

COPY go.* ./
RUN go get -d -v ./...

COPY main.go .
COPY content.txt .

RUN go build -a -installsuffix cgo -o service .

FROM scratch AS runtime
ENTRYPOINT ["./service"]

COPY --from=build /go/src/service ./
