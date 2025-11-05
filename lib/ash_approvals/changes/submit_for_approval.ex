defmodule AshApprovals.Changes.SubmitForApproval do
  use Ash.Resource.Change

  @impl Ash.Resource.Change
  def change(%{context: %{changes_approved?: true}} = changeset, _opts, _context) do
    changeset
  end

  def change(changeset, opts, context) do
    request_approval!(changeset, opts, context)
    Ash.Changeset.set_result(changeset, {:ok, build_result(changeset)})
  end

  @impl Ash.Resource.Change
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
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
