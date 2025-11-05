defmodule Transformers.AddSubmitForApprovalChangeTest do
  use ExUnit.Case
  require Ash.Query

  defmodule Category do
    use Ash.Resource,
      domain: Transformers.AddSubmitForApprovalChangeTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshApprovals]

    ets do
      table :categories
    end

    actions do
      default_accept [:name]
      defaults [:create, :read, :update, :destroy]
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
      resource Transformers.AddSubmitForApprovalChangeTest.Category
    end
  end

  test "1. Create does not persist data" do
    {:ok, record} = Ash.create(Category, %{name: Ash.UUIDv7.generate()})
    # Confirm nothing was saved in the databse
    refute Category
           |> Ash.Query.filter(name == ^record.name)
           |> Ash.exists?()

    #  Confirm the change has been requested
    assert Ash.exists?(AshApprovals.Resources.ChangeRequest)
  end

  test "2. It allows approved changes to proceed normally" do
    {:ok, record} =
      Category
      |> Ash.Changeset.new()
      |> Ash.Changeset.put_context(:changes_approved?, true)
      |> Ash.Changeset.for_create(:create, %{name: "Cat 1"})
      |> Ash.create()

    assert Category
           |> Ash.Query.filter(id == ^record.id)
           |> Ash.exists?()
  end
end
