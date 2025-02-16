[Mar 9, 2024](/blog/2024/)

# oRm baD

> Note: this blog post is mostly about SQL ORM

After some years of programming web back-end and
internal corporate software, I've come to think very
negatively about ORM and its widespread use.

I had no problems with ORM during my first 2 years in the industry.
This is simply because most things I did with SQL back then as a
junior dev was very simple and straightforward. We rarely changed
the SQL schemas, and when we did, it was easy.

And because the product was still in early development, there's
little users to saturate our databases, and that means I had never
needed to address database latency.

All that changed when I went on to work in a bank
with very weird Oracle SQL and schemas designed by stupid BAs
who thought they were smart after taking a business people's
SQL course.

## What made ORM attractive?

To most newbie programmers, ORM seems like the right choice.

We were taught that programming is about abstraction, and that
abstraction is programming. And so we believed that we should stop
worrying about database interaction.

In Go, I was attracted to gorm due to the fact that I could just
declare my SQL table schema as well as its cardinality in the
struct type definition.

I had somehow managed to avoid learning advanced SQL for 2 years,
simply because my 1st company did not use much SQL. Plus when I had to,
I told myself I could just use ORM.

## ORM is complex

ORM frameworks are *incredibly* complex, and generally come
with opinionated assumptions about how they are going to be used.

They also hide something from us. For example, most ORMs will do
a `SELECT *` even if we only ask it to fetch a single column.
We will never know about this from code alone, *unless we log
the actual queries*.

This obscurity is bad when debugging performance issues because
simply scanning through code will mislead us to think innocently
that our code only fetches a field.

The ORM queries also get more complex with multiple joins.

Since we'll have to do this when we declare our *ORM data models*,
it gets even harder to analyze a large graph of data models with
complex relationships.

It gets worse when dealing with some niche or legacy databases,
since these databases may have some platform-specific grammar.

Some of these grammar is so niche that the driver the ORMs use don't
even support it, or the support is half-assed and buggy.

This makes injecting these vendor-specific SQL dialect clauses very
difficult when using ORM, even though most ORMs already provide features
like *suffix feature* in the API, etc.

When using ORM, the most fine-grained controls of these SQL executions
are usually done using the *suffix* stuff to specify additional query.

Another reason that ORM needlessly increases complexity for our code
is that ORM usually comes with framework-specific way to define
database interactions. Adding another "language" (the ORM definitions)
is of course going to make our code require more context to read.

## ORM is not standardized

Sometimes at my previous work, we needed to make changes to database code.
Most of the times it's due to race condition, or new features needed
complex queries.

Every time such problems came, the first thing I did was referring to the
ORM documentation, in addition to SQL articles.

This is because different ORM frameworks have different APIs,
and I never memorize ORM APIs because they aren't standardized and might
change arbitarily in new versions.

This is worlds away from SQL (the language), which is stable and is actually
worth spending some time learning. Retained SQL knowledge will get you further
than knowledge about particular ORM.

## You'll need to know SQL anyway

Some RDBMS also has its own flavor of SQL, but the most basic operations
are standardized, and this knowledge can be carried over or translated to
other RDBMS. The stuff that differs tends to be present only in advanced queries,
like sub-queries, concurrency and transactions.

This means that to properly use an RDMS, you'd first need to know SQL,
and then the DBMS-vendor-specific details, in order to be able to build a correct,
complex, performant queries.

That may sound like a lot of work, but with ORM in your code,
**you will still need to know all that stuff that non-ORM users know, plus,
the details of your ORM framework!**

This is because, whether with or without ORM, we can't come up with complex
queries without knowing SQL and the DMBS-specific details beforehand.

So when problems get complex, you'll still need to know SQL.

## Query builders

**Just learn SQL**. Knowing SQL will save you time when debugging, implementing,
or updating code that involves complex database interactions.

**But using raw SQL in code is frowned upon as bad practice**,
because of the coupling and the risk of SQL injection.

To mitigate this, we usually use *SQL query builders* to help construct the
safe, raw SQL strings.

Query builders are ubiquitous, and most languages have >1 such libraries.
But sometimes the builders do not support all the things we want to do.
What then?

The answer is **homebrewed query builde**r! We can write a small query builder
whose output can be used to inject to the builder libraries!

And since the interface of it all is just strings, we can simply develop the builder
while printing to console to verify it works. The use of strings reduces gap between
seasoned and new-to-the-language programmers, enabling better velocity when onboarding.

This gives us freedom to generate complex queries for any RDBMS, with all the
controls. We can even write separate builders for each DBMS if our queries
are super complex.

> An example of custom query builders [is gsl/sqlquery](https://github.com/soyart/gsl/tree/master/sqlquery).
> 
> It was paired with [squirrel](https://github.com/Masterminds/squirrel)
> query builder library, and only used when the squirrel does not support
> what I'm doing, or when hacking squirrel seems unintuitive.

## Conclusion

- ORM is okay for quick prototyping

    ORM allows us to just use `findOne`, `findMany`, and other convenient APIs
    to give us an idea of how data repositories should be implemented.

- ORM is okay for small apps

    ORM can be used in small projects, to avoid reinventing the wheel.

- ORM is bad for real production code

    If your company is developing its own applications, then ORM could
    be hindering velocity and introduces unintentional expensive operations.

    ORM's also hides SQL queries (which we're supposed to know) from us,
    adding another layer of complexity.

    And if you solely relied on ORM without knowing SQL,
    you'll be screwed once future changes need to involve some complex,
    performant queries with dialect clauses.

- Force yourself to know, *and use*, vanilla SQL enough such that you don't need ORM

    Knowing SQL is a must - there's no excuse for that. And we can
    then use that knowledge to write code using query builder libraries.

If the builder libraries do not cover what you're doing, you can
just write a custom one to handle that part.
