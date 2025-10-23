# AshApprovals

Extension to add four eye principles, two-man rule, dual control or what is known as maker-checker to you Ash Resources


## How It works

If added to the extension, this extension will block create, update and destroy actions on your resources, until those actions are approved 
by someone else in your application.
Steps:

1. Initiate a create, update, or destroy action type.
2. Intercept it, then serialises changeset with its data, opts and context.
3. Store the serialized changeset in the database table `change_requests`
4. Get next approver from the table `change_approvers`(user_id, step, approveable, status)
5. Send email requesting approval with the link details to the approver.
6. If all the approvers have approved the request, then effect the actual change
7. If one of the approvers reject the change request, then stop there
8. Notify the initiator

## Requirements 

For this to work effectively, the following resources must be available

1. `User` representing actor who initiate or approve requests.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ash_approvals` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ash_approvals, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ash_approvals>.

