#!/bin/bash

# 获取实例组
SDBUSER=$(sdb -e "var CUROPR = \"getArg\";var ARGNAME = \"SDBUSER\"" -f cluster_opr.js)
test $? -ne 0 && echo "[ERROR] Failed to get SDBUSER from config.js" && exit 1
SDBPASSWD=$(sdb -e "var CUROPR = \"getArg\";var ARGNAME = \"SDBPASSWD\"" -f cluster_opr.js)
test $? -ne 0 && echo "[ERROR] Failed to get SDBPASSWD from config.js" && exit 1

ha_inst_group_list -u"${SDBUSER}" -p"${SDBPASSWD}" > /dev/null
test $? -ne 0 && echo "[ERROR] Failed to get HASQL instanace group from ha_inst_group_list" && exit 1

# 检查是否有多个实例组，不支持多实例组
if [ "`ha_inst_group_list -u${SDBUSER} -p${SDBPASSWD} | sed '1d' | awk '{print $1}' | uniq | wc -l`" != "1" ]; then
    echo "[ERROR] More than one instance group was detected"
fi
INSTANCEGROUP=`ha_inst_group_list -u"${SDBUSER}" -p"${SDBPASSWD}" | sed '1d' | awk '{print $1}' | uniq`
test $? -ne 0 && echo "[ERROR] Failed to get HASQL instance group name from ha_inst_group_list" && exit 1

# 创建 SDB 的测试表
sdb -e "var CUROPR = \"createTestCSCL\"" -f cluster_opr.js
# 创建 SQL 的测试表
if [[ -f '/etc/default/sequoiasql-mysql' || -f '/etc/default/sequoiasql-mariadb' ]]; then
    echo "Begin to create SQL test database and table"
    
    SQLUSER=$(sdb -e "var CUROPR = \"getArg\";var ARGNAME = \"SQLUSER\"" -f cluster_opr.js)
    test $? -ne 0 && echo "[ERROR] Failed to get SQLUSER from config.js" && exit 1
    SQLPASSWD=$(sdb -e "var CUROPR = \"getArg\";var ARGNAME = \"SQLPASSWD\"" -f cluster_opr.js)
    test $? -ne 0 && echo "[ERROR] Failed to get SQLPASSWD from config.js" && exit 1
    TESTCS=$(sdb -e "var CUROPR = \"getArg\";var ARGNAME = \"TESTCS\"" -f cluster_opr.js)
    test $? -ne 0 && echo "[ERROR] Failed to get TESTCS from config.js" && exit 1
    TESTCL=$(sdb -e "var CUROPR = \"getArg\";var ARGNAME = \"TESTCL\"" -f cluster_opr.js)
    test $? -ne 0 && echo "[ERROR] Failed to get TESTCL from config.js" && exit 1
    TESTCS="${TESTCS}_sql"
    TESTCL="${TESTCL}_sql"
    
    
    # 找出实例组下的一个 SQL 实例
    echo "Begin to check instance group ${INSTANCEGROUP}"
    if [ "`ha_inst_group_list -u"${SDBUSER}" -p"${SDBPASSWD}" --name="${INSTANCEGROUP}"`" != "" ]; then
        # 发现 ha_inst_group_list 打印间隔有问题，如果某些内容过长会导致 awk $x 出错，暂时没办法搞
        SQLHOSTARRAY=(`ha_inst_group_list -u"${SDBUSER}" -p"${SDBPASSWD}" --name="${INSTANCEGROUP}" | tail -n 1 | awk '{print $3}'`)
        SQLPORTARRAY=(`ha_inst_group_list -u"${SDBUSER}" -p"${SDBPASSWD}" --name="${INSTANCEGROUP}" | tail -n 1 | awk '{print $4}'`)
        test ${#SQLHOSTARRAY[*]} -ne 1 &&echo "[ERROR] Failed to get ${INSTANCEGROUP} HOST from ha_inst_group_list" && exit 1
        test ${#SQLHOSTARRAY[*]} -ne 1 &&echo "[ERROR] Failed to get ${INSTANCEGROUP} PORT from ha_inst_group_list" && exit 1
    else
        echo "[ERROR] Failed to find SQL HA group ${INSTANCEGROUP} in ha_inst_group_list"
        exit 1
    fi
    mysql -h"${SQLHOSTARRAY[0]}" -P "${SQLPORTARRAY[0]}" -u "${SQLUSER}" -p"${SQLPASSWD}" -e "create database ${TESTCS};"
    test $? -ne 0 && echo "[ERROR] Create database ${TESTCS} in ${SQLHOSTARRAY[0]}:${SQLPORTARRAY[0]} SQL failed" && exit 1
    mysql -h"${SQLHOSTARRAY[0]}" -P "${SQLPORTARRAY[0]}" -u "${SQLUSER}" -p"${SQLPASSWD}" -D "${TESTCS}" -e "create table ${TESTCL}(uid int,name varchar(10),address varchar(10));"
    test $? -ne 0 && echo "[ERROR] Create table ${TESTCS}.${TESTCL} in ${SQLHOSTARRAY[0]}:${SQLPORTARRAY[0]} SQL failed" && exit 1
    echo "Create table ${TESTCS}.${TESTCL} in ${SQLHOSTARRAY[0]}:${SQLPORTARRAY[0]} SQL success"
    
fi
# 保存集群升级前集合名，各个集合数据条数，域名和 HASQL 相关信息，用于升级后对比（在创建测试表之后再收集信息）
sdb -e "var CUROPR = \"collect_old\";var INSTANCEGROUP = \"${INSTANCEGROUP}\";var DATESTR = \"`date +%Y%m%d`\"" -f cluster_opr.js
