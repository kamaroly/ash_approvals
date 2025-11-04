defmodule AshApprovals do
  @transformers [
    AshApprovals.Transformers.DisableAtomicUpdate,
    AshApprovals.Transformers.AddSubmitForApprovalChange
  ]

  use Spark.Dsl.Extension, transformers: @transformers
end
