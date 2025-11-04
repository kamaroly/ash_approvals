defmodule Transformers.DisableAtomicUpdateTest do
  use ExUnit.Case

  defmodule Category do
    use Ash.Resource,
      domain: Transformers.DisableAtomicUpdateTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshApprovals]

    ets do
      table :categories
    end

    actions do
      defaults [:create, :read, :update, :destroy]
    end

    attributes do
      uuid_primary_key :id
    end
  end

  # Define a domain to hold the resource for testing
  defmodule Domain do
    use Ash.Domain, validate_config_inclusion?: false

    resources do
      resource Transformers.DisableAtomicUpdateTest.Category
    end
  end

  test "It should set update action's `require_atomic?` to false" do
    assert Category
           |> Ash.Resource.Info.actions()
           |> Enum.filter(fn action ->
             # Only focus on the update actions
             case action do
               %Ash.Resource.Actions.Update{} -> true
               _ -> false
             end
           end)
           |> Enum.filter(&(&1.require_atomic? == true))
           #  Confirm all update actions don't require atomic update
           |> Enum.empty?()
  end
end
