Sep 27, [2021](/blog/2021)
# How to parse JSON API data with arbitary keys in Go
Today I'll walk you through *my style* of parsing JSON API data into Go structs. I love Golang, but obviously when it comes to JSO, JavaScript is much more flexible, especially when the JSON you are working on has some what funny structure.

This article is useful when you're dealing with JSON data that's supposed to be an array, but instead they send us JSON with arbitary keys. For example, instead of sending us:

    [
        {
            "name": "apple",
            "price": 20
        },
        {
            "name": "cherry",
            "price: 10
        }
    ]

They do this instead:

    {
        "apple": {
            "price": 20
        },
        "cherry": {
            "price": 10
        }
    }

So now, let's see how we can deal with the second form of JSON in Go!

> Note that I'm a novice programmer, and that there may be other better ways to do it.

## Example JSON
The data we're going to use is from Satang, a Thai cryptocurrency exchange. [The data can be fetched at this URL](https://bitkub.com/fetch/market/ticker/).

    {
        "ADA_THB": {
            "bid": {
                "price":"76.68",
                "amount":"2.4"
            },
            "ask": {
                "price":"77.5",
                "amount":"11.5"
            }
        },"ALGO_THB": {
            "bid": {
                "price":"57.01",
                "amount":"25.61"
            },
            "ask": {
                "price":"59.98",
                "amount":"2000"
            }
        },
        .
        .
        .
    }

We are going to parse this mess of a JSON into a struct `Quote`, which looks like this:

    type Quote struct {
        Bid float64
        Ask float64
    }

If you look at the JSON closely, you'll see that `price` field is actually a string, not a float, so we must use `strconv.ParseFloat()` to parse this price string into `float64`.

And we want to write a function that returns only one `Quote` filtered by the keyword `kw`, which is the arbitary key. The function looks like this:

    func Get(kw string) *Quote {
        
        // Fetch data
        // And read response body
        
        var q Quote
        
        // Parse JSON
        // And filter for a key
        
        return &q
    }

Now, let's get to code!
### Fetching JSON
We begin by first fetching the JSON data from the remote host, and read the response body into variable `body`:

    resp, err := http.Get("https://satangcorp.com/api/orderbook-tickers/")
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}

### Unmarshal JSON into empty interface
Now that we have the JSON body, we can now create an empty interface `i` and unmarshal the fetched JSON into `i`:

    var i interface{}
	err = json.Unmarshal(body, &i)
	if err != nil {
		log.Println("Error parsing JSON: ", err)
		panic(err)
	}

### Map string to empty interface
Now that we have unmarshaled JSON into `i`, we can use map to map string (arbitary keys) to empty interface. We nap it so that we can `range` into this messy JSON!

> Note that we *only* want to get one quote from the many quotes

    /* Declare our Quote to be returned */
    var q Quote

    for arbitaryKey, jsonValue := range i.(map[string]interface{}) {
        /* arbitaryKey is a string */
        switch arbitaryKey {
        /* Only get the object with arbitary key matching kw */
        case kw:
            for key, value := range jsonValue.(map[string]interface{}) {
                /* Key is a string */
                switch key {
                case "bid":
                    for k, v := range value.(map[string]interface{}) {
                        switch k {
                        case "price":
                            q.Bid = strcov.ParseFloat(v.(string), 64)
                        }
                    }
                case "ask":
                    for k, v := range value.(map[string]interface{}) {
                        switch k {
                        case "price":
                            q.Ask = strconv.ParseFloat(v.(string), 64)
                        }
                    }
                }
            }
        default:
            fmt.Println("Quote not found in JSON")
        }
    }

    return &q

### Full function

    func Get(kw string) *Quote {
        
        resp, err := http.Get("https://satangcorp.com/api/orderbook-tickers/")
        if err != nil {
		    panic(err)
	    }
	    defer resp.Body.Close()

	    body, err := ioutil.ReadAll(resp.Body)
	    if err != nil {
		    panic(err)
	    }

        var i interface{}
	    err = json.Unmarshal(body, &i)
	    if err != nil {
		    log.Println("Error parsing JSON: ", err)
		    panic(err)
	    }
        
        var q Quote
        
        for arbitaryKey, jsonValue := range i.(map[string]interface{}) {
        /* arbitaryKey is a string */
            switch arbitaryKey {
        /* Only get the object with arbitary key matching kw */
            case kw:
                for key, value := range jsonValue.(map[string]interface{}) {
                /* Key is a string */
                    switch key {
                    case "bid":
                        for k, v := range value.(map[string]interface{}) {
                            switch k {
                            case "price":
                                q.Bid = strcov.ParseFloat(v.(string), 64)
                            }
                        }
                    case "ask":
                        for k, v := range value.(map[string]interface{}) {
                            switch k {
                            case "price":
                                q.Ask = strconv.ParseFloat(v.(string), 64)
                            }
                        }
                    }
                }
            default:
                fmt.Println("Quote not found in JSON")
            }
        }

        return &q
    }

After all this, we can see that there's still some duplicate codes. I have eliminate those duplicate code in my actual file, you can see it [here](https://github.com/artnoi43/fngobot/blob/main/fetch/satang/satang.go).

That's it guys, and some time later I may add another example to this example.
