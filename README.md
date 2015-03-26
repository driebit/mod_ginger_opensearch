mod_ginger_opensearch
=====================

A Zotonic module for searching [OpenSearch](http://www.opensearch.org/Specifications/OpenSearch) 
APIs. 

Installation
------------

This module depends on [mod_ginger_xml](https://github.com/driebit/mod_ginger_xml),
so make sure to install that, too.

Usage
-----

```erlang
{Result, Items} = opensearch:search(
    "http://example.com/OpenSearch", % API URL
    "this AND that"                  % search terms
).
```

`Result` will contain the OpenSearch results metadata; `Items` a list of items.
You can parse those items with `xmerl`:

```erlang
lists:map(
    fun(Item) ->
        [
            Title = ginger_xml:get_value("//title", Item)
        ]
    end,
    Items
).
```

To specify the count, index and page parameters:

```erlang
{Result, Items} = opensearch:search(
    "http://example.com/OpenSearch",
    "this AND that",
    100,            % count
    10,             % start index
    2               % start page   
).
```

