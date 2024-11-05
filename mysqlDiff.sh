#!/bin/bash

echo "Begin to diff mysql"
UPGRADEBACKUPPATH=$(sdb -e "var CUROPR = \"getArg\";var ARGNAME = \"UPGRADEBACKUPPATH\"" -f cluster_opr.js)
test $? -ne 0 && echo "[ERROR] Failed to get UPGRADEBACKUPPATH from config.js" && exit 1
test "${UPGRADEBACKUPPATH}" == "" && echo "Failed to get UPGRADEBACKUPPATH from config.js" && exit 1

if [ ! -d "${UPGRADEBACKUPPATH}" ]; then
    echo "Backup dir ${UPGRADEBACKUPPATH} does not exists, mkdir it now"
    mkdir -p "${UPGRADEBACKUPPATH}"
else
    echo "Backup dir: ${UPGRADEBACKUPPATH}"
fi

SQLUSER=$(sdb -e "var CUROPR = \"getArg\";var ARGNAME = \"SQLUSER\"" -f cluster_opr.js)
test $? -ne 0 && echo "[ERROR] Failed to get SQLUSER from config.js" && exit 1
SQLPASSWD=$(sdb -e "var CUROPR = \"getArg\";var ARGNAME = \"SQLPASSWD\"" -f cluster_opr.js)
test $? -ne 0 && echo "[ERROR] Failed to get SQLPASSWD from config.js" && exit 1
SQLPORT=$(sdb -e "var CUROPR = \"getArg\";var ARGNAME = \"SQLPORT\"" -f cluster_opr.js)
test $? -ne 0 && echo "[ERROR] Failed to get SQLPORT from config.js" && exit 1
MYSQLDIFFPATH=$(sdb -e "var CUROPR = \"getArg\";var ARGNAME = \"MYSQLDIFFPATH\"" -f cluster_opr.js)
test $? -ne 0 && echo "[ERROR] Failed to get MYSQLDIFFPATH from config.js" && exit 1
MYSQLHOSTNAMES=($(sdb -e "var CUROPR = \"getArg\";var ARGNAME = \"MYSQLHOSTNAMES\"" -f cluster_opr.js))
test $? -ne 0 && echo "[ERROR] Failed to get MYSQLHOSTNAMES from config.js" && exit 1
# IFS=',' read -r -a MYSQLDBNAMES <<< "$MYSQLDBNAMES"
mkdir -p "${UPGRADEBACKUPPATH}/mysqlDiff"
test $? -ne 0 && echo "[ERROR] Failed to mkdir ${UPGRADEBACKUPPATH}/mysqlDiff" && exit 1

# show databases in each mysql instance
for ((i = 0; i < ${#MYSQLHOSTNAMES[@]}; i++)); do
    database_list=($(mysql -h"${MYSQLHOSTNAMES[i]}" -P"$SQLPORT" -u"$SQLUSER" -p"$SQLPASSWD" -e "show databases;" | grep -vE 'Database|information_schema|mysql|performance_schema|sys'))
    echo "databases in mysql from ${MYSQLHOSTNAMES[i]}: " "${database_list[*]}"
    if [ $i -eq 0 ]; then
        MYSQLDBNAMES=("${database_list[@]}")
    fi
done

# diff mysql
for (( k = 0; k < ${#MYSQLDBNAMES[@]}; k++)); do
    diffDB=${MYSQLDBNAMES[k]}
    for ((i = 0; i < ${#MYSQLHOSTNAMES[@]}; i++)); do
        for ((j = i+1; j < ${#MYSQLHOSTNAMES[@]}; j++)); do
            instance1=${MYSQLHOSTNAMES[i]}
            instance2=${MYSQLHOSTNAMES[j]}
            savePath="${UPGRADEBACKUPPATH}/mysqlDiff/diff_${diffDB}_${instance1}_${instance2}"
            python "$MYSQLDIFFPATH" --server1="$SQLUSER":"$SQLPASSWD"@"$instance1":"$SQLPORT" --server2="$SQLUSER":"$SQLPASSWD"@"$instance2":"$SQLPORT" --difftype=sql "$diffDB":"$diffDB" --changes-for=server2 --width 150 --force --check-permission > "$savePath"
            test $? -ne 0 && echo "[ERROR] Failed to diff database[$diffDB] from $instance1 and $instance2"
            echo "Comparing database[$diffDB] from instances: $instance1 and $instance2,detail see $savePath"
        done
    done
done

echo "Begin to dump mysql"
mkdir -p "${UPGRADEBACKUPPATH}/mysqldump"
test $? -ne 0 && echo "[ERROR] Failed to mkdir ${UPGRADEBACKUPPATH}/mysqldump" && exit 1

# dump mysql
for ((i = 0; i < ${#MYSQLHOSTNAMES[@]}; i++)); do
    dumpPath="${UPGRADEBACKUPPATH}/mysqldump/dump${MYSQLHOSTNAMES[i]}"
    # -A(all databases),-d(no data),-R(Dump stored routines),-E(dump events),--triggers(Dump triggers)
    mysqldump -h"${MYSQLHOSTNAMES[i]}" -P"$SQLPORT" -u"$SQLUSER" -p"$SQLPASSWD" --skip-lock-tables -A -R -d -E --triggers > "$dumpPath"
    test $? -ne 0 && echo "[ERROR] Failed to dump mysql from ${MYSQLHOSTNAMES[i]}" && exit 1
    echo "dump mysql success,backup mysql from ${MYSQLHOSTNAMES[i]} to $dumpPath"
done


