defmodule AshApprovals.Changes.SubmitForApproval do
  use Ash.Resource.Change

  @doc """
  If changes have been approved, then continue the normal journey and
  have it persisted in the database, otherwise, take the change
  through approval process first
  """
  @impl Ash.Resource.Change
  def change(%{context: %{changes_approved?: true}} = changeset, _opts, _context) do
    changeset
  end

  def change(changeset, opts, context) do
    Ash.Changeset.before_action(changeset, &submit_change_for_approval(&1, opts, context))
  end

  @impl Ash.Resource.Change
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  defp submit_change_for_approval(changeset, opts, context) do
    # 1. Submit Request
    request_approval!(changeset, opts, context)

    # 2. Prevent submitting in underlying datalayer
    records = struct(changeset.data.__struct__, changeset.attributes)
    Ash.Changeset.set_result(changeset, {:ok, records})
  end

  defp request_approval!(changeset, opts, context) do
    params = %{
      data: serialize_changeset(changeset),
      status: :pending,
      context: context,
      opts: Enum.into(opts, %{})
    }

    # TODO: The change request resource should be configurabl
    Ash.create!(AshApprovalsTest.ChangeRequest, params, Ash.Scope.to_opts(context))
  end

  defp serialize_changeset(changeset) do
    changeset
    |> Ash.Changeset.put_context(:changes_approved?, true)
    |> :erlang.term_to_binary()
    |> Base.encode64()
  end
end
