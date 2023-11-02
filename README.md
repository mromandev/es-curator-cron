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

Pip Packages (just for info):

boto3                 1.28.76
botocore              1.31.76
certifi               2023.7.22
charset-normalizer    3.3.2
click                 7.1.2
elasticsearch         7.17.9
elasticsearch-curator 5.8.4
idna                  3.4
jmespath              1.0.1
pip                   21.2.4
python-dateutil       2.8.2
PyYAML                5.4.1
requests              2.31.0
requests-aws4auth     1.2.3
s3transfer            0.7.0
setuptools            57.5.0
six                   1.16.0
urllib3               1.26.4
voluptuous            0.13.1
wheel                 0.37.0