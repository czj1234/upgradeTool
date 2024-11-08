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
// 时间标识，用于创建备份目录，建议使用当前时间如 "20240101"
var DATESTR = "20240101";
// SequoiaSQL 用户
var SQLUSER = "sdbadmin";
// SequoiaSQL 用户密码
var SQLPASSWD = "sdbadmin";
// SequoiaSQL 端口号
var SQLPORT = "3306";
// 升级包
var NEWSDBRUNPACKAGE = "/opt/test/sequoiadb-5.8.2-linux_x86_64-enterprise-installer.run";
var NEWSQLRUNPACKAGE = "/opt/test/sequoiasql-mysql-5.8.2-linux_x86_64-enterprise-installer.run";
// 回滚包
var OLDSDBRUNPACKAGE = "/opt/test/sequoiadb-3.4.3-linux_x86_64-enterprise-installer.run";
var OLDSQLRUNPACKAGE = "/opt/test/sequoiasql-mysql-3.4.3-linux_x86_64-enterprise-installer.run";
// 创建的测试 SDB CS 名，SQL 的库会增加 _sql 后缀避免重复（升级前创建，避免升级过程中DDL）
var TESTCS = "testCS";
// 创建的测试 SDB CL 名，SQL 的表会增加 _sql 后缀避免重复（升级前创建，避免升级过程中DDL）
var TESTCL = "testCL"
// 回滚时是否需要安装 OM
var ROLLBACKOM = false;
// start.sh 脚本中 sdbcmart 等待节点超时时间，默认为 1300s
var STARTTIMEOUT = 1300;
