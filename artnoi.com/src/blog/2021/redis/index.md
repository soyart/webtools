Oct 2, [2021](/blog/2021/)
# Some popular Redis commands
Redis is an in-memory data structure store, usually used as a in-memory key-value database and caching. [The commands](https://redis.io/commands) are case-insensitive. To run the Redis client, use `redis-cli`.
# Quit Redis CLI
Use `QUIT` to quit from Redis CLI

    QUIT

# Selecting different Redis logical databases
The databases are zero-indexed and defaults to `0`. To work on different database, use `SELECT`:

    SELECT <index>

# Flush Redis
To flush all data store, use `FLUSHALL`

    FLUSHALL

# List all keys
    
	KEYS <pattern>

You can use wildcard `*` to list all keys, or combine the wildcard with a pattern similar to how you would in a UNIX shell.
# Check if keys exist
We can check if keys exist with `EXISTS`:

    EXISTS <key> [key..]

This returns `1` if it does exist, and `0` otherwise.
# Key deletion
We can simply delete key-value pairs with `DEL`:

    DEL <key> [key..]

# Expiration
We can specify expiration time with `EXPIRE`:

    EXPIRE <key> <seconds>

And get TTL with:

    TTL <key>

A positive TTL indicates the remaining time-to-live for the key, while `-1` indicates that the data has no expiration, and `-2` indicates that the key has expired.

If absolute expiration time is needed, use `EXPIREAT`, which is similar to `EXPIRE` but it takes UNIX timestamps.
# Strings
Usually Redis stores string data, or lists of strings. For a simple key-value data store and retrievial, use `SET` to set a value for a key, and `GET` to retrieve value:

    SET <key> <value>
	GET <key>

We can combine `SET` and `EXPIRE` into `SETEX`:

    SETEX <key> <second> <value>

For list of strings, we can insert data with `LPUSH` or `RPUSH`. `LPUSH` pushes data to the left of the array, while `RPUSH` does the exact opposite:

    LPUSH <keys> <element> [element..]
    RPUSH <keys> <element> [element..]

The elements are pushed in the order they are given at the command-line. For example, the following command:

	LPUSH friends john jane mark mike

Results in this data structure:

    mike mark jane john

We can get the values in the list with `LRANGE`:

    LRANGE <key> <start> <end>

Start and end values are zero-indexed, and negative value is allowed. To get all the element values in a key, use `0` as the start index `-1` as the end:

    LRANGE <key> 0 -1

We can remove (i.e., pop) elements in a list with `LPOP` or `RPOP`:

    LPOP <key> [count]
    RPOP <key> [count]

If no `count` is given, it pops the first item to the left or to the right. For example, if we have this data:

    mike mark jane john

And we do:

    RPOP friends 2

`john` is removed first, and then `jane`.
# Sets
Sets are collection of unique members. They are not indexed the way lists are. We can use `SADD` to create and add members to a set:

    SADD <key> <member> [member..]

We can get the members of a set with `SMEMBERS`"

    SMEMBERS <key>

And we can remove member from a set with `SREM`:

    SREM <key> member [member..]

Remember that set members are unique. Adding a duplicate member will throw an error
# Hash
Hash store field-value pairs within a key. We can create and set the field-value pairs with `HSET`:

    HSET <key> <field> <value> [field value..]

We can get the value stored in field with:
 
    HGET <key> <field>

We can also use `HGETALL` to retrieve all data (both fields and values) from the hash:

    HGETALL <key>

For example, let's say we created a hash with

    HSET person name Prem age 25

When you use `HGETALL`, the fields are returned before their respective values like so:

    1) "name"
    2) "Prem"
    3) "age"
    4) "25"

We can delete a field with `HDEL`:

    HDEL <key> <field> [field..]

And check if a field exists with `HEXISTS`, whose return values are identical to `EXISTS`:

    HEXISTS <key> <field>

That's it guys, cheers.
