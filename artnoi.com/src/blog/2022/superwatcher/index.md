Nov 2, 2022

# Introducing superwatcher

If you work for a Web3 company, then you almost certainly, at some points,
have to work with [event logs](https://goethereumbook.org/events/).

## Event logs

Event logs are, essentially, data emitted by smart contracts after certain events
(e.g. function calls) happened.

> Emitting an event log is usually not free of cost. On Ethereum and its forks, emitting
> an event log costs _gas_. As a result, smart contract programmers have to decide
> when and when not to emit event log.

### Why not just filter logs?

Most of the Web3 backend code revolves around log and transaction subscription,
which is fine and easy

_if_ the blockchain today is what it has always _trying_ to be - a reliable single
source of truth. This however is not the case. As of this writing, most Ethereum-like
blockchains experience what we hatefully call _chain reorg_.

Chain reorgs happen when the blockchain nodes decided that some of the produced
blocks contained frauded transactions. To discard the produced blocks, the produced
(reorged) blocks will be invalidated with a new block replacing the reorged blocks.

These new blocks and their hashes are used instead to link the current chain to
its future blocks.

So with this in mind, you should begin to see why handling a chain reorg is
cubersome and tiring. Any recent data you got from the chain has the probability
to be invalidated later by the chain itself.

## superwatcher

superwatcher is a _Go library_ for implementing Ethereum event log-filtering services.
It provides a clean and sane interface for interacting with event logs on the
Ethereum blockchain.

Baked to its core was chain reorg support. Unlike `go-ethereum` code, superwatcher
takes chain reorgs very seriously, and it expects that its users know about what
a chain reorg is and what to do when one happens.

The exposed interface that the users will implement only roughly defines 3 methods,
first one for handling filtered event logs (obviously), the second was what to
do if we know that some logs were reorged, and the third one for handling
superwatcher error.

## Status

As of 2022, superwatcher has been in beta stage. It passed tests, and it can handle
chain reorgs, but its interfaces and features are not yet stable. We hope to be able
to ship it before the end of 2023.
