#!/usr/bin/env sh
echo "Lintering"
cat Dockerfile | docker run --rm -i hadolint/hadolint hadolint --ignore DL3018 --ignore SC2035 -
echo "Structure tests"
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $PWD/structure-tests/structure-tests.yaml:/tmp/tests.yaml gcr.io/gcp-runtimes/container-structure-test test --image sinatra --config /tmp/tests.yaml
