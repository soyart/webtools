Dec 27, 2023

# Why I think ORM is bad

I had always used ORM at work for web back-end in the past,
because that's what the projects were using when I picked them up.

But at my new place, our Go code needs to use fancy Oracle database,
and the most popular ORM library for Go, gorm, lacks a production-ready
Oracle driver.

Since this is a bank, we did not have a choice but to abandon gorm.
I volunteered to migrate ORM code to use SQL builder pattern,
and removed gorm as dependency.

During the migration, I saw so many good points
