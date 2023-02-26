Sep 25, [2021](/blog/2021/)

# Why I prefer Go as a beginner developer

I have learned programming since 2020, and now I can code fluently in Go, JavaScript, and can somehow write Python and Rust although not as well as the first two languages. The reason I like Go better compared to these languages maybe because it is my first language. But after spending some time to think about it, I have come to realize that it's much more than that.

## What I like about Go

### No semicolon

This makes the overall experience much better.

### No unused variables

When I write JavaScript, sometimes when I don't follow TDD, I create unused names like imports and variables. Go doesn't allow unused variables, so every thing counts and serves a purpose in the program.

### Performance and build time

Although Go is garbage-collected and thus is not suitable for writing operating systems, Go is actually very high performace. It has great built-in support for concurrency too, so it is perfect for writing a high performance backend program, which is what I do. It also builds very fast, when compared to Rust - another popular modern compiled language without the garbage compiled (lol).

### Great standard library

Go ships with amazing standard library that enables you to write sophisticated software. The extra library (`golang.org/x`) is also super useful and inclusive. For example, my first Go program, [gfc](https://github.com/artnoi43/gfc), is written using only Go standard library and the extra ones. You can build a HTTP client or server using only the standard library.

### Nice pattern

In Go files, you first have your `package`, then `import`. This is great, because you'll know right away what package you are working with and what external files are being imported.

### Explicit fallthrough

When using a switch case, I almost always `break`. So it is nice that I don't have to `break` every time I write a case in Go because it `break`s by default. In rare cases where I have to fallthrough, I can easily do that too.

### Easy-to-read, and limited syntax

We read code more than we write it - that's just a fact. And the fact that Go reads very easily and features limited syntactic sugar has helped me read Go. Compared to JavaScript, Go syntax is much cleaner and less confusing. In Go, you can declare a function like:

    func sum(a int, b int) int {
        return a + b
    }

Or

    var sum = func(a int, b int) int {
        return a + b
    }

These 2 ways are similar enough not to cause any confusion, and the function signature also give us just enough information about the function. Compare this to JavaScript, where you can write a function in many ways, for example:

    function sum(a, b) {
        return a + b;
    }

Or

    const sum = (a, b) => {
        return a + b;
    }

Or

    const sum = (a, b) => a + b

Because there are many ways to write the same function, different developers will use different styles - **and that makes it a little bit more difficult to read other people's JavaScript code**. This is why I prefer Go's syntax - because it has minimum syntactic sugar.

## What I don't like about Go

### Error handling

Go is notorious for its poor error handling. Most of my error handling in Go goes like this:

    result, err := someFunc(someInput) {
        panic(err)
    }

Yes, you can return the error to propagate the error with something like:

    result, err := sumFunc(someInput)
    if err != nil {
        return err
    }

But this is nothing like JavaScript, where you can do things like:

    try {
        doSomething();
        doSomethingAgain();
        doSomethangAgain();
    } catch (err) {
        // Do your error handling here
        console.error(err);
    };

### Compiler not as informative vs Rust's

If I had not written Rust, I wouldn't know how a compiler can be life-saving. But too bad, I learned Rust, and I wish Go compiler could be a little bit more helpful.

## Bottom line

I think I'd stuck with Go for a while. It is nice and easy language for a beginner. In the mean time, I will also continue to learn more of Rust, and continue to write JavaScript because that what Thai programmers write. I don't hate JavaScript or Node, but I just like Go much, much more.
