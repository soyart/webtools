Oct 23, 2022

# Introducing superwatcher

If you work for a Web3 company, then you almost certainly, at some points,
have to work with [event logs](https://goethereumbook.org/events/).

## Event logs

Event logs are, essentially, data emitted by smart contracts after certain events
(e.g. function calls) happened.

> Emitting an event log is usually not free of cost. On Ethereum and its forks, emitting
an event log costs _gas_. As a result, smart contract programmers have to decide
when and when not to emit event log.

## How event logs are useful: Uniswapv3 example

Event logs allow us to _follow_ a smart contract states.

For example, Uniswap pool computes swap rate based on the pool internal states, chiefly,
the balance of the pool's tokens.

A Uniswap pool life cycle is something like this:

> __Note: this is a highly simplified version of a DEX pool__

1. Some wallets create new Uniswap pool using the so-called _factory_ contract `Uniswapv3PoolFactory`

    > This emits event `PoolCreated` if the pool creation is successful

2. The new pool is created, and all of its states are at initial states.

3. Other wallets transfer/stake tokens into the pool,
    altering the pool internal states

    > This emits event `Transfer`, which also contains information about the transfer

4. Some users decide to do a _swap_ on the pool.

    Swap rate is computed using variables from the internal states.
    The internal states will also change after the swap.

    > This emits event `Swap`, which also contains information about the swap,
    i.e. the swap quantity and rate.

Knowing this, if we were to create a simple program to track all Uniswap pools,
and the pools' current swap rates (by keep the pool internal states ourselves
instead of calling the smart contract each time), we can do all of that simply
by processing the logs.

### Tracking `PoolCreated` event to know when new pools are created

Before we can track our pools balances (for swap rate computation), we must first
track all pools' creations. We can do this by listening specifically for event
`PoolCreated` from the `Uniswapv3PoolFactory` contract.

If we do this correctly, we should be able to know the address of every
Uniswapv3 pool ever created by this factory smart contract.

### Tracking events `Transfer` and `Swap`

After we know the addresses of the pools, we can then filter the logs from these
addresses, and we _specifically_ listens for `Transfer` and `Swap` events.

By tracking those events and updating the pool states to our own database,
we now have the inputs (pool states) for swap algorithm used by the pool.

### Calculating swap rate on our own computers

And if we have code for the pool's business logic, then we can just call the pool
function responsible for computing the swap rate, i.e. function `GetExchange`.

In Go case, we can use `abigen` to convert a Solidity or other smart contract source
to Go files. So, by using `abigen`, we can create Go version of the smart contract
that we can import `GetExchange` from.

This allows us to be virtually the off-chain pool, and we should technically be
able to do this just by following event logs.

## How to follow logs (filter logs) to do what I just explained

There are 2 ways to follow the logs. Either by _subscribing_ or by _filtering_ logs.

Subscribing to logs are not very reliable in `go-ethereum` due to chain reorgs, which
is a PIA to work with. This is why I chose to go with the _filtering_ method.

The `go-ethereum` project provides you with an Ethereum RPC client `ethclient.Client`
that has method `FilterLogs(ethereum.FilterQuery) ([]types.Log, error)` that we can
use to filter event logs. See [this tutorial](https://goethereumbook.org/event-read/)
to learn how it works.

With `FilterLogs`, we have full the control over the filter block range,
contract addresses, and log _topics_ to filter with. This means that we can literally
scan the whole blockchain if we want to, from the genesis to the current block.

But that would be needlessly expensive, hence why we will not be filtering
the whole blockchain.

So what I usually do is using a `for` loop to increment `FilterQuery.FromBlock` and
`FilterQuery.ToBlock` perpetually. The initial `FromBlock` would be the _factory
contract creation block_, or the block _when the __pool factory__ contract was deployed_.
This is different to the contract created by the pool factory (`PoolCreated`).

To track the created Uniswap LP internal states, we also use the same method `FilterLogs`.
But this time it's different, in that the contract addresses and log topics
would be different for different events.

## How superwatcher comes in

As you can see, most of the logic around tracking these pools are _filtering logs_,
and if we can have a way to inject each service's contract address and log topics
into the code doing log filtering, then we can definitely get all the interesting
event logs.

And if we some how are able to inject the so-called _handle funcs_ into the code
doing log filtering, then we can also handle _all_ of the log types.

But one thing makes this approach highly impractical - the chain reorgs. With this,
we can't just write.
