#!/usr/bin/env bash
cd "$(dirname "$0")"

anyscale compute-config create -n anyscale-preempt-demo -f anyscale_computeconfig.yaml
