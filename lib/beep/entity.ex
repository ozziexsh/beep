defmodule Beep.Entity do
  @moduledoc """
  Adds common repo methods to an ecto schema module for convenience.

  The following methods are added when you `use Beep.Entity`:
  - insert(!)
  - update(!)
  - all
  - get(!)
  - get_by(!)
  - for each related module specified in the `related` option (e.g. :posts):
    - insert_posts(!)
    - posts

  ## Examples

  First you need to add the `use` statement to your schema module.
  We will use the following module for all examples going forward:

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

  Then you can call common repo functions without needing to use changesets or specifying the module:

      user = User.insert!(%{ email: "test@example.com" })
      user = User.update!(user, %{ email: "hello@example.com" })

      user = User.get(1)
      user = User.get_by(email: "hello@example.com")
      users = User.all()

  You can use changesets when needed:

      user = User.get(1)

      user
      |> User.some_registration_changeset(data)
      |> User.update()


  Passing `related: []` to the `use` statement adds a few methods for creating/fetching related records:

      post = User.insert_posts!(user, %{ title: "Hello World" })
      posts = User.posts(user)

  If a unique field is specified as per the example module above, then a regular ecto error will be returned on conflict:

      {:ok, user} = User.insert(%{ email: "test@example.com" })
      {:error, errors} = User.insert(%{ email: "test@example.com" })
  """

  defmacro __using__(opts) do
    unique = Keyword.get(opts, :unique, [])
    related = Keyword.get(opts, :related, [])

    relationship_methods =
      Enum.map(related, fn rel ->
        insert_name = String.to_atom("insert_#{rel}")

        quote do
          def unquote(insert_name)(entity, attributes) do
            struct = Ecto.build_assoc(entity, unquote(rel))
            module = struct.__struct__
            unique = module.get_beep_unique()

            struct
            |> Ecto.Changeset.change(attributes)
            |> maybe_apply_unique_constraint(unique)
            |> @repo.insert()
          end

          def unquote(:"#{insert_name}!")(entity, attributes) do
            struct = Ecto.build_assoc(entity, unquote(rel))
            module = struct.__struct__
            unique = module.get_beep_unique()

            struct
            |> Ecto.Changeset.change(attributes)
            |> maybe_apply_unique_constraint(unique)
            |> @repo.insert!()
          end

          def unquote(rel)(entity) do
            entity
            |> @repo.preload(unquote(rel))
            |> Map.get(unquote(rel))
          end
        end
      end)

    quote do
      @repo unquote(opts[:repo])
      @unique unquote(unique)
      @related unquote(related)

      def get_beep_unique(), do: @unique

      Macro.expand(unquote(relationship_methods), __MODULE__)

      def all(opts \\ []) do
        @repo.all(__MODULE__, opts)
      end

      def get(id, opts \\ []) do
        @repo.get(__MODULE__, id, opts)
      end

      def get!(id, opts \\ []) do
        @repo.get!(__MODULE__, id, opts)
      end

      def get_by(clauses, opts \\ []) do
        @repo.get_by(__MODULE__, clauses, opts)
      end

      def get_by!(clauses, opts \\ []) do
        @repo.get_by!(__MODULE__, clauses, opts)
      end

      def insert(attrs) do
        struct(__MODULE__)
        |> Ecto.Changeset.change(attrs)
        |> maybe_apply_unique_constraint()
        |> @repo.insert()
      end

      def insert!(attrs) do
        struct(__MODULE__)
        |> Ecto.Changeset.change(attrs)
        |> maybe_apply_unique_constraint()
        |> @repo.insert!()
      end

      def update(entity, attrs) do
        entity
        |> Ecto.Changeset.change(attrs)
        |> maybe_apply_unique_constraint()
        |> @repo.update()
      end

      def update!(entity, attrs) do
        entity
        |> Ecto.Changeset.change(attrs)
        |> maybe_apply_unique_constraint()
        |> @repo.update!()
      end

      defp maybe_apply_unique_constraint(changeset, unique \\ @unique) do
        Enum.reduce(unique, changeset, fn field, changeset ->
          Ecto.Changeset.unique_constraint(changeset, [field])
        end)
      end
    end
  end
end
