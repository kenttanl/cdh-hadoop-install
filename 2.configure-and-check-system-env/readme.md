1. install expect if not install
    ```
    sudo yum install expect
    ```

2. modify executable permissions
    ```
    $ chmod 755 config.sh
    ```

3. exec config.sh: modify directory and file permissions
    ```
    $ ./config.sh
    ```

4. config conf/hosts, , add all host IPs, for example:
	```
	172.0.0.1
	172.0.0.2
	172.0.0.3
	172.0.0.4
	```

5. config conf/config.py, update username and password, for example:
    ```python
    config={
        # if Manager_IP is '',we will take the local server as Manager.
        # for example -> 'Manager_IP':'10.1.41.231'
        'Manager_IP':''
        # if username is '', we will take the current login as user
        ,'username':'kent'
        # if password is '', we will require you input password during the execution of the script
        ,'password':'xxxxxx'
    }
    ```

6. if you will use the script to Check and config system enviroment, please update CentOS-Base.repo

7. exec checkAndUpadteOneByOne.sh, and select 1 - 9:
    ```
    $ ./checkAndUpadteOneByOne.sh

    1. syn host file
    2. syn repostory file
    3. limits check
    4. selinux check
    5. firewall check
    6. ntpd check
    7. swappiness check
    8. transparent_hugepage check
    9. optimize tcp connection setup
    10. copy files
    11. exit
    ```

You can also enter debug mod, it only shows the commands that will be executed, not really executed.

    ```
    $ ./checkAndUpadteOneByOne-debug.sh

    1. syn host file
    2. syn repostory file
    3. limits check
    4. selinux check
    5. firewall check
    6. ntpd check
    7. swappiness check
    8. transparent_hugepage check
    9. optimize tcp connection setup
    10. copy files
    11. exit
    ```

8. exec checkAndUpadte.sh (deprecated)
    ```
    $ ./checkAndUpadte.sh
    ```


    
