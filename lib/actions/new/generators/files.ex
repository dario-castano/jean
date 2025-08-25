defmodule Actions.New.Generators.Files do
  require Logger

  @spec remove_app_file(String.t(), String.t()) :: :ok | {:error, String.t()}
  def remove_app_file(app_name, root_dir) do
    app_file_path = Path.join([root_dir, app_name, "lib", "#{app_name}.ex"])
    file_deletion = File.rm(app_file_path)

    case file_deletion do
      :ok ->
        :ok

      {:error, reason} ->
        Logger.error("Failed to delete #{app_file_path}: #{reason}")
        {:error, "Failed to delete #{app_file_path}: #{reason}"}
    end
  end

  def create_config_files(app_name, root_dir) do
    target_dir = Path.join([root_dir, app_name, "config"])
    jean_root = Path.join([:code.priv_dir(:jean) |> to_string(), "templates", "new", "config"])

    files = ["config.exs", "prod.exs", "test.exs", "dev.exs"] |>
      Enum.map(fn elem ->
        {Path.join([jean_root, "#{elem}.eex"]), Path.join([target_dir, elem])}
      end)

    Enum.reduce_while(files, :ok, &copy_file_reductor/2)

    :ok
  end

  defp create_file(source, target) do
    case File.cp_r(source, target) do
      {:ok, _} ->
        Logger.debug("Copied #{source} to #{target}")
        :ok
      {:error, reason, file} ->
        Logger.error("Failed to copy #{file} from #{source} to #{target}: #{reason}")
        {:error, "Failed to copy #{file} from #{source} to #{target}: #{reason}"}
    end
  end

  defp copy_file_reductor({source, target} = x, _) do
    Logger.debug("Copying file: #{source} to #{target}")
    case create_file(source, target) do
      :ok -> {:cont, x}
      {:error, _} -> {:halt, x}
    end
  end

end
