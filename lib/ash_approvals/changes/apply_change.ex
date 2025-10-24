defmodule AshApprovals.Changes.ApplyChange do
  use Ash.Resource.Change

  @impl Ash.Resource.Change
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &process_approved/2)
  end

  @impl Ash.Resource.Change
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  defp process_approved(_changeset, change_request) do
    change_request.data
    |> unserialize_changeset()
    |> approve_change_request()
    |> apply_changes!()

    {:ok, change_request}
  end

  defp unserialize_changeset(serialized_string) do
    serialized_string
    |> Base.decode64!()
    |> :erlang.binary_to_term()
  end

  defp approve_change_request(changeset) do
    Ash.Changeset.put_context(changeset, :changes_approved?, true)
  end

  defp apply_changes!(%{action_type: :create} = changeset) do
    Ash.create!(changeset)
  end

  defp apply_changes!(%{action_type: :update} = changeset) do
    Ash.update!(changeset)
  end
end
