Jul 21, [2021](/blog/2021)

# MariaDB and MySQL Workbench on Arch Linux

> This short tutorial will assume that you run the DBMS on a remote server.

## Install the packages

On the server, install `mariadb` package. On the client, install `mysql-workbech` package.

## Create database and configure the database server

On the server, create our database:

    # mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql;

Now, before starting the database server, we can configure the server to listen on the server's VPN address, in this case `10.8.0.1`:

> By default, MariaDB (and MySQL) listens on port 3306. If connection fails, it is likely that you forgot to create a user for the remote host connecting to the database.

    # /etc/my.cnf.d/server.conf
    .
    .
    .
    bind-adress=10.8.0.1
    .
    .
    .

Now we can start `mariadb.service`:

    # systemctl start mariadb.service;

And we can now connect to database (local):

    # mysql -u root -p

And create other user for our workstation host, in this case `10.8.0.69`:

> Make sure that you supply the semicolon `;` at the end of the command lines.

    MariaDB> CREATE DATABASE mydb;
    MariaDB> CREATE USER 'artnoi'@'10.8.0.69' IDENTIFIED BY 'some_pass';
    MariaDB> GRANT ALL PRIVILEGES ON mydb.* TO 'monty'@'10.8.0.69';
    MariaDB> FLUSH PRIVILEGES;
    MariaDB> quit;

Now we can connect to the database remotely:

    $ mysql -h 10.8.0.1 -u artnoi -p;

We can also use a SQL query file `queries.sql` like this:

    $ mysql -h 10.8.0.1 -u artnoi -p < queries.sql;

And direct the output to a file (e.g. `out.tab`) like:

    $ mysql -h 10.8.0.1 -u artnoi -p < queries.sql > out.tab;

## Misc.

Listing databases:

    SHOW DATABASES;

Listing tables in a database:

    USE <database_name>;
    SHOW TABLES;

Creating table:

    CREATE TABLE persons (
        id INT NOT NULL AUTO_INCREMENT,
        uuid VARCHAR(36),
        fname VARCHAR(24),
        lname VARCHAR(24),
        dob DATE,
        married BOOLEAN,
        PRIMARY KEY ( id )
    );

Showing table columns

    DESCRIBE <table_name>;

Listing users

    SELECT user FROM mysql.user;

Listing users with hostnames:

    SELECT user, host FROM mysql.user;

Listing user privileges:

    SHOW GRANTS;
    SHOW GRANTS FOR '<username>';
    SHOW GRANTS FOR '<username>'@'<host>';

You can revoke privileges with:

    REVOKE ALL PRIVILEGES ON mydb.* FROM 'admin'@'localhost';

Or remove a user with `DROP`:

    DROP USER 'admin'@'localhost';

Since there is no `UNUSE`, if we want to deselect/unuse a database, we can just `CREATE` a new one, switch to it with `USE`, and `DROP` it like:

    CREATE DATABASE dummy;
    USE dummy;
    DROP DATABASE dummy;

That's it guys, have fun!
