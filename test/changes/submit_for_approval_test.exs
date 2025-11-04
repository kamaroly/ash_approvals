defmodule Changes.SubmitForApprovalTest do
  use ExUnit.Case

  require Ash.Query

  defmodule Category do
    use Ash.Resource,
      domain: Changes.SubmitForApprovalTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshApprovals]

    ets do
      table :categories
    end

    actions do
      default_accept [:name]
      defaults [:create, :read, :update, :destroy]

      # destroy :destroy do
      #   description "Destroy article and its comments"
      #   # Make this action primary so that it can be called with Ash.destroy without
      #   # having to mention the action to use
      #   primary? true

      #   # Before this action is executed, we'll need to delete corresponding
      #   # comments
      #   # change before_action(fn changeset, context ->
      #   #          dbg("TESTING FOR DESTROYING")
      #   #          # Continue with the change
      #   #          changeset
      #   #        end)
      # end
    end

    attributes do
      uuid_primary_key :id
      attribute :name, :string
    end
  end

  # Define a domain to hold the resource for testing
  defmodule Domain do
    use Ash.Domain, validate_config_inclusion?: false

    resources do
      resource Changes.SubmitForApprovalTest.Category
    end
  end

  describe "Create does not affect datalayer unless specified" do
    test "It should intercept create actions" do
      {:ok, record} =
        Category
        |> Ash.Changeset.for_create(:create, %{name: "Cat 1"})
        |> Ash.create()

      # Confirm nothing was saved in the databse

      refute Category
             |> Ash.Query.filter(id == ^record.id)
             |> Ash.exists?()

      #  Confirm the change has been requested
      assert Ash.exists?(AshApprovals.Resources.ChangeRequest)
    end
  end

  describe "UPDATE" do
    test "Update should skip datalayer unless specified" do
      {:ok, record} =
        Ash.create(Category, %{name: "Kamaro"}, context: %{changes_approved?: true})

      assert Category
             |> Ash.Query.filter(id == ^record.id)
             |> Ash.exists?()

      # Attempt update
      params = %{name: "Updated Category"}

      {:ok, _updated_cat} =
        record
        |> Ash.Changeset.for_update(:update, params)
        |> Ash.update()

      # Confirm changes are not persisted
      refute Category
             |> Ash.Query.filter(id == ^record.id)
             |> Ash.Query.filter(name == ^params.name)
             |> Ash.exists?()
    end
  end

  describe "Destroying" do
    test "It shoud skip underlying database layer " do
      {:ok, record} = Ash.create(Category, %{name: "Kamaro"}, context: %{changes_approved?: true})

      # Confirm datalayer behavior was run
      require Ash.Query

      assert Category
             |> Ash.Query.filter(id == ^record.id)
             |> Ash.exists?()

      # Confirm that `set_result` prevent running underlying layer
      fake_result = %Category{name: "Faked Results"}

      {:ok, fake_record} =
        record
        |> Ash.Changeset.for_destroy(:destroy)
        # |> Ash.Changeset.set_result({:ok, record})
        |> Ash.destroy(return_destroyed?: true)

      # Confirm nothing changed in the database
      assert Category
             |> Ash.Query.filter(name == ^record.name)
             |> Ash.Query.filter(id == ^record.id)
             |> Ash.exists?()
    end
  end
end
