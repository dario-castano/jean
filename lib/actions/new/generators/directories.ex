defmodule Actions.New.Generators.Directories do
require Logger

  @spec create_basic_directories(String.t(), String.t()) :: :ok | {:error, String.t()}
  def create_basic_directories(root_path, app_name) do
    directories = [
      "config",
      "lib/#{app_name}/actors",
      "lib/#{app_name}/actors/registry",
      "lib/#{app_name}/actors/supervisors",
      "lib/#{app_name}/core",
      "lib/#{app_name}/core/model",
      "lib/#{app_name}/core/model/entities",
      "lib/#{app_name}/core/model/value_objects",
      "lib/#{app_name}/core/use_cases",
      "lib/#{app_name}/infrastructure",
      "lib/#{app_name}/interfaces"
    ] |> Enum.map(&Path.join([root_path, &1]))

    Enum.reduce_while(directories, :ok, &directory_reductor/2)

    directory_check = Enum.all?(directories, &File.dir?/1)

    case directory_check do
       true -> :ok
       false -> {:error, "Failed to create one or more directories"}
    end
  end

  defp create_directory(path) do
      case File.mkdir_p(path) do
        :ok -> :ok
        {:error, reason} ->
          Logger.error("Failed to create directory #{path}: #{reason}")
          {:error, "Failed to create directory #{path}: #{reason}"}
      end
  end

  defp directory_reductor(x, _) do
    Logger.debug("Creating directory: #{x}")
    case create_directory(x) do
      :ok -> {:cont, x}
      {:error, _} -> {:halt, x}
    end
  end
end
