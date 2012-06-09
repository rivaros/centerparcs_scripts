#!/bin/bash
pg_dump -h 127.0.0.1 -p 6432 -n public -Fc > ~/central.dump && echo "Full central backup made"
