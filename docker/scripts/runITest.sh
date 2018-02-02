#!/bin/bash

set -e

echo "==============: Running integration tests for ... cluster"
go test ./test/integration/clusters/... -tags=integration
