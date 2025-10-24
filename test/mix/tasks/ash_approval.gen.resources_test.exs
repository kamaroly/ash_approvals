defmodule Mix.Tasks.AshApproval.Gen.ResourcesTest do
  use ExUnit.Case, async: true
  import Igniter.Test

  test "it warns when run" do
    # generate a test project
    test_project()
    # run our task
    |> Igniter.compose_task("ash_approval.gen.resources", [])
    # see tools in `Igniter.Test` for available assertions & helpers
    |> assert_has_warning("mix ash_approval.gen.resources is not yet implemented")
  end
end
