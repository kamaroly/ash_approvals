defmodule AshApprovals.Changes.SubmitForApproval do
  use Ash.Resource.Change

  @doc """
  Modifies the normal behaviour and only save to the database when
  it is flagged as approved. Otherwise move it to the change
  request table which will initiate steps for the change
  requests

  1. If approved for change, proceed as normal
  2. If not approved, don't persist in the database
  """
  @impl Ash.Resource.Change
  def change(%{context: %{changes_approved?: true}} = changeset, _opts, _context) do
    changeset
  end

  def change(changeset, opts, context) do
    dbg(changeset)
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
    result = build_result(changeset)
    Ash.Changeset.set_result(changeset, {:ok, result})
  end

  defp build_result(%{action_type: :create} = changeset) do
    struct(changeset.data.__struct__, changeset.attributes)
  end

  defp build_result(changeset), do: changeset.data

  defp request_approval!(changeset, opts, context) do
    params = %{
      changeset: serialize_changeset(changeset),
      action_type: changeset.action_type,
      action: changeset.action.name,
      status: :pending,
      context: context,
      opts: Enum.into(opts, %{})
    }

    # TODO: The change request resource should be configurabl
    Ash.create!(AshApprovalsTest.ChangeRequest, params, Ash.Scope.to_opts(context))
    |> dbg()
  end

  defp serialize_changeset(changeset) do
    changeset
    |> :erlang.term_to_binary()
    |> Base.encode64()
  end
end
