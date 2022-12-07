
Function Install-Xampp {
    Param(
        [Parameter(Mandatory)]
        [string] $version
    )

    $url = ('https://netix.dl.sourceforge.net/project/xampp/XAMPP%20Windows/{0}/xampp-windows-x64-{0}-0-VS16-installer.exe' -f $version);

  
    $options = @(
        '--unattendedmodeui', 'none',
        '--mode', 'unattended',
        # '--launchapps', '0',
        '--debuglevel', '4',
        '--disable-components', 'xampp_filezilla,xampp_mercury,xampp_tomcat,xampp_perl,xampp_webalizer,xampp_sendmail'
    );
    . .\Install-FromExe.ps1
    Install-FromExe -Name 'xampp' -Url $url -Options $options -NoVerify;
}