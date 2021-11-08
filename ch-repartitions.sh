#!/bin/bash

#start this script on local host
## p201i67db-pgstb01.unix.local=172.27.192.66
local_host=localhost
remote_host=172.27.192.66
clickhouse_data=/var/lib/clickhouse/data
database=shardOne
remote_database=shardOne_test
table=graphite_reverse
remote_table=graphite_reverse
partition=202110

function TestResult() {
  result_code=$1
  test_msg=$2
  if [[ $result_code == 0 ]]; then
      echo "Succeed $test_msg"
  else
      echo "Failed $test_msg"
      exit "${result_code}"
  fi
}

sudo touch '/var/lib/clickhouse/flags/force_drop_table' && sudo chmod 666 '/var/lib/clickhouse/flags/force_drop_table'

clickhouse-client  --host ${local_host} -q "ALTER TABLE ${database}.${table} DETACH PARTITION '${partition}'"
TestResult $? "alter table"

rsync -zarvh --remove-source-files -e ssh --progress --info=progress2 ${local_host}:${clickhouse_data}/${database}/${table}/detached/* ${remote_host}:${clickhouse_data}/${remote_database}/${remote_table}/detached
TestResult $? "move partition to remote server"

#rsync -zarh --remove-source-files -e ssh --progress  --info=progress2 172.27.192.66:/var/lib/clickhouse/data/shardOne_test/graphite_reverse/detached/* /var/lib/clickhouse/data/shardOne/graphite_reverse/detached/