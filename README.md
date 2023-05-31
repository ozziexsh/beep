# Beep

Adds common repo methods to an ecto schema module for convenience.

## Installation

Add `beep` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:beep, "~> 0.1.0"}
  ]
end
```

## Examples

First you need to add the `use` statement to your schema module.
We will use the following module for all examples going forward:

```elixir
defmodule MyApp.Accounts.User do
  use Ecto.Schema
  use Beep.Entity,
    repo: MyApp.Repo,
    unique: [:email],
    related: [:posts]

  schema "users" do
    field :email, :string

    has_many :posts, MyApp.Accounts.Post
  end
end
```

Then you can call common repo functions without needing to use changesets or specifying the module:

```elixir
user = User.insert!(%{ email: "test@example.com" })
user = User.update!(user, %{ email: "hello@example.com" })

user = User.get(1)
user = User.get_by(email: "hello@example.com")
users = User.all()
```

You can use changesets when needed:

```elixir
user = User.get(1)

user
|> User.some_registration_changeset(data)
|> User.update()
```

Passing `related: []` to the `use` statement adds a few methods for creating/fetching related records:

```elixir
post = User.insert_posts!(user, %{ title: "Hello World" })
posts = User.posts(user)
```

If a unique field is specified as per the example module above, then a regular ecto error will be returned on conflict:

```elixir
{:ok, user} = User.insert(%{ email: "test@example.com" })
{:error, errors} = User.insert(%{ email: "test@example.com" })
```
