function Update-ScriptPath {
    $env:PATH = [Environment]::GetEnvironmentVariable('PATH',[EnvironmentVariableTarget]::Machine);
}