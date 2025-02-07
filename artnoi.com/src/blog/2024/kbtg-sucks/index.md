[Mar 9, 2024](/blog/2024/)

# KBTG sucks

[KBTG](https://kbtg.tech) is the tech arm of Thai bank [KBank](http://www.kasikornbank.com/).
Its mission is to help propel KBank with technologies, e.g.
developing end-user apps for the bank's customers, ATM software,
or the bank's own internal tools and systems.

Its premiere product, KPlus, is KBank's mobile banking app.
KPlus is known for being the fastest and the most reliable
among Thai mobile banking apps.

As a bank's retail customer, I think (and still do) highly of KPlus -
most of my banking is done through the app. Let's just say it's why
I'd thought KBTG must have been really good at software engineering,
and that it's a legitimate tech company.

This blog post will attempt to debunk that, using my 3-month
experience with the company, and why I had to leave there in a hurry.

> Note that this blog only represents my own view and experience,
> and there's a high chance that KBTG still had some few competent
> people left working for them that I had not interacted with.

## My experience

### Joining and red flags

I joined KBTG in Oct 2023 as a full-time software engineer.
My hunch during the interview with other KBTG employees raised
a lot of red flags for me (I thought the interviewers seemed dumb technically).

But I accepted the offer any way.

The first day was the orientation, and one of senior executives welcomed us
with some narcissistic theme that went something like:

> ".. we're one of the best tech companies in the SEA region.
> We now have 1.5k employees (or something), but we aim to recruit
> more people and pushed that count to 2500, so that we can be
> **the best** in SEA"..
>
> A 65 year old senior executive at, ahem, SEA's best tech companies

I kid you not, so they think they are "the best" because they have
so many people working for them.

It's like saying the Thai government is one of the best government
in the world, simply because they employ up to 2 million people,
or NK's Korean People's Army has the most fearsome combat poweress
simply because their towering number of personnel.

(Coming back to think about it,
I'd say this kind of thinking matches the speaker's level of overall
intelligence, experience, and awareness).

The fact that they thought adding people will get them closer to
their goal of being at the top also sounds very weird. Sure,
if they only acquired competent business people and engineers,
and not some nepo kid bankers, bozo engineers, or incompetent
mid-level managers.

During the orientation they kept telling us new joiners that
they only have "the best of the best" people working for them,
that everyone here is incredibly talented.

### Team

I was assigned to an all-new-joiner squad, working on the backend of
a upcoming mobile app product.

And then I learned that there are 3 tiers of SWEs at KBTG - a normal one
(e.g. me), "advanced", and senior. I was the only normal engineer
(not advanced, not senior) in the entire squad.

The app is incredibly simple - more like a front-end for SQL databases
and bank's legacy core banking software running in their mainframes.

I also learned that the project we're working had been developed
by an outsourcers for 2 years already. In late 2023, around
25-30 SWEs were working on the product, which was still in beta.

So, an outsourced company had been working on KBTG products for 2
years, and in 2023 KBTG hired more people, including me,
to ship this product within their release timeline because the
outsourced teams couldn't.

> Other squad members had joined together and worked together before.
> They all came from the same place (another Thai bank), and they all
> came here because their followed their manager. I later heard from
> a friend that their previous workplace was purging old, incompetent
> engineers, replacing them with younger, more competent new joiners.

### Worst possible code

The first time I took a look at it, I was cursing whoever
wrote that piece of shit, antichrist software.

I'm not gonna say that my code is any good, but it sure was better
than theirs.

Their code is super bad - it follows a very stupid interpretation
of "Clean Architecture", where they focused on the wrong part
about the pattern (they did not even read the book).

One of them cared so much about keeping the function body short,
so he splited a complex function into 5, all of which were not reused
at all and resulted in fragmented code that I have to move up and down
the files to understand.

In short, it was not clean at all. The only clean part about the
project's code is code directories (folders).

What's worse than the stupid pattern is the outright buggy code
written by the so-called "advanced" and senior KBTG devs. These devs
don't even know the difference between encoding and encryption.

The code never cared about concurrency bug. After 2 years of
development, **there were still no repositories had any databse
transactional control code**.

They cared so much about code coverage, yet they only wrote tests
for happy cases.

This results in bugs in every sprint demo, most of them is due to
the race conditions arising from neglect.

### Stupid architecture

> Not code structure

They are also obsessed with implementing microservices.
I have yet to find another system that had done microservice this wrong.

They some how managed to build microservice system *without* getting
any of the usual benefits rewarded by implementing the pattern.

They build highly coupled services, they always want to create new
stupid useless services, and they did not at all care about problems
in distributed systems. They never discuss read skew, write skew,
mutexes, or consensus.

The result is an abomination of a system that's highly unreliable,
difficult to debug and impossible to verify performance.

### Incompetent developers

What really ground my gears there was the people I worked with.
Most of them have "advanced" or senior titles, but none of them would
fit my personal standard for senior devs.

#### No ownership among the devs

> Of all the devs I work with here, only 3 were considered competent

All of them had no interest in having ownership of their code.
They only focused on delivering their buggy, barely-working code
at the end of the sprints.

They never mentioned the word "tech debt" too, so it's
only normal that the sprint demos usually had more failures than success.

#### Lack or very low level of intelligence

All of them that I worked with are what we call "cargo-cult developer" -
a grouping of SWEs who only do something because someone told them
it's good, without any small critical thinking efforts.

This is why they couldn't tell that their code is shit and not "clean
architecture" at all. They never thought about it - some of their senior
just came up with this stupid shit and they all said yes.

They also lack problem solving skills. One of the "advanced" idiots
ALWAYS took a snapshot of the error message and sent it to me to ask what's
happening. The worst part is those messages are very simple and straightforward,
so simple that had they posessed any normal human brain they should be able to
figure it out already (stuff like `file 'xxx.yaml' not found` or `port yyy already in use`).

Another area that will highlight their intelligence deficiency is how they
set up the test environments. The outsourcers, who had been working on
this product for 2 years, thought it was a bright idea to set up the development
environment such that the proudction SQL constraints are to be disabled
in test environment. Because, and I fucking kid you not, velocity.

Yes, they fucking skip `NOT NULL` and other foreign key constraints in
their test environment, so they would not have found bugs which would
slow them down. I'd always told them that this is bad, because query bugs
will for sure unexpectedly surface in production.

With broken dev database, developers had to write a version of the code
that operates without foreign key constraints, proper row ID,
and another version for production databases.

Some of them did not even bother to notice that code written to work
on development environment is very likely to be broken on production.

And, you guess it, they ALWAYS had database constraint-related bugs when testing
in SIT-like environments. This used to happen every week.

This SQL constraint issue, coupled with their low intellect, kept the outsourced
company from timely delivery of the product.

#### Stupid code reviews

They are hell-bent on making every code review a Netflix drama,
where stupid shit like naming, alphabet order, and other cliche, cargo-cult stuff
gets mentioned all the time, but the obvious problems like *not* handling errors,
database transactions, and mutexes are not being mentioned or cared about at all.

They don't follow any style guides, instead, they made up their own rules
based on their (possibly) JavaScript and Java backgrounds.

They always wanted to force their stupid, useless convention on me,
pointing to their style guide reference every time I signaled my unwillingness
to comply. If their style was any good or logical, I'd not complain one bit.

Even worse is when they reject my PRs citing their stupid
rules like interfaces should be defined in alphabetical order,
while their recently merged PRs also clearly violated this rule.
They ignored my comment pointing out they themselves just pushed changes
violating their rules.

When I told them that some if not most of their rules outright violate Go convention,
they ignored it, citing extra efforts.

They used to reject my code that follows Google and Uber Go style guide,
which is the one they said they followed. When I corrected them saying
none of the style guides mention or encourage their convention of camelCase filenames,
they will just say "oh, we have our own rules", and proceeding to continue to name files
like JavaScript, which led to buggy GitLab runner from case-insensitive filesystem
on the server.

These people had no idea that they are bad devs, despite having worked
in software for more than a decade. If you go to their LinkedIn profile
you'll see that they brag about how they know "CRUD", "PostgreSQL", "REST API".
One of them even spells Go (Golang) differently 5 times in their resume.
It's like applying for a manager saying you can do Excel and PowerPoint.

Yes, they are that stupid, but they think they are worthy of being called senior.

### Incompetent bank employees

This Thai bank is well known for nepotism and harbouring incompetent employees
until requirement. It's a very large bank, and most employees got to work here
because *they knew someone here*.

The BA I worked with was very incompetent - ALL business requirements I got
always had some errors abd needed to be amended (of course I was the one who
found out the BRD was shit).

Let's say the BRD had 10 lines. then 8 of them would be wrong.
We worked in 2-week sprints, and my BRDs usually stayed invalid for a full week.
This is because the BA took days to resolve one bad bullet point or line in the BRDs.

The worst thing about this is the business-side employees who knew little SQL,
but knew it enough for their managers to let them design SQL schemas. This led
to the worst SQL tables and business logic I've ever seen.

Our project owners also come from this side, and they don't think anything
like in tech companies. They sound and act like bank employees, always
implementing stupid internal processes, focus only on "delivery", which,
most of the times just meant the front-end works.

This is why our equally stupid outsourced devs had been "delivering" this
project for 2 years, yet nothing works. The secret is that these outsourced
devs only did demo with mocked back-end. I just can't fathom the stupidity
of every one of them here.

Even the incompenent KBTG devs thought that the business employees were idiots.

## KBTG is not a tech company

KBTG advertises itself as "ASEAN's leading tech company".

In reality, it's just KBank software subsidiary with a lot of incompetent people.
They manage, run, and think like a large bank. Their culture is even more
conservative than my brokerage's, which is my first job.

The CEO usually brags about how KBTG is so great, full of talents
(going so far as to say everyone working here is top talent).

He emphasizes how KBTG is actively doing AI development, while in reality,
I've yet to see any employees, code, emails discussing about AI, nor any other
cool tech stuff that he sells daily to the press.

The company does not even want to improve. They want everything to be the same.
They don't develop talents, they simply horde talents hoping that it will cure
their organization's collective stupidity.
 
# My departure

I once respected all SWEs - I used to think that 80% of devs are smart people,
and the rest being the lucky dumbsters or "script kiddies".

Joining KBTG changed that view. I now think SWE is just like any other professions.

I also hate working in very large corporations like KBank now.

These companies are too big to fail, and they have so many people.
Because they are too big to fail, they know they don't need to do everything in a smart
way. They can just throw their weight around and get profits.

This Thai bank wouldn't go bankrupt because an app is toilet material, or
if the app never launches. There's simply no need for the org to be well optimized,
or dismiss incompetent people. Some of them don't actually do anything, just
sitting around with laptop opened on their office desk.

This is why I left KBTG: I don't want to be familiarized with idiocy and incompetence.
I don't want to think that the shit they do is "good enough".

I don't want to endure seeing the least intelligent professionals I've ever seen
circlejerk themselves to dry deaths.

With all of the things I saw, I just couldn't stay. I have a feeling that
if I stayed, my own brain cells would simply rot from interacting with these people.

