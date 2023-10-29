Write-Output "[HSDIS-BUILDER] INFO - Checking out JDK code ..."
New-Item -ItemType Directory -Path jdk
$_JDK_DIST = [Environment]::GetEnvironmentVariable('JDK_DISTRIBUTION')
$_JDK_VER = [Environment]::GetEnvironmentVariable('JDK_VERSION')
if ($_JDK_DIST -eq "openjdk") {
  if ($_JDK_VER -eq "21") {
    git clone https://github.com/openjdk/jdk jdk
    Push-Location jdk
    git checkout tags/jdk-$_JDK_VER-ga
    Pop-Location
  } else {
    Write-Output "[HSDIS-BUILDER] ERROR - Invalid OpenJDK version: $_JDK_VER"
    exit 1
  }
} elseif ($_JDK_DIST -eq "corretto") {
  if ($_JDK_VER -eq "21") {
    git clone https://github.com/corretto/corretto-$_JDK_VER jdk
  } else {
    Write-Output "[HSDIS-BUILDER] ERROR - Invalid Amazon Corretto JDK version: $_JDK_VER"
    exit 1
  }
} else {
  Write-Output "[HSDIS-BUILDER] ERROR - Invalid JDK distribution: $_JDK_DIST"
  exit 1
}
Write-Output "[HSDIS-BUILDER] INFO - Checked out JDK code"

Write-Output "[HSDIS-BUILDER] INFO - Downloading binutils ..."
New-Item -ItemType Directory -Path binutils
Push-Location binutils
$_BINUTILS_VER = 2.41
Invoke-Webrequest -Uri "https://ftp.gnu.org/gnu/binutils/binutils-$_BINUTILS_VER.tar.gz" -OutFile "binutils-$_BINUTILS_VER.tar.gz"
tar -xzf "binutils-$_BINUTILS_VER.tar.gz"
$_CWD = Get-Location
$_BINUTILS_PATH = "$_CWD\binutils-$_BINUTILS_VER"
Pop-Location
Write-Output "[HSDIS-BUILDER] INFO - Downloaded binutils"

$_BOOT_JDK_PATH = [Environment]::GetEnvironmentVariable('JAVA_HOME')
if ($_JDK_DIST -eq "openjdk") {
  Write-Output "[HSDIS-BUILDER] INFO - Installing Boot JDK ..."
  $_BOOT_JDK_VER = $_JDK_VER
  if ($_JDK_VER -eq "21") {
    choco install openjdk --version=$_BOOT_JDK_VER.0.0
    $_BOOT_JDK_PATH = "C:\Program Files\OpenJDK\jdk-$_BOOT_JDK_VER"
  }
  Write-Output "[HSDIS-BUILDER] INFO - Installed Boot JDK"
}

echo "[HSDIS-BUILDER] INFO - Building hsdis ..."
Push-Location jdk
$_CWD = Get-Location
$_GH_ENV = [Environment]::GetEnvironmentVariable('GITHUB_ENV')
bash configure --with-hsdis=binutils --with-binutils-src=$_BINUTILS_PATH --with-boot-jdk=$_BOOT_JDK_PATH
make build-hsdis
"HSDIS_BUILD_ARTIFACT_PATH=$_CWD/build/windows-x86_64-server-release/support/hsdis/hsdis-amd64.dll" >> $_GH_ENV
Pop-Location
echo "[HSDIS-BUILDER] INFO - Built hsdis"