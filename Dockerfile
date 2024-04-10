ARG IMG_TAG=latest

# This shouldn't be inside the image, but I put it here to eliminate one manual step
# Clone the repository
FROM alpine/git AS clone
WORKDIR /src/app/
ARG GITHUB_USERNAME
RUN git config --global credential.username $GITHUB_USERNAME &&\
    git clone https://github.com/cosmos/gaia.git -b v14.2.0 .


# The part below is taken from their repository
# Compile the gaiad binary
FROM golang:1.20-alpine AS gaiad-builder
ENV HOME=/src/app
WORKDIR $HOME
COPY --from=clone $HOME .
RUN go mod download
ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev python3
RUN apk add --no-cache $PACKAGES
RUN CGO_ENABLED=0 make install

# Add to a distroless container
FROM cgr.dev/chainguard/static:$IMG_TAG
WORKDIR /src/app/
ARG IMG_TAG
COPY --from=gaiad-builder /go/bin/gaiad /usr/local/bin/
EXPOSE 26656 26657 1317 9090
USER 0

ENTRYPOINT ["gaiad", "start", "--home", "/src/app", "--minimum-gas-prices", "0.01photino"]

# Running a container with this image throws an error (panic: couldn't read GenesisDoc file: open /src/app/config/genesis.json: no such file or directory).
# I know just the basics about blockchain, but from what I've read I need to create an account and join a testnet. I wish I had the time to get deeper into this
# right now and learn how to properly do it, but for the purpose of this assessment I will pass it

# Results from Grype:

# NAME                          INSTALLED         FIXED-IN  TYPE       VULNERABILITY        SEVERITY
# github.com/cometbft/cometbft  v0.37.4           0.37.5    go-module  GHSA-hq58-p9mv-338c  Low
# github.com/cometbft/cometbft  v0.37.4                     go-module  GHSA-555p-m4v6-cqxv  Low
# github.com/cosmos/cosmos-sdk  v0.47.10-ics-lsm            go-module  GHSA-w5w5-2882-47pc  Low
# github.com/cosmos/ibc-go/v7   v7.3.2            7.4.0     go-module  GHSA-j496-crgh-34mx  Critical
# golang.org/x/crypto           v0.16.0           0.17.0    go-module  GHSA-45x7-px36-x8w8  Medium
# google.golang.org/protobuf    v1.32.0           1.33.0    go-module  GHSA-8r3f-844c-mc37  Medium

# Results from Syft:

# NAME                                                                VERSION                               TYPE        
# alpine-baselayout-data                                              3.6.3-r0                              apk
# alpine-keys                                                         2.4-r1                                apk
# alpine-release                                                      3.20.0_alpha20240329-r0               apk
# ca-certificates-bundle                                              20240226-r0                           apk
# cloud.google.com/go                                                 v0.111.0                              go-module    
# cloud.google.com/go/compute/metadata                                v0.2.3                                go-module    
# cloud.google.com/go/iam                                             v1.1.5                                go-module    
# cloud.google.com/go/storage                                         v1.30.1                               go-module
# cosmossdk.io/api                                                    v0.3.1                                go-module
# cosmossdk.io/core                                                   v0.5.1                                go-module
# cosmossdk.io/depinject                                              v1.0.0-alpha.4                        go-module
# cosmossdk.io/errors                                                 v1.0.1                                go-module
# cosmossdk.io/log                                                    v1.3.1                                go-module
# cosmossdk.io/math                                                   v1.3.0                                go-module
# cosmossdk.io/simapp                                                 v0.0.0-20230602123434-616841b9704d    go-module
# cosmossdk.io/tools/rosetta                                          v0.2.1                                go-module
# filippo.io/edwards25519                                             v1.0.0                                go-module
# github.com/ChainSafe/go-schnorrkel                                  v1.0.0                                go-module
# github.com/armon/go-metrics                                         v0.4.1                                go-module
# github.com/aws/aws-sdk-go                                           v1.44.203                             go-module
# github.com/beorn7/perks                                             v1.0.1                                go-module
# github.com/bgentry/go-netrc                                         v0.0.0-20140422174119-9fd32a8b3d3d    go-module
# github.com/bgentry/speakeasy                                        v0.1.1-0.20220910012023-760eaf8b6816  go-module
# github.com/btcsuite/btcd/btcec/v2                                   v2.3.2                                go-module
# github.com/cenkalti/backoff/v4                                      v4.1.3                                go-module
# github.com/cespare/xxhash/v2                                        v2.2.0                                go-module
# github.com/chzyer/readline                                          v1.5.1                                go-module
# github.com/cockroachdb/apd/v2                                       v2.0.2                                go-module
# github.com/cockroachdb/errors                                       v1.10.0                               go-module
# github.com/cockroachdb/logtags                                      v0.0.0-20230118201751-21c54148d20b    go-module
# github.com/cockroachdb/redact                                       v1.1.5                                go-module
# github.com/coinbase/rosetta-sdk-go                                  v0.7.9                                go-module
# github.com/cometbft/cometbft                                        v0.37.4                               go-module
# github.com/cometbft/cometbft-db                                     v0.10.0                               go-module
# github.com/confio/ics23/go                                          v0.9.0                                go-module
# github.com/cosmos/btcutil                                           v1.0.5                                go-module
# github.com/cosmos/cosmos-proto                                      v1.0.0-beta.4                         go-module
# github.com/cosmos/cosmos-sdk                                        v0.47.10-ics-lsm                      go-module
# github.com/cosmos/gaia/v15                                          v0.0.0-20240318084748-1e7b5171ff1d    go-module
# github.com/cosmos/go-bip39                                          v1.0.0                                go-module
# github.com/cosmos/gogogateway                                       v1.2.0                                go-module
# github.com/cosmos/gogoproto                                         v1.4.10                               go-module
# github.com/cosmos/iavl                                              v0.20.1                               go-module
# github.com/cosmos/ibc-apps/middleware/packet-forward-middleware/v7  v7.1.3-0.20240228213828-cce7f56d000b  go-module
# github.com/cosmos/ibc-go/v7                                         v7.3.2                                go-module
# github.com/cosmos/ics23/go                                          v0.10.0                               go-module
# github.com/cosmos/interchain-security/v3                            v3.3.3-lsm                            go-module
# github.com/cosmos/keyring                                           v1.2.0                                go-module
# github.com/cosmos/rosetta-sdk-go                                    v0.10.0                               go-module
# github.com/creachadair/taskgroup                                    v0.4.2                                go-module
# github.com/davecgh/go-spew                                          v1.1.1                                go-module
# github.com/decred/dcrd/dcrec/secp256k1/v4                           v4.1.0                                go-module
# github.com/desertbit/timer                                          v0.0.0-20180107155436-c41aec40b27f    go-module
# github.com/dvsekhvalnov/jose2go                                     v1.6.0                                go-module
# github.com/felixge/httpsnoop                                        v1.0.2                                go-module
# github.com/fsnotify/fsnotify                                        v1.6.0                                go-module
# github.com/getsentry/sentry-go                                      v0.23.0                               go-module
# github.com/go-kit/kit                                               v0.12.0                               go-module
# github.com/go-kit/log                                               v0.2.1                                go-module
# github.com/go-logfmt/logfmt                                         v0.6.0                                go-module
# github.com/go-logr/logr                                             v1.2.4                                go-module
# github.com/go-logr/stdr                                             v1.2.2                                go-module
# github.com/godbus/dbus                                              v0.0.0-20190726142602-4481cbc300e2    go-module
# github.com/gogo/googleapis                                          v1.4.1                                go-module
# github.com/gogo/protobuf                                            v1.3.2                                go-module
# github.com/golang/groupcache                                        v0.0.0-20210331224755-41bb18bfe9da    go-module
# github.com/golang/mock                                              v1.6.0                                go-module
# github.com/golang/protobuf                                          v1.5.3                                go-module
# github.com/golang/snappy                                            v0.0.4                                go-module
# github.com/google/btree                                             v1.1.2                                go-module
# github.com/google/go-cmp                                            v0.6.0                                go-module
# github.com/google/orderedcode                                       v0.0.1                                go-module
# github.com/google/s2a-go                                            v0.1.7                                go-module
# github.com/google/uuid                                              v1.4.0                                go-module
# github.com/googleapis/enterprise-certificate-proxy                  v0.3.2                                go-module
# github.com/googleapis/gax-go/v2                                     v2.12.0                               go-module
# github.com/gorilla/handlers                                         v1.5.1                                go-module
# github.com/gorilla/mux                                              v1.8.1                                go-module
# github.com/gorilla/websocket                                        v1.5.0                                go-module
# github.com/grpc-ecosystem/go-grpc-middleware                        v1.3.0                                go-module
# github.com/grpc-ecosystem/grpc-gateway                              v1.16.0                               go-module
# github.com/gsterjov/go-libsecret                                    v0.0.0-20161001094733-a6f4afe4910c    go-module
# github.com/gtank/merlin                                             v0.1.1                                go-module
# github.com/gtank/ristretto255                                       v0.1.2                                go-module
# github.com/hashicorp/go-cleanhttp                                   v0.5.2                                go-module
# github.com/hashicorp/go-getter                                      v1.7.1                                go-module
# github.com/hashicorp/go-immutable-radix                             v1.3.1                                go-module
# github.com/hashicorp/go-safetemp                                    v1.0.0                                go-module
# github.com/hashicorp/go-version                                     v1.6.0                                go-module
# github.com/hashicorp/golang-lru                                     v0.5.5-0.20210104140557-80c98217689d  go-module
# github.com/hashicorp/hcl                                            v1.0.0                                go-module
# github.com/hdevalence/ed25519consensus                              v0.1.0                                go-module
# github.com/huandu/skiplist                                          v1.2.0                                go-module
# github.com/iancoleman/orderedmap                                    v0.2.0                                go-module
# github.com/improbable-eng/grpc-web                                  v0.15.0                               go-module
# github.com/jmespath/go-jmespath                                     v0.4.0                                go-module
# github.com/klauspost/compress                                       v1.16.7                               go-module
# github.com/kr/pretty                                                v0.3.1                                go-module
# github.com/kr/text                                                  v0.2.0                                go-module
# github.com/lib/pq                                                   v1.10.7                               go-module
# github.com/libp2p/go-buffer-pool                                    v0.1.0                                go-module
# github.com/magiconair/properties                                    v1.8.7                                go-module
# github.com/manifoldco/promptui                                      v0.9.0                                go-module
# github.com/mattn/go-colorable                                       v0.1.13                               go-module
# github.com/mattn/go-isatty                                          v0.0.20                               go-module
# github.com/matttproud/golang_protobuf_extensions                    v1.0.4                                go-module
# github.com/mimoo/StrobeGo                                           v0.0.0-20210601165009-122bf33a46e0    go-module
# github.com/minio/highwayhash                                        v1.0.2                                go-module
# github.com/mitchellh/go-homedir                                     v1.1.0                                go-module
# github.com/mitchellh/go-testing-interface                           v1.14.1                               go-module
# github.com/mitchellh/mapstructure                                   v1.5.0                                go-module
# github.com/mtibben/percent                                          v0.2.1                                go-module
# github.com/pelletier/go-toml/v2                                     v2.0.8                                go-module
# github.com/pkg/errors                                               v0.9.1                                go-module
# github.com/pmezard/go-difflib                                       v1.0.1-0.20181226105442-5d4384ee4fb2  go-module
# github.com/prometheus/client_golang                                 v1.14.0                               go-module
# github.com/prometheus/client_model                                  v0.3.0                                go-module
# github.com/prometheus/common                                        v0.42.0                               go-module
# github.com/prometheus/procfs                                        v0.9.0                                go-module
# github.com/rakyll/statik                                            v0.1.7                                go-module
# github.com/rcrowley/go-metrics                                      v0.0.0-20201227073835-cf1acfcdf475    go-module
# github.com/rogpeppe/go-internal                                     v1.11.0                               go-module
# github.com/rs/cors                                                  v1.8.3                                go-module
# github.com/rs/zerolog                                               v1.32.0                               go-module
# github.com/spf13/afero                                              v1.9.5                                go-module
# github.com/spf13/cast                                               v1.6.0                                go-module
# github.com/spf13/cobra                                              v1.8.0                                go-module
# github.com/spf13/jwalterweatherman                                  v1.1.0                                go-module
# github.com/spf13/pflag                                              v1.0.5                                go-module
# github.com/spf13/viper                                              v1.16.0                               go-module
# github.com/stretchr/testify                                         v1.8.4                                go-module
# github.com/subosito/gotenv                                          v1.4.2                                go-module
# github.com/syndtr/goleveldb                                         v1.0.1-0.20210819022825-2ae1ddf74ef7  go-module
# github.com/tendermint/go-amino                                      v0.16.0                               go-module
# github.com/tidwall/btree                                            v1.6.0                                go-module
# github.com/ulikunitz/xz                                             v0.5.11                               go-module
# go.opencensus.io                                                    v0.24.0                               go-module
# go.opentelemetry.io/otel                                            v1.19.0                               go-module
# go.opentelemetry.io/otel/metric                                     v1.19.0                               go-module
# go.opentelemetry.io/otel/trace                                      v1.19.0                               go-module
# golang.org/x/crypto                                                 v0.16.0                               go-module
# golang.org/x/exp                                                    v0.0.0-20230711153332-06a737ee72cb    go-module
# golang.org/x/net                                                    v0.19.0                               go-module
# golang.org/x/oauth2                                                 v0.13.0                               go-module
# golang.org/x/sync                                                   v0.4.0                                go-module
# golang.org/x/sys                                                    v0.16.0                               go-module
# golang.org/x/term                                                   v0.15.0                               go-module
# golang.org/x/text                                                   v0.14.0                               go-module
# google.golang.org/api                                               v0.149.0                              go-module
# google.golang.org/genproto                                          v0.0.0-20240102182953-50ed04b92917    go-module
# google.golang.org/genproto/googleapis/api                           v0.0.0-20231212172506-995d672761c0    go-module
# google.golang.org/genproto/googleapis/rpc                           v0.0.0-20240108191215-35c7eff3a6b1    go-module
# google.golang.org/grpc                                              v1.60.1                               go-module
# google.golang.org/protobuf                                          v1.32.0                               go-module
# gopkg.in/ini.v1                                                     v1.67.0                               go-module
# gopkg.in/yaml.v2                                                    v2.4.0                                go-module
# gopkg.in/yaml.v3                                                    v3.0.1                                go-module
# nhooyr.io/websocket                                                 v1.8.6                                go-module
# pgregory.net/rapid                                                  v1.1.0                                go-module
# sigs.k8s.io/yaml                                                    v1.4.0                                go-module
# stdlib                                                              go1.21.9                              go-module
# tzdata                                                              2024a-r1                              apk