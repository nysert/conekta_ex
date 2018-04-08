# ConektaEx
Conekta API Client for Elixir

## Installation

  1. Add `conekta_ex` to deps in `mix.exs`:

```elixir
def deps do
  [
    {:conekta_ex, "~> 0.1.0"}
  ]
end
```

  2. Add your `private_key` to your config file
```elixir
config :conekta_ex, :private_key, "PRIVATE_KEY"
```

## Usage
```elixir
ConektaEx.X.retrieve
ConektaEx.X.create
ConektaEx.X.update
ConektaEx.X.delete
ConektaEx.X.SUBMODEL_FN #Customer.create_source, Order.create_charge
```
Returns `{:ok, %ConektaEx.X{}}` when everything goes ok.
Returns `{:error, %ConektaEx.Error{}}` when the api returns an error.
`raise` on request error (bad request, timeout) all functions have an opts
param to change timeout `opts = [timeout: 15_000, recv_timeout: 15_000] #defaults`.


## Webhooks
When using webhooks, you will have to handle different event `type`s.
```elixir
{:ok, event} = ConektaEx.Event.decode(json)
case Map.get(event, :type) do
  "charge.paid" ->
    do_something(:charge_paid, event)

  "charge.refunded" ->
    do_something(:charge_refunded, event)

  "subscription.paid" ->
    do_something(:subscription_paid, event)

  "subscription.payment_failed" ->
    do_something(:subscription_payment_failed, event)
end
```
