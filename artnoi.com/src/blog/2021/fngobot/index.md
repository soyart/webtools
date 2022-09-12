Apr 16, [2021](/blog/2021/)
<H1>fngobot - a simple stock tracking Telegram bot written in Go</H1>
I have recently working on a new personal project - [@FnGoBot](https://github.com/artnoi43/fngobot), which is a Go-based (with a lil bit of Python) Telegram bot for tracking stock prices. This has always been a project I wanted to do from the time when I was working in a brokerage.

> Check it out on [my GitHub](https://github.com/artnoi43)!

# `bot.go`
The bot uses a 100% Go-based Telegram framework `telebot`, which is super easy to work with. The bot can quote stock, track it for you, or even alert when the price gets to your target price. And that's all it can do. It supports cryptocurrencies also.

# `bitkub.go` and `satang.go`
These files get API (JSON) data from Bitkub and Satang Pro respectively, to get cryptocurrency quotes from the Thai exchanges. They still need working, since the way they parse JSON is super ugly.

## Installation
Use Git to get code from my GitHub repository:

    $ git clone https://github.com/artnoi43/fnbot;

And grab the other depedencies

    $ go get golang.org/x/text/message;
    $ go get golang.org/x/text/language;

    $ go get gopkg.in/tucnak/telebot.v2;
    $ go get github.com/piquette/finance-go;

Replace the dummy API token with your bot's in `bot.go`, and run with:

    $ go run bot.go;

Or, build it and run with:

    $ go build bot.go && ./bot;

And start chatting with your bot
