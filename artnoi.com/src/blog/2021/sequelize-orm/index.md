Aug 22, [2021](/blog/2021)

# Sequelize ORM Command-line

Sequelize is a JavaScript ORM library that works with many DBMSs. It supports most major SQL-based DBMS software (MySQL, SQLite, PostgreSQL, etc). It is very easy to use, and suitable for newbie programmers like I am. This blog post will be about using Sequelize with MariaDB.

> This blog post makes use of the command-line utility `sequelize-cli` (`sequelize`), because I find this approach easier and less prone to human errors.

## Setting up Sequelize

First, install `sequelize`, `mysql2` (local), and `sequelize-cli` (global) for MariaDB (MySQL):

    $ npm install sequelize mysql2;
    # npm install -g sequelize-cli;

Then, initialize Sequelize:

    $ sequelize init;

## Creating database and tables

Edit Sequelize database configuration in `./config/config.json`.

Now, you can create use Sequelize to create the database for you (which is the one configured in the file in the previous step):

    $ sequelize db:create;

After database is successfully created, you can verify that the database is indeed created in your DBMS.

I then use the CLI to create tables (called models in Sequelize):

    $ sequelize model:generate --name User --attributes name:string,email:string,password:string,role:string;
    $ sequelize model:generate --name Post --attributes body:string;

## Changing attributes

By default, Sequelize creates tables with names identical to the model's name. If you want to change this behaviour, override it in `./models/<model_name.>.js`.

You can also manually add attributes (table columns) in `./model/<model_name>.js`, for example, both User and Post models have UUID attributes that were not created with the CLI. If you add your own attributes, be sure to add them to the migrations in `./migrations`. To migrate your database, run:

    $ sequelize db:migrate # Migrate database
    $ sequelize db:migrate:status # Get migration status
    $ sequelize db:migrate:undo # Revert a migration

## Coding

The models' properties such as relationship and columns can be edited after its initial generation in `./models/<Model>.js`. There are many guides online on how to do this. Everyone does it differently, so I will not be writing about it.
