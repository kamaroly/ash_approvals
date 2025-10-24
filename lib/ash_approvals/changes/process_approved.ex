defmodule AshApprovals.Changes.ProccessApproved do
  use Ash.Resource.Change

  @impl Ash.Resource.Change
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &process_approved/2)
  end

  @impl Ash.Resource.Change
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  defp process_approved(_changeset, record) do
    record.data
    |> binary_string_to_changeset()
    |> apply_changes!()

    {:ok, record}
  end

  defp binary_string_to_changeset(serialized_string) do
    serialized_string
    |> Base.decode64!()
    |> :erlang.binary_to_term()
  end

  defp apply_changes!(%{action_type: :create} = changeset) do
    action = changeset.action
    attributes = changeset.attributes
    params = get_params(attributes)
    context = [context: %{changes_approved?: true}]

    changeset.data.__struct__
    |> Ash.Changeset.for_create(action, params, context)
    |> Ash.create!()
  end

  defp apply_changes!(%{action_type: :update} = changeset) do
    action = changeset.action
    attributes = changeset.attributes
    params = get_params(attributes)
    context = [context: %{changes_approved?: true}]

    changeset.data.__struct__
    |> Ash.Changeset.for_update(action, params, context)
    |> Ash.update!()
  end

  defp get_params(attributes) do
    attributes
    |> Map.delete(:id)
    |> Map.delete(:inserted_at)
    |> Map.delete(:updated_at)
  end
end
