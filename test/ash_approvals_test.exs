defmodule AshApprovalsTest do
  use ExUnit.Case
  doctest AshApprovals

  defmodule Category do
    use Ash.Resource,
      domain: AshApprovalsTest.Domain,
      data_layer: Ash.DataLayer.Ets

    ets do
      table(:categories)
    end

    actions do
      defaults([:read, :update, :destroy])

      create :create do
        accept [:name]
        primary? true
        change AshApprovals.Changes.SetResults
      end
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:name, :string, allow_nil?: false)
      timestamps()
    end
  end

  # Define a domain to hold the resource for testing
  defmodule Domain do
    use Ash.Domain

    resources do
      resource(AshApprovalsTest.Category)
    end
  end

  test "greets the world" do
    Category
    |> Ash.Changeset.for_create(:create, %{name: "Cat 1"})
    |> Ash.create!()
    |> dbg()
  end
end
