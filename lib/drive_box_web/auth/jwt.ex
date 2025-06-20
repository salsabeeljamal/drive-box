defmodule DriveBoxWeb.Auth.JWT do
  use Joken.Config

  @impl Joken.Config
  def token_config do
    default_claims(default_exp: 24 * 60 * 60) # 24 hours
    |> add_claim("user_id", nil, &is_binary/1)
  end

  def generate_token(user_id) do
    extra_claims = %{"user_id" => user_id}
    generate_and_sign(extra_claims)
  end

  def verify_token(token) do
    verify_and_validate(token)
  end
end 