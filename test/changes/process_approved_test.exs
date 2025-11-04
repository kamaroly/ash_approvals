defmodule Changes.ProcessApprovedTest do
  use ExUnit.Case
  require Ash.Query

  defmodule Category do
    use Ash.Resource,
      domain: Changes.ProcessApprovedTest.Domain,
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
      attribute :name, :string, allow_nil?: false
      timestamps()
    end
  end

  # Define a domain to hold the resource for testing
  defmodule Domain do
    use Ash.Domain, validate_config_inclusion?: false

    resources do
      resource Changes.ProcessApprovedTest.Category
    end
  end

  test "It effects changes when approved" do
    category_params = %{name: "Approved category"}

    {:ok, record} =
      Category
      |> Ash.Changeset.for_create(:create, category_params)
      |> Ash.create()

    # Approve the change requests
    change_request = Ash.read_first!(AshApprovals.Resources.ChangeRequest)

    {:ok, request} =
      change_request
      |> Ash.Changeset.for_update(:approve)
      |> Ash.update()

    assert request.status == :approved

    assert Category
           |> Ash.Query.filter(name == ^category_params.name)
           |> Ash.exists?()
  end
end
