#!/usr/bin/env bash

for DATE in `dateseq 2024-01-01 2024-08-03`
do
  ./wf ${DATE}
done
