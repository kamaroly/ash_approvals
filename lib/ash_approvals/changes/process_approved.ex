defmodule AshApprovals.Changes.ProccessApproved do
  use Ash.Resource.Change

  @impl Ash.Resource.Change
  def change(%{action: %{name: :approve}} = changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &process_change_request/2)
  end

  def change(changeset, _opts, _context), do: changeset

  @impl Ash.Resource.Change
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  defp process_change_request(_changeset, record) do
    # 1. Decode the stored into an original changeset
    # 2. apply changes

    record.changeset
    |> binary_string_to_changeset()
    |> apply_changes!()

    {:ok, record}
  end

  defp binary_string_to_changeset(serialized_string) do
    serialized_string
    |> Base.decode64!()
    |> :erlang.binary_to_term()
  end

  # Apply the changes
  defp apply_changes!(%{action_type: :create} = changeset) do
    params = get_attributes(changeset.attributes)

    changeset.data.__struct__
    |> Ash.Changeset.new()
    |> Ash.Changeset.put_context(:changes_approved?, true)
    |> Ash.Changeset.for_create(changeset.action.name, params)
    |> Ash.create!()
  end

  defp apply_changes!(%{action_type: :update} = changeset) do
    params = get_attributes(changeset.attributes)

    changeset.data
    |> Ash.Changeset.new()
    |> Ash.Changeset.put_context(:changes_approved?, true)
    |> Ash.Changeset.for_update(changeset.action.name, params)
    |> Ash.update!()
  end

  defp apply_changes!(%{action_type: :destroy} = changeset) do
    changeset.data
    |> Ash.Changeset.new()
    |> Ash.Changeset.put_context(:changes_approved?, true)
    |> Ash.Changeset.for_destroy(changeset.action.name)
    |> Ash.destroy!()
  end

  defp get_attributes(attributes) do
    attributes
    |> Map.delete(:id)
    |> Map.delete(:inserted_at)
    |> Map.delete(:updated_at)
  end
end
