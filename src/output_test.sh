#!/bin/bash

### testing output log

## for real directory: ../output/out.log
LOGFILE=./out.log


echo "$(date "+%m%d%Y %T"): Start" >> $LOGFILE


echo "$(date "+%m%d%Y %T"): End" >> $LOGFILE
