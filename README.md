# cdh-hadoop-install

安装步骤文档：
- Github: [http://kentt.top/2018/09/16/cdh-hadoop-install/](http://kentt.top/2018/09/16/cdh-hadoop-install/) 
- CSDN: [https://blog.csdn.net/t894690230/article/details/82730909](https://blog.csdn.net/t894690230/article/details/82730909)

### 文件介绍

- 1.configure-no-password-sudo:
    - sudo 无密配置脚本
- 2.configure-and-check-system-env: 
    - 配置 SSH 无密登陆；
    - 配置 host 文件：确保所有主机都能正确的解析自己以及集群内其它所有主机的主机名（将覆盖原服务器节点上的文件）；
    - 配置 repostory 文件：用于内网安装；
    - 配置打开文件的最大句柄数：防止 HDFS too many open files 异常，本脚本设置为 32768；
    - 关闭 SELinux，使其状态为 disabled：启用时可能限制 SSH 免密登陆；
    - 关闭防火墙；
    - 配置 NTP 服务：集群内所有节点的时间必须同步；
    - 配置 swappiness：使 vm.swappiness = 0，以避免使用 swap 分区；
    - 禁用透明大页面压缩（Transparent HugePages / THP）：使 transparent_hugepage=never，以提升系统性能；
    - 优化 TCP 连接设置。

> 具体安装步骤请点击目录查看