Feb 27, [2023](/blog/2023/)

# My experience with Rust

I promised myself back in 2021 to learn Rust in 2022. That did not happen.
Instead, I found myself overwhelmed by the [Go library development](/blog/2022/superwatcher/)
at my work.

After the core development of the library was done, I gained a bit of free time.
So I bough a book on Rust, read through all of its 700 pages, and have since started
working on Rust.

After a week with Rust, I just liked it. The developer experience is unmatched
once you learn to move past the mystifying bits of Rust - lifetimes and ownership.

Here is why I like Rust.

## Memory safety

I believe Rust's memory safety contract to be the main barrier to Rust for developers
who only used GC-ed languages, which I was one.

But once you start to understand the rationale behind Rust's novel contracts,
you begin to appreciate these Rust-specfic rules. And once your code compiles in
safe Rust, you can rest assured that there'd be no memory bugs in your programs,
which is a huge bless.

In my very limited experience as a Go developer - I learned that "business logic"
bugs are easy to find and reason about. But memory bugs? These guys are very catch
and required much more elaborate debugging. And it would be even more annoying if
the code is concurrent!

With the compiler watching your back, you can be a bit more confident that your
Rust program will be free of any data race, and every object you share across threads
will always be wrapped in some kind of concurrency primitives so that it's clear
to the programmers.

## Solid type system

Rust types are out of this world. You can have algebaric types, enums with values,
and powerful *trait*s (Rust's version of interface), generics, and lifetime annotation.

## Ergonomics

Traits are super useful to me in Rust. Some ergonomic traits like `AsRef`, `Deref`,
`From` are super useful when composing any type or function signatures in your application.

Traits like `Iterator` unifies so many actions we have been doing in the for-loop
in a very coherent, functional ways.

## Balanced look and feel

Rust is a multi-paradigm language with, IMO, combines the best traits from each paradigm.
You want to do this imperatively? Done. You want to lazily chain methods together
and avoid keeping states? That you can do. You want to exercise your OOP
composing skill? Rust can do that too, albiet without a `class` keyword.

With this look and feel, you can choose any paradigm to solve any specific problems.

## Rust macros

Rust macros are nice. Although I haven't yet learn Rust's procedural macros, I still
think Rust macros are pretty cool especially for generating code.

## Rust attributes

Attributes are great. They can be used to do anything from generating code, instructing
the compiler to use different implementations or representation, platform-specific
code, and many more. It is like 1000x times more powerful than Go's struct tags.

## Tooling

Rust's tools are very nice. The toolchain comes complete with formatter, linter,
package manager and the best compiler I've ever used.
