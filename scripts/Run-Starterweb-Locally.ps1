#!/usr/bin/env powershell
#requires -version 4

[CmdletBinding(PositionalBinding = $false)]
param()

# BEWARE: This script makes changes to source files which you will have to seperate from any changes you want to keep before commiting.

Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop'
git clean -xdf


$projects = "$PSScriptRoot/../src/Microsoft.DotNet.Web.ProjectTemplates"

$csproj = Join-Path $projects "StarterWeb-CSharp.csproj.in"
(Get-Content $csproj).replace('<PackageReference Include="Microsoft.AspNetCore.App"', '<PackageReference Include="Microsoft.NETCore.App" Version="${MicrosoftNETCoreApp22PackageVersion}" />
    <PackageReference Include="Microsoft.AspNetCore.App"') | Set-Content $csproj

./build.cmd /t:Package

Push-Location "$projects/content/StarterWeb-CSharp"
try {
    $sqlServer = "Data\SqlServer"
    if (Test-Path $sqlServer) {
        Remove-Item -Recurse -Force -Path $sqlServer
    }

    $generatedProj = "Company.WebApplication1.csproj"
    if (Test-path $generatedProj) {
        if (-not ((Get-Content $generatedProj) -contains "<DefineConstants>")) {
            $runtimeString = "</RuntimeFrameworkVersion>"
            $content = (Get-Content $generatedProj).replace($runtimeString, "$runtimeString`n<DefineConstants>IndividualLocalAuth;UseLocalDB</DefineConstants>") | Set-Content $generatedProj
        }
        $commentedConnectionString = '//  "ConnectionStrings": {'

        $connectionString = @'
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=aspnet-Company.WebApplication1-53bc9b9d-9d6a-45d4-8429-2a2761773502;Trusted_Connection=True;MultipleActiveResultSets=true"
  },
'@
        $appSettings = "appsettings.json"
        (Get-Content $appSettings).replace($commentedConnectionString, $connectionString) | Set-Content $appSettings
    }

    $layout = "Views/Shared/_Layout.cshtml"
    $loginPartial = '<partial name="_LoginPartial" />'
    $identityPartial = '<partial name="_LoginPartial.Identity" />'
    (Get-Content $layout).Replace($loginPartial, $identityPartial) | Set-Content $layout

    $launchSettings = "Properties\launchSettings.json"
    (Get-Content $launchSettings).replace('"sslPort": 0', '') | Set-Content $launchSettings

    dotnet run
}
finally {
    Pop-Location
}
