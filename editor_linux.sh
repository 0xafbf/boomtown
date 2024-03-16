#!/bin/bash
# editor.sh
# Copyright Botero Tech 2024
# Created by Andrés Botero
# This script depends on the abtools submodule

# Prefer to use dedicated nvidia graphics in Linux
__NV_PRIME_RENDER_OFFLOAD=1
__GLX_VENDOR_LIBRARY_NAME=nvidia


DIRECTORY_PATH=$(dirname "$0")
"$DIRECTORY_PATH/abtools/editor.sh"
