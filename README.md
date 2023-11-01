# es-curator-cron

Elasticsearch v7 Curator Logstash indices retention cron job
based on: https://github.com/stefanprodan/es-curator-cron


### Run

Docker Swarm stack:

```yaml
version: "3.7"

services:
  curator:
    image: mromandev/es-curator-cron:latest
    environment:
      - "PERIOD=hourly"
      - "KEEP_DAYS=7"
      - "INDEX_PREFIX=kpf-kapsch-"
      - "INDEX_PATTERN=%Y-%d-%m"
    command: "--host elasticsearch --port 9200"
```
INDEX_PATTERN refers to timestring on filtertype age
You can set the cron `PERIOD` to 15min, hourly, daily, weekly and monthly.
