Jan 25, 2022

# 🔥 FnGoBot now has a CLI!

## Why am I so delightful?

When I first wrote [FnGoBot](https://github.com/soyart/fngobot), which is my second Go program, I made a lot of mistakes that made it very difficult to change anything in the code. Everything was highly coupled, everywhere and out of place.

But after [I got a new job](/blog/2021/dev/), I have been refactoring the code to the point that I can now easily add a new quote source in 1/2 hour, or even add new interface to the bot. And I did just that.

Now that I also write tests, adding new feature or refactoring also becomes much easier.

## 📝 What I had to do

### Categorization

So first I had to identified which part of the bot is a lib, and which part a main. Then I categorized code into roughly 4 packages:

1. Package `cmd` is where the `main` programs live.

2. Package `bot` deals with bot logic, such as handling alerts, getting quotes based on source, etc.

3. Package `parse` defines a parsing function. Because both the Telegram bot and CLI versions use this package, their commands are 100% compatible.

4. Package `fetch` deals with getting quotes from remote APIs.

5. Package `enums` for enums. lol.

### Writing CLI handlers

FnGoBot interacts with users via _handlers_. And before CLI, FnGoBot had only 1 type of handlers: Telegram bot handlers.

The Telegram bot handler is an interface, but the implentation is a struct with all the fields required by a Telgram chatbot embedded. So a CLI handler should me much more simpler and minimalistic than the Telegram bot handler.

All I had to do was to create a new package `bot/handler_cli` and write code!

## Other recently FnGoBot features

### `fetch.Quoter` interface

The `fetch.Quoter` interface abstracts how quotes can be passed around to functions. It defines 3 methods: `Last()`, `Bid()`, `Ask()`.

To add a new quote source, I'll just have to parse its API data into a struct that implement this interface, and the entire FnGoBot can now use quotes from that new sources.

### Handlers management

1. Users can now see all of the handlers with `/handlers`

2. Users can also stop a running handler with `/stop <UUID>`

3. Handlers are stored per-sender in a map, so now users can only see and stop their own handlers
