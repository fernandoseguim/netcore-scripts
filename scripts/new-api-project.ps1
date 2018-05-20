[CmdletBinding()]
param(
    [Alias("n")][Parameter(Mandatory=$True, Position = 1)][string]$SolutionName,
    [Alias("p")][string]$ProjectPath = "." )

$ErrorActionPreference = "Stop"

New-Item -Path $ProjectPath -Name $SolutionName -ItemType "directory"

Set-Variable -Name "WorkspaceRoot" -Value "$ProjectPath/$SolutionName"
Set-Variable -Name "SourcePath" -Value "src"
Set-Variable -Name "TestPath" -Value "test"

Set-Location -Path $WorkspaceRoot

Set-Variable -Name "ProjectApi" -Value "$SolutionName.Api"
Set-Variable -Name "ProjectDomain" -Value "$SolutionName.Domain"
Set-Variable -Name "ProjectShared" -Value "$SolutionName.Shared"
Set-Variable -Name "ProjectInfra" -Value "$SolutionName.Infra"
Set-Variable -Name "ProjectTests" -Value "$SolutionName.Tests"

New-Item -Path $SourcePath -Name $ProjectApi -ItemType "directory"
New-Item -Path $SourcePath -Name $ProjectDomain -ItemType "directory"
New-Item -Path $SourcePath -Name $ProjectShared -ItemType "directory"
New-Item -Path $SourcePath -Name $ProjectInfra -ItemType "directory"
New-Item -Path $TestPath -Name $ProjectTests -ItemType "directory"    

dotnet new sln

dotnet new webapi --name $ProjectApi --output "$SourcePath\$ProjectApi" --no-restore
dotnet new classlib --name $ProjectDomain --output "$SourcePath\$ProjectDomain" --no-restore
dotnet new classlib --name $ProjectShared --output "$SourcePath\$ProjectShared" --no-restore
dotnet new classlib --name $ProjectInfra --output "$SourcePath\$ProjectInfra" --no-restore
dotnet new xunit --name $ProjectTests --output "$TestPath\$ProjectTests" --no-restore

dotnet sln .\$SolutionName.sln add .\$SourcePath\$ProjectApi\$ProjectApi.csproj
dotnet sln .\$SolutionName.sln add .\$SourcePath\$ProjectDomain\$ProjectDomain.csproj
dotnet sln .\$SolutionName.sln add .\$SourcePath\$ProjectShared\$ProjectShared.csproj
dotnet sln .\$SolutionName.sln add .\$SourcePath\$ProjectInfra\$ProjectInfra.csproj
dotnet sln .\$SolutionName.sln add .\$TestPath\$ProjectTests\$ProjectTests.csproj

dotnet add .\$SourcePath\$ProjectDomain\$ProjectDomain.csproj reference .\$SourcePath\$ProjectShared\$ProjectShared.csproj

dotnet add .\$SourcePath\$ProjectInfra\$ProjectInfra.csproj reference .\$SourcePath\$ProjectDomain\$ProjectDomain.csproj
dotnet add .\$SourcePath\$ProjectInfra\$ProjectInfra.csproj reference .\$SourcePath\$ProjectShared\$ProjectShared.csproj

dotnet add .\$SourcePath\$ProjectApi\$ProjectApi.csproj reference .\$SourcePath\$ProjectDomain\$ProjectDomain.csproj
dotnet add .\$SourcePath\$ProjectApi\$ProjectApi.csproj reference .\$SourcePath\$ProjectShared\$ProjectShared.csproj
dotnet add .\$SourcePath\$ProjectApi\$ProjectApi.csproj reference .\$SourcePath\$ProjectInfra\$ProjectInfra.csproj

dotnet add .\$TestPath\$ProjectTests\$ProjectTests.csproj reference .\$SourcePath\$ProjectApi\$ProjectApi.csproj
dotnet add .\$TestPath\$ProjectTests\$ProjectTests.csproj reference .\$SourcePath\$ProjectDomain\$ProjectDomain.csproj
dotnet add .\$TestPath\$ProjectTests\$ProjectTests.csproj reference .\$SourcePath\$ProjectShared\$ProjectShared.csproj
dotnet add .\$TestPath\$ProjectTests\$ProjectTests.csproj reference .\$SourcePath\$ProjectInfra\$ProjectInfra.csproj

git clone https://gist.github.com/dfe232d3455a153746841392e1cf3643.git
Move-Item -Path ".\dfe232d3455a153746841392e1cf3643\VisualStudio.gitignore" -Destination ".\.gitignore"
Write-Output "added .gitignore to project"

git clone https://gist.github.com/55ecef5391957a3eb38347bd63362fd3.git
Move-Item -Path ".\55ecef5391957a3eb38347bd63362fd3\VisualStudio.gitattributes" -Destination ".\.gitattributes"
Write-Output "added .gitattributes to project"

Start-Sleep -m 2000

Remove-Item -Recurse -Force -Path .\dfe232d3455a153746841392e1cf3643
Remove-Item -Recurse -Force -Path .\55ecef5391957a3eb38347bd63362fd3

git init

git add .

git commit -m "initial commit with .gitignore to webapi project"

dotnet restore

dotnet build