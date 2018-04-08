FROM elixir:1.4
COPY . .

RUN mix local.hex --force
RUN mix local.rebar
RUN mix deps.clean --all
RUN mix deps.get
RUN mix compile

ENTRYPOINT iex -S mix
