defmodule BlockScoutWeb.AddressContractVerificationController do
  use BlockScoutWeb, :controller

  alias Explorer.Chain.SmartContract
  alias Explorer.SmartContract.{Publisher, Solidity.CompilerVersion}

  def new(conn, %{"address_id" => address_hash_string}) do
    changeset =
      SmartContract.changeset(
        %SmartContract{address_hash: address_hash_string},
        %{}
      )

    {:ok, compiler_versions} = CompilerVersion.fetch_versions()

    render(conn, "new.html", changeset: changeset, compiler_versions: compiler_versions)
  end

  def create(
        conn,
        %{
          "address_id" => address_hash_string,
          "smart_contract" => smart_contract,
          "external_libraries" => external_libraries
        }
      ) do
    case Publisher.publish(address_hash_string, smart_contract, external_libraries) do
      {:ok, _smart_contract} ->
        redirect(conn, to: address_contract_path(conn, :index, address_hash_string))

      {:error, changeset} ->
        {:ok, compiler_versions} = CompilerVersion.fetch_versions()

        render(conn, "new.html", changeset: changeset, compiler_versions: compiler_versions)
    end
  end
end
