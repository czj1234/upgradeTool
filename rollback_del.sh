#!/bin/bash
dropHACS=false
INSTANCEGROUP="ecm_mysql_group"
sdb -e "var CUROPR = \"dropSYSRECYCLEITEMS\"" -f cluster_opr.js
if [ "$dropHACS" = true ]; then
    sdb -e "var CUROPR = \"dropHACS\";var INSTANCEGROUP = \"${INSTANCEGROUP}\"" -f cluster_opr.js
fi