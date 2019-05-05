

**ProcessMaker流程引擎Docker镜像**
 
 
### Docker 镜像制作
``` shell
# 使用multi-stage(多阶段构建)需要docker 17.05+版本支持
sudo docker build  --network=host --no-cache -t  registry.cn-shenzhen.aliyuncs.com/dev-ops/processmaker:3.3.8 .
sudo docker push registry.cn-shenzhen.aliyuncs.com/dev-ops/processmaker:3.3.8 

```
## Docker 快速启动
``` shell
#启动mysql
sudo docker run --name uwork-mysql -h uwork-mysql  --network=host  -v /data/uwork-mysql:/var/lib/mysql -v /etc/localtime:/etc/localtime -e MYSQL_ROOT_PASSWORD=uwork  --restart always -d registry.cn-shenzhen.aliyuncs.com/dev-ops/mysql:5.7.24 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
docker exec -it uwork-mysql bash
#echo 'sql_mode=""' >> /etc/mysql/mysql.conf.d/mysqld.cnf
docker restart uwork-mysql
#启动phpmyadmin
sudo docker run --name phpmyadmin -h phpmyadmin   --restart always -d -v /etc/localtime:/etc/localtime -e PMA_ARBITRARY=1 -e PMA_HOSTS=10.10.133.11 -e PMA_VERBOSES=uwork -e PMA_PORTS=3306   -p 8060:80 phpmyadmin/phpmyadmin 
#GRANT ALL PRIVILEGES ON *.* TO 'root'@'10.33.1.175' IDENTIFIED BY 'monitor_admin' WITH GRANT OPTION;   FLUSH   PRIVILEGES; 
#启动ProcessMaker
sudo docker run -d --restart=always -h processmaker  --name=processmaker -v /etc/localtime:/etc/localtime   -p 81:80   registry.cn-shenzhen.aliyuncs.com/dev-ops/processmaker:3.3.8  
```