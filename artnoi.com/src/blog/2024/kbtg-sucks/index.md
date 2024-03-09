[Mar 9, 2024](/blog/2024/)

# KBTG sucks

[KBTG](https://kbtg.tech) is the tech arm of Thai bank [KBank](http://www.kasikornbank.com/).
Its mission is to help propel KBank with technologies, e.g.
developing apps for the bank's customers, ATM software, or the bank's
internal tools.

Its premiere product is KPlus, KBank's mobile banking app.
KPlus is known for having nice UX, fast, and overall the best and
the most reliable among Thai mobile banking apps.

As the bank's retail customer, I think highly of KPlus - most
of my banking is done through the app. Let's just say it's why
I though KBTG must have been really good at software engineering,
and is a legitimate tech company owned by a bank.

This blog post will be about my bad experience and why I left.

## My experience

### Joining

I joined KBTG in Oct 2023 as a software engineer. My intuition during
the interview with other KBTG employees raised a lot of red flags
for me (I thought the interviewers seemed dumb technically).

But I accepted the offer any way.

I was assigned to a all-new-joiner squad working on some upcoming
app product. It's a very simple app - more like a front-end for
databases and bank's legacy core banking software.

I learned that there are 3 tiers of SWEs at KBTG - a normal one
(e.g. me), "advanced", and senior. I was the only squad member to
not had been an advanced SWE. Other team SWEs also joined together.
They all came from the same place (another Thai bank), and they
came here because their followed their manager.

I also learned that the project we're working has been developed
by an outsourcer company for 2 years already.

### Stupid, buggy code

The moment I cloned the code and read it, I was cursing whoever
wrote that piece of shit software. I wished them occasional comatose.

The code is super bad - it follows a very stupid interpretation
of "Clean Architecture", where they focused on the wrong part
about the pattern (they did not even read the book).

One of them cared so much about keeping the function body short,
so he splited a complex function into 5, all of which were not reused
at all and resulted in fragmented code that I have to move up and down
the files to understand.

In short, it was not clean at all. The only clean part about the
project's code is code directories.

What's worse than the stupid pattern is the outright buggy code
written by the so-called "advanced" and senior KBTG devs.

The code never cared about concurrency bug. After 2 yearts in
development, **no repositories had any databse transactional control code**.

This results in bug for every sprint demo, and I suspect
most of them is due to the concurrency problems.

### Stupid architecture

> Not code structure

They are also obsessed with microservices. And I have yet to found
another project with such stupid microservice architecture.

It's as if they map each microservice to an SQL table.

They some how managed to build microservice system *without*
any of the usual benefits from the pattern.

They build highly coupled services, they always want to create new
stupid useless services, and they did not at all care about problems
in distributed systems. They never discuss read skew, write skew,
mutexes, or consensus.

They cared so much about code coverage, yet they only tested stupid
happy cases.

The result is an abomination of a system that's highly unreliable,
difficult to debug and verify performance.

### Incompetent developers

Bug perhaps what really ground my gears there was the people I work with.
Most of them have "advanced" or senior titles, but none of them would
fit my personal standard for senior devs.

All of them had no interest in having ownership of their code.
They only focused on delivering their buggy stupid code at the end of
the sprints. They never mentioned the word "tech debt" too, so it's
only normal that the sprint demos usually had more failures than success.

They are hell-bent on stupid code reviews, where stupid shit like
naming, alphabet order, and other cliche, cargo-cult stuff.

All of them that I worked with are what we call "cargo-cult developer" -
a grouping of SWEs who only do something because someone told them
it's good, without any small critical thinking efforts.

This is why they couldn't tell that their code is shit and not "clean
architecture" at all. They never thought about it - some of their senior
just came up with this stupid shit and they all said yes.

They also lack problem solving skills. One of the "advanced" idiots
ALWAYS snapshot the error message and sent it to me to ask what caused
the errors, and those messages are very simple and straightforward that
had they had any normal human brain they should be able to figure it out
(stuff like `file not found` or `port already in use`).

Their code style is also stupid. They don't follow any style guides,
instead, they made up their own based on their (possibly) JavaScript
backgrounds.

They always wanted to force their stupid, useless convention on me,
pointing to their style guide reference. If their style was any good
or logical, I'd not complain one bit. But it was just so idiotic I had
to raise hand.

When I told them that this is incorrect convention for Go, they ignored it,
citing efforts. They used to reject my code that follows Uber Go style guide,
which is the one they said they followed. When I told them that this is
not right according to Go, Google, or Uber style guides, they simply said
"they had their own rules" and continue to name files like JavaScript,
which led to buggy GitLab runner from case-insensitive server filesystem.

These people had no idea that they are bad devs, despite having worked
in software for more than a decade. If you go to their LinkedIn profile
you'll see that they brag about how they know "CRUD", "PostgreSQL", "REST API".
One of them even spells Go (Golang) differently 5 times in their resume.

Yes, they are that stupid, but they think they are worthy of being called senior.

### Incompetent business employees

This Thai bank is well known for harbouring incompetent companies. It's a
very large bank, and most employees got to work here because
*they knew someone here*.

The BA I worked with was very incompetent - ALL business requirements I got
always had some errors that needed to be amended (of course I was the one who
found out the BRD was shit).

Let's say the BRD had 10 lines. 8 of them was wrong. We worked in 2-week sprints,
and my BRDs usually stayed invalid for a full week. This is because the BA
took days to resolve bad BRDs.

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
of every one here.

Even the incompenent devs knew that the business employees were idiots.

## KBTG is not a tech company

KBTG advertises itself as "Thailand and ASEAN leading tech company".

In reality, it's just KBank subsidiary with a lot of incompetents.
They manage, run, and think like a bank.

The CEO usually sweet talks about how KBTG is so great, full of talents
(going so far as to say everyone working here is top talent).

He emphasizes how KBTG is actively doing AI development, while in reality,
I've yet to see any employees, code, emails discussing about AI, nor any other
cool tech stuff he sells.

The company does not even want to improve. They want everything to be the same.
They don't develop talents, they simply horde talents hoping that it will cure
the organizational stupidity.
 
# My departure

With all of the things I saw, I just couldn't stay. I have a feeling that
if I stayed, my own brain cells would simply rot from interacting with these people.

I once respected all SWEs - I used to think that 80% of devs are smart people,
and the rest being the lucky dumbsters.

Joining KBTG changed that view. I now think SWE is just like any other jobs.

I also hate working in very large corporations like KBank now. These companies
are too big to fail, and they have so many people. Because they are too big
to fail, they don't need to do everything in a smart way.

This Thai bank wouldn't go bankrupt because an app is toilet material, or
if the app never launches. There's simply no need for the org to be well optimized,
or dismiss incompetent people. Some of them don't actually do anything.

This is why I left KBTG: I don't want to be familiarized with idiocy and incompetence.
I don't want to think that the shit they do is "good enough".
