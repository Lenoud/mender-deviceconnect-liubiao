# mender-deviceconnect-liubiao：上游原样源码 + liubiao/patches 构建时补丁。
# 最终镜像布局与 Jenkins mender-server-build 产出的 mender-server-deviceconnect 一致（scratch、65534 用户、TMPDIR=/tmp），只替换二进制。
ARG GO_IMAGE=harbor.skyrisai.com/dockerhub-daocloud/library/golang:1.26.5
FROM ${GO_IMAGE} AS build
ENV GOMAXPROCS=2 GOTOOLCHAIN=local GOPROXY=https://goproxy.cn,direct CGO_ENABLED=0
WORKDIR /source
COPY . /source
RUN set -eu; \
    for patch in liubiao/patches/*.patch; do git apply --check "$patch"; git apply "$patch"; echo "已应用补丁：$patch"; done
WORKDIR /source/backend
ARG SOURCE_VERSION
# 与 Jenkins 一致：执行公共包与本服务的 Go short 单测，排除需要 Mongo 的存储集成包。
RUN set -eu; \
    test -n "${SOURCE_VERSION}"; \
    go mod download; go mod verify; \
    packages="$(go list ./pkg/... ./services/deviceconnect/... | grep -v -E '/store/mongo($|/)')"; \
    go test -tags nopkcs11 -short -p 2 -timeout 240s $packages; \
    go build -tags nopkcs11 -trimpath \
      -ldflags "-s -w -X github.com/mendersoftware/mender-server/pkg/version.version=${SOURCE_VERSION}" \
      -o /out/deviceconnect ./services/deviceconnect; \
    mkdir -p /empty-tmp

FROM scratch
USER 65534:65534
ENV TMPDIR=/tmp
COPY --from=build --chown=65534:65534 /empty-tmp /tmp
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /out/deviceconnect /usr/bin/deviceconnect
COPY backend/services/deviceconnect/config.yaml /etc/deviceconnect/config.yaml
COPY LICENSE /usr/share/licenses/mender-server/LICENSE
ENTRYPOINT ["/usr/bin/deviceconnect", "--config", "/etc/deviceconnect/config.yaml"]
