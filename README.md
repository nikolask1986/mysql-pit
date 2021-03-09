# mysql-pit-recovery
## Prerequisites:
- Docker
- Docker-compose
## Usage:
Edit the .env file with the required environment variables. 
```sh
docker-compose up
```
By executing the above command the following steps are going to be created:
- A mysql container will run using the environment variables from the .env file. 

Once the container is up and running lets connect to it and populate the database with some data.
```sh
docker exec -it mysql1 bash #connect to the container
mysql -u root -p # login to the database

#Then populate the database with data using the sql commands below: 
CREATE DATABASE IF NOT EXISTS db1;
CREATE DATABASE IF NOT EXISTS db2;
USE db1;
CREATE TABLE IF NOT EXISTS nameDB (
id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
firstname VARCHAR(30) NOT NULL,
lastname VARCHAR(30) NOT NULL,
email VARCHAR(50),
reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
INSERT INTO nameDB (firstname, lastname, email)
VALUES ('Karl', 'Brady', 'karl.brady@email.com');
```
Then, make sure the management script is executable
```sh
chmod +x management.sh
```
Run the script
```sh
./management.sh
```
![Alt text](/screenshots/pit1.png?raw=true "script welcome screenshot")

Option 1 will show all the binary logs of the database

![Alt text](/screenshots/pit2.png?raw=true "script welcome screenshot")

Option 2 will show the current active binary log of the database

![Alt text](/screenshots/pit3.png?raw=true "script welcome screenshot")

Option 3 will let you choose a binary log. Select option 3 and type **mysql-bin.000003**

![Alt text](/screenshots/pit4.png?raw=true "script welcome screenshot")

Option 4 will show the selected binary log. 
Now, lets go back to the database and add another user to the table:
```sh
INSERT INTO nameDB (firstname, lastname, email)
VALUES ('Julie', 'Phelan', 'julie.phelan@email.com');
```
Go back to the management script and select option 4 again. The last part of the log should be the user we just created. 

![Alt text](/screenshots/pit5.png?raw=true "script welcome screenshot")

Lets try to create a new database before the last user was created. To do that, we need the start and end point of the log , in this case 431 to 1164
Select option 5 and enter the values.

![Alt text](/screenshots/pit6.png?raw=true "script welcome screenshot")

Now go back to the mysql container and check if the database was created

![Alt text](/screenshots/pit7.png?raw=true "script welcome screenshot")

When the database comes to a point which is unmanageable to view the whole binary log, the script can be modified to use time specific search by using:
```sh
mysqlbinlog --start-datetime="<start_time>" --stop-datetime=”<end_time>"   --verbose /var/lib/mysql/<binary_log>
```
**ONLY TO BE USED LOCALLY FOR DEVELOPMENT PURPOSES**
