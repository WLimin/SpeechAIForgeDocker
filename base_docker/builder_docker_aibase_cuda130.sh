#!/bin/bash
docker build --progress=plain \
 -t aibase-torch291-cuda130:user \
-f Dockerfile.aibase_cuda130 \
./

