FROM --platform=${BUILDPLATFORM} golang:1.20.4-alpine AS build_deps
RUN apk add --no-cache git
WORKDIR /workspace
COPY go.mod go.sum ./
RUN go mod download

FROM build_deps AS build
ARG TARGETOS
ARG TARGETARCH
COPY . .
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o webhook -ldflags '-w -extldflags "-static"' .

FROM alpine:3.18
RUN apk add --no-cache ca-certificates
COPY --from=build /workspace/webhook /usr/local/bin/webhook
ENTRYPOINT ["webhook"]
