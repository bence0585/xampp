<#
  .Synopsis
  Lekér egy fájlt egy web request-en keresztül.

  .Parameter Url
  A fájl elérési útvonala.

  .Parameter DestinationPath
  A letöltés mappája.
  
  .Example
    Invoke-WebFileRequest -Url https://bootstrap.pypa.io/get-pip.py -DestinationPath C:\get-pip.py.
#>
function Invoke-WebFileRequest {
    param(
        [Parameter(Mandatory)]
        [string]$url,
        [Parameter(Mandatory)]
        [string]$destinationPath
    )

    # biztonsági protokoll teszt
    $secure = 1;
    if ($url.StartsWith('http:')) {
        $secure = 0;
    }

    # Proxy beállítása, ha kell
    $proxy = [System.Net.WebProxy]::GetDefaultProxy();

    if ($null -ne $proxy.Address) {
        if ($secure) {
            if (Test-Path env:HTTPS_PROXY) {
                $proxy = New-Object System.Net.WebProxy ($env:HTTPS_PROXY, $true);

                # SSL Kikapcsolása, hogy megtudjuk hogy hhtps-e a proxy
                if ($env:HTTPS_PROXY.StartsWith('http:')) {
                    $secure = 0;
                }
            }
        }
        else {
            if (Test-Path env:HTTP_PROXY) {
                $proxy = New-Object System.Net.WebProxy ($env:HTTP_PROXY, $true);
            }
        }
    }

    if ($secure) {
        # Biztonsági protokoll eltárolása
        $oldSecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol;

        # Kívánt biztonsági protokoll szintjének felmérése
        $securityProtocol = 0;
        $testEndpoint = [System.Uri]$url;

        if ($null -ne $proxy.Address) {
            $testEndpoint = $proxy.Address;
        }

        foreach ($protocol in 'tls12', 'tls11', 'tls') {
            $tcpClient = New-Object Net.Sockets.TcpClient;
            $tcpClient.Connect($testEndpoint.Host, $testEndpoint.Port)

            $sslStream = New-Object Net.Security.SslStream $tcpClient.GetStream();
            $sslStream.ReadTimeout = 15000;
            $sslStream.WriteTimeout = 15000;

            try {
                $sslStream.AuthenticateAsClient($testEndpoint.Host, $null, $protocol, $false);
                $supports = $true;
            }
            catch {
                $supports = $false;
            }

            $sslStream.Dispose();
            $tcpClient.Dispose();

            if ($supports) {
                switch ($protocol) {
                    'tls12' { $securityProtocol = ($securityProtocol -bor [System.Net.SecurityProtocolType]::Tls12) }
                    'tls11' { $securityProtocol = ($securityProtocol -bor [System.Net.SecurityProtocolType]::Tls11) }
                    'tls' { $securityProtocol = ($securityProtocol -bor [System.Net.SecurityProtocolType]::Tls) }
                }
            }
        }

        [System.Net.ServicePointManager]::SecurityProtocol = $securityProtocol;
    }

    # File letöltése
    $tcpClient = New-Object System.Net.WebClient;
    $tcpClient.Proxy = $proxy;
    $tcpClient.DownloadFile($url, $destinationPath);

    if ($oldSecurityProtocol) {
        # Biztonsági protokoll visszaállítása
        [System.Net.ServicePointManager]::SecurityProtocol = $oldSecurityProtocol;
    }
}