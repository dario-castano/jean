defmodule Actions.New.Handlers.Executor do
  require Logger
  alias Actions.New.Generators.Directories

  @spec execute([String.t()]) :: {:ok, String.t()} | {:rolled, String.t()}
  def execute([app_name | _]) when is_bitstring(app_name) do
    with {:ok, cwd} <- File.cwd(),
          :ok <- create_mix_project(app_name),
          :ok <- remove_app_file(app_name, cwd),
          :ok <- create_cleanarch_structure(app_name, cwd) do
      {:ok, app_name}
    else
      {:error, reason} -> rollback(app_name, reason)
    end
  end

  @spec create_mix_project(String.t()) :: :ok | {:error, String.t()}
  defp create_mix_project(app_name) do
    mix_args = ["new", app_name, "--sup"]
    {output, exit_code} = System.cmd("mix", mix_args, stderr_to_stdout: true)

    if exit_code == 0 do
      :ok
    else
      Logger.error("Failed to create mix project: #{output}")
      {:error, output}
    end
  end

  @spec remove_app_file(String.t(), String.t()) :: :ok | {:error, String.t()}
  defp remove_app_file(app_name, root_dir) do
    app_file_path = Path.join([root_dir, app_name, "lib", "#{app_name}.ex"])
    file_deletion = File.rm(app_file_path)

    case file_deletion do
      :ok -> :ok
      {:error, reason} ->
        Logger.error("Failed to delete #{app_file_path}: #{reason}")
        {:error, "Failed to delete #{app_file_path}: #{reason}"}
    end
  end

  defp create_cleanarch_structure(app_name, root_dir) do
    root_path = Path.join(root_dir, app_name)
    with :ok <- Directories.create_basic_directories(root_path, app_name) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @spec rollback(String.t(), String.t()) :: {:rolled, String.t()} | {:error, String.t()}
  defp rollback(app_name, reason) do
    {:ok, cwd} = File.cwd()
    app_path = Path.join([cwd, app_name])
    case File.rm_rf(app_path) do
      {:ok, _} -> :ok
      {:error, reason, file} ->
        Logger.error("Failed to rollback by deleting #{file}: #{reason}")
        {:error, "Failed to rollback by deleting #{file}: #{reason}"}
    end
    {:rolled, reason}
  end
end
