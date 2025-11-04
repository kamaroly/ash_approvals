defmodule AshApprovals.Changes.SubmitForApproval do
  use Ash.Resource.Change

  @impl Ash.Resource.Change
  def change(%{context: %{changes_approved?: true}} = changeset, _opts, _context) do
    changeset
  end

  def change(changeset, opts, context) do
    dbg(changeset)

    changeset
    |> Ash.Changeset.before_action(&submit_change_for_approval(&1, opts, context))
  end

  @impl Ash.Resource.Change
  def atomic(changeset, opts, context) do
    if is_atomic_update?(changeset) do
      {:not_atomic,
       "Cannot perform AshApproval atomically. " <>
         "You need to set `require_atomic?` to `false` on your update actions."}
    else
      {:ok, change(changeset, opts, context)}
    end
  end

  defp is_atomic_update?(changeset) do
    changeset.action_type == :update and Enum.empty?(changeset.atomics) == false
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
    Ash.create!(AshApprovals.Resources.ChangeRequest, params, Ash.Scope.to_opts(context))
  end

  defp serialize_changeset(changeset) do
    changeset
    |> :erlang.term_to_binary()
    |> Base.encode64()
  end
end
