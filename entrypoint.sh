#!/bin/sh

mkdir -p /etc/periodic/${PERIOD}

cat > /etc/periodic/${PERIOD}/0-curator <<EOF
#!/bin/sh
/usr/local/bin/curator_cli $@ \
    delete-indices \
    --ignore_empty_list \
    --filter_list '[{"filtertype":"age","source":"name","direction":"older","unit":"days","unit_count":${KEEP_DAYS},"timestring":"${INDEX_PATTERN}"},{"filtertype":"pattern","kind":"prefix","value":"${INDEX_PREFIX}"}]'
EOF

chmod +x /etc/periodic/${PERIOD}/0-curator

echo "cron: /etc/periodic/${PERIOD}/0-curator"
echo "command: $(cat /etc/periodic/${PERIOD}/0-curator)"

exec crond -f