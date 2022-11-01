Nov 2, 2022

# Introducing superwatcher

If you work for a Web3 company, then you almost certainly, at some points,
have to work with [event logs](https://goethereumbook.org/events/).

## Event logs

Event logs are, essentially, data emitted by smart contracts after certain events
(e.g. function calls) happened.

> Emitting an event log is usually not free of cost. On Ethereum and its forks, emitting
an event log costs _gas_. As a result, smart contract programmers have to decide
when and when not to emit event log.

### Why not just filter logs?

Most of the Web3 backend code revolves around log and transaction subscription, which is fine and easy
_if_ the blockchain today is what it has always _trying_ to be - a reliable source of truth. This however
is not the case. As of this writing, most Ethereum-like blockchains experience what we hatefully call _chain reorg_.

Chain reorgs happen when the blockchain nodes decided that some of the produced blocks contained
frauded transactions. To discard the produced blocks, the produced (reorged) blocks will be
invalidated with a new block replacing the reorged blocks.

These new blocks and their hashes are used instead to link the current chain to its future blocks.

So with this in mind, you should begin to see why handling a chain reorg is cubersome and tiring.
Any recent data you got from the chain has the probability to be invalidated later by the chain itself.

## superwatcher

superwatcher is a _Go library_ for implementing Ethereum event log-filtering services. It
provides a clean and sane interface for interacting with event logs on the Ethereum blockchain.

Baked to its core was chain reorg support. Unlike `go-ethereum` code, superwatcher takes chain reorgs
very seriously, and it expects that its users know about what a chain reorg is and what to do when one happens.

The exposed interface that the users will implement only roughly defines 3 methods,
first one for handling filtered event logs (obviously), the second was what to do if we know that some logs were reorged,
and the third one for handling superwatcher error.

### superwatcher internals

I view superwatcher as 3 separate components: (1) the log emitter, (2) the emitter client, and (3) the superwatcher engine.

1. Log emitter

    The log emitter emits logs (yup). It is initialized with some contract addresses and log topics, which would then be
    used to filter only the logs matching these critetia.

    It loops to filter logs in a sliding window fashion, to catch chain reorgs obviously. At the end of each loop, it emits
    (publishes) the result to whoever is listening on the right channel, which, for most of the time, is its client.

2. Log emitter client
    
    The log emitter client (emitter client) is the consumer for the emitter. When initialized together, the logs flow from
    the emitter to the client via a Go channel. The emitter client inspects the result and the channels, before returning the
    result to whoever embeds it. It also syncs the emitter loop, meaning that the emitter will not advance if the emitter client
    does not instruct it to do so.

    Using the emitter client helps abstract the emitter emitting logic away from our other code.

3. The engine

    The superwatcher engine is the star of the show. It embeds the emitter client, and uses injected service methods to process
    logs and chain reorgs. It also keeps some states and metadata, usually log history, to determine what to do with the current log.

    Injecting service code into the engine can be done by initializing the engine with a struct implementing `ServiceEngine` interface.
    The `ServiceEngine` was designed to support middleware-like designs, that is, we can wrap one service engine inside another,
    or have multiple service _sub-engines_ that gets wrapped by a _router_ or _main service engine_ and so on.

    The engine syncs with the emitter via the emitter client.
