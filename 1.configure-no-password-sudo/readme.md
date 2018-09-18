1. Install expect
	```
	$ sudo yum install expect
	```
2. Edit host-ips file, add all host IPs, for example:
	```
	172.0.0.1
	172.0.0.2
	172.0.0.3
	172.0.0.4
	```
3. Edit start.sh, modify username and password to valid, for example:
	```
	username=kent
	password=******

	# ...
	```

4. Modify executable permissions
	```
	$ chmod 755 ./*
	```

5. Run the start.sh script
	```
	./start.sh
	```
