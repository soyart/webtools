Mar 30, [2022](/blog/2022/)

# What no bitches does to a MF: todong

During my last feature development, I finished my part early, and so I had a bit of free time. So I decided to practice writing clean code, with the same old to-do list REST back-end. [The code is open for thrashing on my GitHub](https://github.com/artnoi43/todong).

## Goals

I wanted maximum flexibility with data store and web frameworks, such that *one* line in the config file configures whether this code will use which data store and web frameworks at runtime.

## Results

I managed to make it. The project structure is as something like this:

<pre><code>
todong
├── assets
├── cmd
│   └── todong
├── config
├── datamodel
├── enums
├── internal
├── lib
│   ├── handler
│   │   ├── fiberhandler // fiber handlers
│   │   └── ginhandler   // gin handlers
│   ├── httpserver
│   │   ├── fiberserver  // fiber server
│   │   └── ginserver    // gin server
│   ├── middleware
│   ├── postgres
│   ├── redisclient
│   ├── redishelper
│   ├── store            // data storage
│   └── utils
└── test
</code></pre>

In the end, it does what I want it to. Data storage and handlers are completely abstracted away from package main.
