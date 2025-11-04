defmodule AshApprovals.Domain do
  use Ash.Domain

  resources do
    resource AshApprovals.Resources.ChangeRequest
  end
end
