#!/bin/bash

set -e

echo "==============: Running cluster e2e tests..."
go test ./test/e2e/clusters/... -tags=e2e
