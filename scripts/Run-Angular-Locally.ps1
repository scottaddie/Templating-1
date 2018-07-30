#!/usr/bin/env powershell
#requires -version 4

[CmdletBinding(PositionalBinding = $false)]
param()

# BEWARE: This script makes changes to source files which you will have to seperate from any changes you want to keep before commiting.

Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop'
#git clean -xdf

$projects = "$PSScriptRoot/../src/Microsoft.DotNet.Web.Spa.ProjectTemplates"

$csproj = Join-Path $projects "Angular-CSharp.csproj.in"
(Get-Content $csproj).replace('<PackageReference Include="Microsoft.AspNetCore.App"', '<PackageReference Include="Microsoft.NETCore.App" Version="${MicrosoftNETCoreApp22PackageVersion}" />
    <PackageReference Include="Microsoft.AspNetCore.App"') | Set-Content $csproj

dotnet new --uninstall Microsoft.DotNet.Web.Spa.ProjectTemplates
dotnet new --uninstall Microsoft.DotNet.Web.Spa.ProjectTemplates.2.2
./build.cmd /t:Package
dotnet new --install "$PSScriptRoot/../artifacts/build/Microsoft.DotNet.Web.Spa.ProjectTemplates.2.2.0-preview1-t000.nupkg"

New-Item -ErrorAction Ignore "tmp" -ItemType Directory
Push-Location "tmp"
try {
    dotnet new angular
    Push-Location "ClientApp"
    try {
        npm install
    }
    finally {
        Pop-Location
    }
    dotnet run
}
finally {
    Pop-Location
}
