#!/usr/bin/env bash

process_id=$(ps -ef| grep run.py  | grep -v grep | awk '{print $2}')
if [[ "${process_id}x" != "x" ]]; then
	kill $process_id
fi
