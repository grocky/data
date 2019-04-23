#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT=$(realpath "${DIR}/..")

export PATH="${PATH}:${PROJECT_ROOT}/bin"
