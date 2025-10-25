defmodule AshApprovalsTest do
  use ExUnit.Case
  require Ash.Query
  doctest AshApprovals

  defmodule ChangeRequest do
    use Ash.Resource,
      domain: AshApprovalsTest.Domain,
      data_layer: Ash.DataLayer.Ets

    ets do
      table :change_requests
    end

    actions do
      default_accept [:changeset, :context, :opts, :status, :action, :action_type]
      defaults [:create, :read, :update, :destroy]

      update :approve do
        description "Approve an existing request and affect underlying datalayer"
        change set_attribute(:status, :approved)
        change AshApprovals.Changes.ProccessApproved
      end
    end

    attributes do
      uuid_primary_key :id
      attribute :changeset, :string, allow_nil?: false
      attribute :context, :map, allow_nil?: false
      attribute :opts, :map, allow_nil?: false
      attribute :status, :atom, default: :pending
      attribute :action, :atom, allow_nil?: false
      attribute :action_type, :atom, allow_nil?: false
      timestamps()
    end
  end

  defmodule Category do
    use Ash.Resource,
      domain: AshApprovalsTest.Domain,
      data_layer: Ash.DataLayer.Ets

    ets do
      table :categories
    end

    actions do
      default_accept [:name]
      defaults [:create, :read, :update, :destroy]
    end

    changes do
      change AshApprovals.Changes.SubmitForApproval
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
      resource AshApprovalsTest.Category
      resource AshApprovalsTest.ChangeRequest
    end
  end

  # test "1. Create does not persist data" do
  #   {:ok, record} =
  #     Category
  #     |> Ash.Changeset.for_create(:create, %{name: "Cat 1"})
  #     |> Ash.create()

  #   # Confirm nothing was saved in the databse
  #   require Ash.Query

  #   refute Category
  #          |> Ash.Query.filter(id == ^record.id)
  #          |> Ash.exists?()

  #   #  Confirm the change has been requested
  #   assert Ash.exists?(ChangeRequest)
  # end

  # test "2. It allows approved changes to proceed normally" do
  #   {:ok, record} =
  #     Category
  #     |> Ash.Changeset.new()
  #     |> Ash.Changeset.put_context(:changes_approved?, true)
  #     |> Ash.Changeset.for_create(:create, %{name: "Cat 1"})
  #     |> Ash.create()

  #   require Ash.Query

  #   assert Category
  #          |> Ash.Query.filter(id == ^record.id)
  #          |> Ash.exists?()
  # end

  # test "3. When a change request is approved it processes the change normally" do
  #   {:ok, record} =
  #     Category
  #     |> Ash.Changeset.for_create(:create, %{name: "Approved category"})
  #     |> Ash.create()

  #   # Approve the change requests
  #   change_request = Ash.read_first!(ChangeRequest)

  #   {:ok, request} =
  #     change_request
  #     |> Ash.Changeset.for_update(:approve)
  #     |> Ash.update()

  #   assert request.status == :approved
  #   assert Ash.read_first!(Category)
  # end

  test "Updates should require approval before persisting them" do
    {:ok, record} =
      Category
      |> Ash.Changeset.new()
      |> Ash.Changeset.put_context(:changes_approved?, true)
      |> Ash.Changeset.for_create(:create, %{name: "Category to update"})
      |> Ash.create()

    assert Category
           |> Ash.Query.filter(id == ^record.id)
           |> Ash.exists?()

    # Attempt update
    params = %{name: "Updated Category"}

    {:ok, updated_cat} =
      record
      |> Ash.Changeset.for_update(:update, params)
      |> Ash.update()

    # Confirm changes are not persisted
    refute Category
           |> Ash.Query.filter(id == ^record.id)
           |> Ash.Query.filter(name == ^params.name)
           |> Ash.exists?()

    # for change <- Ash.read!(ChangeRequest) do
    #   change
    #   |> Ash.Changeset.for_update(:approve)
    #   |> Ash.update!()
    # end

    # # After approval, the category should have updated
    # assert Category
    #        |> Ash.Query.filter(id == ^record.id)
    #        |> Ash.Query.filter(name == ^params.name)
    #        |> Ash.exists?()
  end
end
