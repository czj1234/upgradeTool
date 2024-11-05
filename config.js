// SequoiaDB 用户
var SDBUSER = "sdbadmin";
// SequoiaDB 用户对应的密码
var SDBPASSWD = "sdbadmin";
// COORD 节点主机
var COORDADDR = "localhost";
// COORD 节点端口号
var COORDSVC = "11810";
// 所有机器都可用的备份目录，注意此目录下不要有其他文件，否则可能会被覆盖
var UPGRADEBACKUPPATH = "/sdbdata/data01/upgradebackup";
// SequoiaSQL 用户
var SQLUSER = "sdbadmin";
// SequoiaSQL 用户密码
var SQLPASSWD = "sdbadmin";
// SequoiaSQL 端口号
var SQLPORT = "3306";
// 升级包
var NEWSDBRUNPACKAGE = "/opt/run/sequoiadb-5.8.2-linux_x86_64-enterprise-installer.run";
var NEWSQLRUNPACKAGE = "/opt/run/sequoiasql-mysql-5.8.2-linux_x86_64-enterprise-installer.run";
// 回滚包
var OLDSDBRUNPACKAGE = "/opt/run/sequoiadb-3.2.7-linux_x86_64-enterprise-installer.run";
var OLDSQLRUNPACKAGE = "/opt/run/sequoiasql-mysql-3.2.7-linux_x86_64-enterprise-installer.run";
// 创建的测试 SDB CS 名，SQL 的库会增加 _sql 后缀避免重复（升级前创建，避免升级过程中DDL）
var TESTCS = "testCS";
// 创建的测试 SDB CL 名，SQL 的表会增加 _sql 后缀避免重复（升级前创建，避免升级过程中DDL）
var TESTCL = "testCL"
// MySQLDiff工具路径
var MYSQLDIFFPATH = "/home/sdbadmin/MySQLDiff/mysqldiff.py";
// mysql实例主机名(默认以配置的第一个主机上的所有数据库进行对比，需要注意第一个主机名的配置)
var MYSQLHOSTNAMES = ["jsdb02", "jsdb04", "jsdb06", "hrjs1db3", "hrjs1db6", "hrjs1db9"];
// start.sh 脚本中 sdbcmart 等待节点超时时间，默认为 1300s
var STARTTIMEOUT = 1300;
