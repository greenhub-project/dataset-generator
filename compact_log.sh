#!/usr/bin/env sh

SIZE=${1:-5000}

tail -$SIZE data/dataset-generator.log > data/dataset-generator.log
