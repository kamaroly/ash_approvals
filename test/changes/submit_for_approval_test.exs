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

  describe "Submit for approval change test" do
    # test "It should intercept create actions" do
    #   {:ok, record} =
    #     Category
    #     |> Ash.Changeset.for_create(:create, %{name: "Cat 1"})
    #     |> Ash.create()

    #   # Confirm nothing was saved in the databse

    #   refute Category
    #          |> Ash.Query.filter(id == ^record.id)
    #          |> Ash.exists?()

    #   #  Confirm the change has been requested
    #   assert Ash.exists?(AshApprovals.Resources.ChangeRequest)
    # end

    # test "It should intercept update actions" do
    #   {:ok, record} =
    #     Category
    #     |> Ash.Changeset.new()
    #     |> Ash.Changeset.put_context(:changes_approved?, true)
    #     |> Ash.Changeset.for_create(:create, %{name: "Category to update"})
    #     |> Ash.create()

    #   assert Category
    #          |> Ash.Query.filter(id == ^record.id)
    #          |> Ash.exists?()

    #   # Attempt update
    #   params = %{name: "Updated Category"}

    #   {:ok, _updated_cat} =
    #     record
    #     |> Ash.Changeset.for_update(:update, params)
    #     |> Ash.update()

    #   # Confirm changes are not persisted
    #   refute Category
    #          |> Ash.Query.filter(id == ^record.id)
    #          |> Ash.Query.filter(name == ^params.name)
    #          |> Ash.exists?()
    # end

    test "It should intercept destroy actions" do
      {:ok, record} =
        Category
        |> Ash.Changeset.new()
        |> Ash.Changeset.put_context(:changes_approved?, true)
        |> Ash.Changeset.for_create(:create, %{name: "Category to update"})
        |> Ash.create()

      assert Category
             |> Ash.Query.filter(id == ^record.id)
             |> Ash.exists?()

      assert :ok ==
               record
               |> Ash.Changeset.for_destroy(:destroy)
               |> Ash.destroy()
               |> dbg()

      # Confirm the record wasn't destroyed
      assert Category
             |> Ash.Query.filter(id == ^record.id)
             |> Ash.exists?()
    end
  end
end
