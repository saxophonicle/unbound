# unofficial unbound docker image

[![Docker Pulls](https://img.shields.io/docker/pulls/klutchell/unbound.svg?style=flat-square)](https://hub.docker.com/r/klutchell/unbound/)
[![Docker Stars](https://img.shields.io/docker/stars/klutchell/unbound.svg?style=flat-square)](https://hub.docker.com/r/klutchell/unbound/)

[Unbound](https://unbound.net/) is a validating, recursive, and caching DNS resolver.

## Tags

- `1.9.3`, `latest`
- `1.9.0`

## Architectures

Simply pulling `klutchell/unbound:<version>` should retrieve the correct image for your arch, but you can also pull specific arch images via tags.

The architectures supported by this image are:

- `amd64-<version>`
- `arm32v6-<version>`
- `arm32v7-<version>`
- `arm64v8-<version>`
- `i386-<version>`
- `ppc64le-<version>`
- `s390x-<version>`

## Deployment

```bash
# run a recursive DNS server on port 53
docker run -p 53:5053/udp klutchell/unbound
```

## Parameters

- `-p 53:5053/udp` - publish udp port 5053 on the container to udp port 53 on the host
- `-v /path/to/config:/opt/unbound/etc/unbound` - (optional) mount a custom configuration directory

## Building

```bash
# print makefile usage
make help

# ARCH can be amd64, arm32v6, arm32v7, arm64v8, i386, ppc64le, s390x
# and is emulated on top of any host architechture with qemu
make build ARCH=arm32v6

# appending -all to the make target will run the task
# for all supported architectures and may take a long time
make build-all BUILD_OPTIONS=--no-cache
```

## Usage

NLnet Labs documentation: <https://nlnetlabs.nl/documentation/unbound/>

You can print the full command-line usage options by running the container.

```bash
# print general usage
docker run --rm klutchell/unbound --help
```

## Author

Kyle Harding: <https://klutchell.dev>

## Contributing

Please open an issue or submit a pull request with any features, fixes, or changes.

## Acknowledgments

This image is largely based on MatthewVance's work: <https://github.com/MatthewVance/unbound-docker>

## License

- klutchell/unbound: [MIT License](./LICENSE)
- Unbound: [BSD License](https://github.com/NLnetLabs/unbound/blob/master/LICENSE)
