# ecto_paginator

## Concept

Secure cursor-based pagination for Ecto.

This work is based on https://github.com/duffelhq/paginator.

Original Paginator encoded cursors with base64. In most cases the cursor contains the id field from the table. This is a serious security issue.

EctoPaginator encrypts cursors with AES-128-GCM to hinder reverse engineering app's data structure.

You can choose to either use app-wide encryption key or provide a function, which returns a key given on a current context.

### Cursor-based (a.k.a keyset pagination)

This method relies on opaque cursor to figure out where to start selecting records. It is more performant than
`LIMIT-OFFSET` because it can filter records without traversing all of them.

It's also consistent, any insertions/deletions before the current page will leave results unaffected.

## Getting started

```elixir
defmodule MyApp.Repo do
  use Ecto.Repo,
    otp_app: :my_app,
    adapter: Ecto.Adapters.Postgres

  use EctoPaginator
end

query = from(p in Post, order_by: [asc: p.inserted_at, asc: p.id])

page = MyApp.Repo.paginate(query, cursor_fields: [:inserted_at, :id], limit: 50)

# `page.entries` contains all the entries for this page.
# `page.metadata` contains the metadata associated with this page (cursors, limit, total count)
```

## Install

Add `EctoPaginator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:ecto_paginator, "~> 0.6"}]
end
```

## Configure encryption

Crypto engine needs some configuration to run properly.

You need to set up either

```elixir
config :ecto_paginator, :default_encryption_key, "1234123412341234"
```

(key length = 16 bytes)

or

```elixir
config :ecto_paginator, :key_fun, &MyApp.MyMod.key_func/0
```

in your config files.

## Usage

1. Add `EctoPaginator` to your repo.

   ```elixir
   defmodule MyApp.Repo do
     use Ecto.Repo,
       otp_app: :my_app,
       adapter: Ecto.Adapters.Postgres

     use EctoPaginator
   end
   ```

2. Use the `paginate` function to paginate your queries.

   ```elixir
   query = from(p in Post, order_by: [asc: p.inserted_at, asc: p.id])

   # return the first 50 posts
   %{entries: entries, metadata: metadata} = Repo.paginate(query, cursor_fields: [:inserted_at, :id], limit: 50)

   # assign the `after` cursor to a variable
   cursor_after = metadata.after

   # return the next 50 posts
   %{entries: entries, metadata: metadata} = Repo.paginate(query, after: cursor_after, cursor_fields: [{inserted_at: :asc}, {:id, :asc}], limit: 50)

   # assign the `before` cursor to a variable
   cursor_before = metadata.before

   # return the previous 50 posts (if no post was created in between it should be the same list as in our first call to `paginate`)
   %{entries: entries, metadata: metadata} = Repo.paginate(query, before: cursor_before, cursor_fields: [:inserted_at, :id], limit: 50)

   # return total count
   # NOTE: this will issue a separate `SELECT COUNT(*) FROM table` query to the database.
   %{entries: entries, metadata: metadata} = Repo.paginate(query, include_total_count: true, cursor_fields: [:inserted_at, :id], limit: 50)

   IO.puts "total count: #{metadata.total_count}"
   ```

## Indexes

If you want to reap all the benefits of this method it is better that you create indexes on the columns you are using as
cursor fields.

### Example

```elixir
# If your cursor fields are: [:inserted_at, :id]
# Add the following in a migration

create index("posts", [:inserted_at, :id])
```

## Notes

- This method requires a deterministic sort order. If the columns you are currently using for sorting don't match that
  definition, just add any unique column and extend your index accordingly.
- You need to add order_by clauses yourself before passing your query to `paginate/2`. In the future we might do that
  for you automatically based on the fields specified in `:cursor_fields`.
- There is an outstanding issue where Postgrex fails to properly builds the query if it includes custom PostgreSQL types.
- This library has only be tested with PostgreSQL.

### Running tests

Clone the repo and fetch its dependencies:

```
$ git clone https://github.com/agleb/ecto_paginator.git
$ cd ecto_paginator
$ mix deps.get
$ mix test
```

## LICENSE

See [LICENSE](https://github.com/agleb/ecto_paginator/blob/master/LICENSE.txt)
