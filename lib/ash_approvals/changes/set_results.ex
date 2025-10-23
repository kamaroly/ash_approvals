defmodule AshApprovals.Changes.SetResults do
  use Ash.Resource.Change

  @impl Ash.Resource.Change
  def change(changeset, _opts, _context) do
    Ash.Changeset.before_action(changeset, &maybe_seek_approval/1)
  end

  defp maybe_seek_approval(changeset) do
    params = struct(changeset.data.__struct__, changeset.attributes)
    Ash.Changeset.set_result(changeset, {:ok, params})
  end
end
