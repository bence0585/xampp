Function Uninstall-Xampp {
    Param(
        [Parameter(Mandatory)]
        [string] $filepath
    )  

    $options = @(
        '--mode', 'unattended',
        '--debuglevel', '4'
    );
    Start-Process $filepath -Wait -ArgumentList $options;
}