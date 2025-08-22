defmodule Actions.New.Handlers.Executor do
  def execute([app_name | _]) when is_bitstring(app_name) do
    {status, output} = create_mix_project(app_name)

    case status do
       :ok -> {:ok, app_name}
       :error -> {:error, output}
    end
  end

  defp create_mix_project(app_name) do
    mix_args = ["new", app_name, "--sup"]
    {output, exit_code} = System.cmd("mix", mix_args, stderr_to_stdout: true)

    if exit_code == 0 do
      {:ok, output}
    else
      {:error, output}
    end
  end
end
