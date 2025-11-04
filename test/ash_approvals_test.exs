defmodule AshApprovalsTest do
  use ExUnit.Case
  require Ash.Query
  doctest AshApprovals

  defmodule Category do
    use Ash.Resource,
      domain: AshApprovalsTest.Domain,
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
      resource AshApprovalsTest.Category
      resource AshApprovalsTest.ChangeRequest
    end
  end
end
