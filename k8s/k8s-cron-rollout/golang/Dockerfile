FROM golang:1.20 as builder
WORKDIR /go/src/app
COPY go.mod go.sum main.go ./
RUN go mod download && go mod verify
#RUN go mod tidy
#RUN go vet -v
#RUN go test -v
RUN CGO_ENABLED=0 go build -o /go/bin/app

FROM gcr.io/distroless/static-debian11
COPY --from=builder /go/bin/app /
CMD ["/app"]
