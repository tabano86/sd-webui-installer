<#  
    AUTOMATIC1111 Stable Diffusion WebUI Installer
    - Prompts for an installation directory (default: $env:USERPROFILE\StableDiffusionWebUI)
    - Checks available disk space (minimum: 10GB free)
    - Installs Git and Python 3.10.11 if needed
    - Clones or updates the repository (and fixes Git “dubious ownership” issues)
    - Sets up a virtual environment and installs dependencies via Start-Process (to avoid command operator issues)
    - Downloads the v1.5 model if not already present
    - Updates webui-user.bat with performance flags (--xformers --medvram)
    - Launches the WebUI and waits for user input before exiting
#>

#region Configuration
$MinFreeSpaceGB     = 10
$DefaultInstallDir  = "$env:USERPROFILE\StableDiffusionWebUI"

$GitInstallerUrl    = "https://github.com/git-for-windows/git/releases/download/v2.41.0.windows.1/Git-2.41.0-64-bit.exe"
$PyVersion          = "3.10.11"
$PythonInstallerUrl = "https://www.python.org/ftp/python/$PyVersion/python-$PyVersion-amd64.exe"
$RepoURL            = "https://github.com/AUTOMATIC1111/stable-diffusion-webui.git"
$ModelURL           = "https://huggingface.co/sd-legacy/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors"
#endregion

#region Helper Functions

function Command-Exists {
    param([string]$cmd)
    return $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue)
}

function Prompt-ForInstallDir {
    param([string]$Default)
    $inputDir = (Read-Host "Enter installation directory [`"$Default`"]").Trim()
    if ([string]::IsNullOrWhiteSpace($inputDir)) { 
        Write-Host "No input received. Using default: $Default" -ForegroundColor Yellow
        return $Default 
    }
    return $inputDir
}

function Check-DiskSpace {
    param(
        [string]$Path,
        [int]$MinGB
    )
    $driveRoot = [IO.Path]::GetPathRoot($Path)
    $driveLetter = $driveRoot.TrimEnd("\")
    # Use the drive letter (first character) to get PSDrive info.
    $drive = Get-PSDrive ($driveLetter.Substring(0,1))
    if ($drive -eq $null) {
        Write-Warning "Unable to determine free space for $Path"
        return $false
    }
    $freeGB = [math]::Round($drive.Free / 1GB, 2)
    Write-Host "Drive $driveLetter has $freeGB GB free."
    if ($freeGB -lt $MinGB) {
        Write-Error "Not enough free disk space. At least $MinGB GB is required."
        return $false
    }
    return $true
}

function Install-Git {
    if (-not (Command-Exists "git")) {
        Write-Host "Git not found. Installing Git..." -ForegroundColor Cyan
        $installerPath = "$env:TEMP\git_installer.exe"
        try {
            Invoke-WebRequest -Uri $GitInstallerUrl -OutFile $installerPath -UseBasicParsing
        } catch {
            Write-Error "Could not download Git installer. $_"
            throw
        }
        $args = "/VERYSILENT /NORESTART"
        $proc = Start-Process -FilePath $installerPath -ArgumentList $args -Wait -PassThru
        if ($proc.ExitCode -ne 0) {
            Write-Error "Git installation failed (exit code $($proc.ExitCode))."
            throw "Git installation failed."
        }
        Write-Host "Git installed successfully." -ForegroundColor Green
        $gitPath = "${Env:ProgramFiles}\Git\cmd"
        if (Test-Path $gitPath) { $env:PATH += ";$gitPath" }
    }
    else {
        Write-Host "Git is already installed." -ForegroundColor Yellow
    }
}

function Install-Python {
    try {
        $versionOutput = & python --version 2>&1
    } catch {}
    if ($versionOutput -and $versionOutput -match "Python 3\.10\.")
    {
        Write-Host "Python 3.10 detected." -ForegroundColor Yellow
    } else {
        Write-Host "Installing Python $PyVersion..." -ForegroundColor Cyan
        $pyInstaller = "$env:TEMP\python_installer.exe"
        try {
            Invoke-WebRequest -Uri $PythonInstallerUrl -OutFile $pyInstaller -UseBasicParsing
        } catch {
            Write-Error "Failed to download Python installer. $_"
            throw
        }
        $pyArgs = "/quiet InstallAllUsers=1 PrependPath=1"
        $pyProc = Start-Process -FilePath $pyInstaller -ArgumentList $pyArgs -Wait -PassThru
        if ($pyProc.ExitCode -ne 0) {
            Write-Error "Python installation failed (exit code $($pyProc.ExitCode))."
            throw "Python installation failed."
        }
        Write-Host "Python $PyVersion installed successfully." -ForegroundColor Green
    }
    try {
        return (Get-Command python).Source
    } catch {
        return "python"
    }
}

function Clone-Or-UpdateRepo {
    param(
        [string]$InstallDir,
        [string]$RepoUrl
    )
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir | Out-Null
    }
    if (Test-Path (Join-Path $InstallDir ".git")) {
        Write-Host "Repository already exists. Updating repository..." -ForegroundColor Cyan
        Push-Location $InstallDir
        & git pull
        Pop-Location
    }
    else {
        Write-Host "Cloning repository from $RepoUrl ..." -ForegroundColor Cyan
        & git clone --depth 1 $RepoUrl $InstallDir
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Git clone failed."
            throw "Git clone failed."
        }
    }
    # Fix Git “dubious ownership” issue
    $problemRepo = Join-Path $InstallDir "repositories\stable-diffusion-stability-ai"
    if (Test-Path $problemRepo) {
        Write-Host "Adding repository '$problemRepo' to Git safe.directory ..." -ForegroundColor Cyan
        & git config --global --add safe.directory "$problemRepo"
    }
}

function Setup-Venv {
    param(
        [string]$InstallDir,
        [string]$PythonExe
    )
    $venvDir = Join-Path $InstallDir "venv"
    if (-not (Test-Path $venvDir)) {
        Write-Host "Creating virtual environment..." -ForegroundColor Cyan
        & "$PythonExe" -m venv "$venvDir"
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to create virtual environment."
            throw "Failed to create virtual environment."
        }
    } else {
        Write-Host "Virtual environment already exists; using existing one." -ForegroundColor Yellow
    }
    $venvPython = Join-Path $venvDir "Scripts\python.exe"
    # Use Start-Process to upgrade pip
    $proc = Start-Process -FilePath $venvPython -ArgumentList "-m", "pip", "install", "--upgrade", "pip" -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        Write-Error "Failed to upgrade pip in the virtual environment."
        throw "Pip upgrade failed."
    }
    return $venvPython
}

function Install-Dependencies {
    param(
        [string]$VenvPython,
        [string]$InstallDir
    )
    Write-Host "Installing dependencies..." -ForegroundColor Cyan
    $proc = Start-Process -FilePath $VenvPython -ArgumentList "-m", "pip", "install", "torch", "torchvision", "torchaudio", "--index-url", "https://download.pytorch.org/whl/cu118" -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        Write-Error "Failed to install PyTorch with CUDA support."
        throw "PyTorch installation failed."
    }
    $proc = Start-Process -FilePath $VenvPython -ArgumentList "-m", "pip", "install", "-r", (Join-Path $InstallDir "requirements.txt") -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        Write-Error "Failed to install requirements from requirements.txt."
        throw "Requirements installation failed."
    }
    $proc = Start-Process -FilePath $VenvPython -ArgumentList "-m", "pip", "install", "xformers" -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        Write-Error "Failed to install xformers."
        throw "Xformers installation failed."
    }
}

function Download-ModelFile {
    param(
        [string]$InstallDir,
        [string]$ModelUrl
    )
    $modelsDir = Join-Path $InstallDir "models\Stable-diffusion"
    if (-not (Test-Path $modelsDir)) { 
        New-Item -ItemType Directory -Path $modelsDir -Force | Out-Null 
    }
    $modelFile = Join-Path $modelsDir "v1-5-pruned-emaonly.safetensors"
    if (Test-Path $modelFile) {
        Write-Host "Model file already exists; skipping download." -ForegroundColor Yellow
    } else {
        Write-Host "Downloading model file..." -ForegroundColor Cyan
        try {
            Invoke-WebRequest -Uri $ModelUrl -OutFile $modelFile -UseBasicParsing
        } catch {
            Write-Warning "Model download failed. Please manually download and place the model in $modelsDir"
        }
    }
}

function Update-WebUIBat {
    param(
        [string]$InstallDir
    )
    $batPath = Join-Path $InstallDir "webui-user.bat"
    if (Test-Path $batPath) {
        $content = Get-Content $batPath
        $flagLine = "set COMMANDLINE_ARGS=--xformers --medvram"
        if ($content -notmatch "COMMANDLINE_ARGS") {
            Write-Host "Adding performance flags to webui-user.bat ..." -ForegroundColor Cyan
            $content += "`r`n$flagLine"
        } else {
            $content = $content -replace '^(set\s+COMMANDLINE_ARGS=).*', $flagLine
        }
        Set-Content $batPath $content
    }
}
#endregion

#region Main Installer Block

try {
    Write-Host "Stable Diffusion WebUI Installer Starting..." -ForegroundColor Cyan

    # 1. Ask for installation directory and check disk space.
    $installDir = Prompt-ForInstallDir -Default $DefaultInstallDir
    Write-Host "Installation directory: $installDir" -ForegroundColor Cyan
    if (-not (Check-DiskSpace -Path $installDir -MinGB $MinFreeSpaceGB)) { 
        throw "Insufficient disk space." 
    }

    # 2. Ensure Git is installed.
    Install-Git

    # 3. Ensure Python 3.10 is installed.
    $pythonExe = Install-Python

    # 4. Clone or update the repository.
    Clone-Or-UpdateRepo -InstallDir $installDir -RepoUrl $RepoURL

    # 5. Set up (or reuse) the virtual environment.
    $venvPython = Setup-Venv -InstallDir $installDir -PythonExe $pythonExe

    # 6. Install required Python dependencies.
    Install-Dependencies -VenvPython $venvPython -InstallDir $installDir

    # 7. Download the model file if not already present.
    Download-ModelFile -InstallDir $installDir -ModelUrl $ModelURL

    # 8. Update webui-user.bat with performance flags.
    Update-WebUIBat -InstallDir $installDir

    # 9. Launch the WebUI.
    Write-Host "Launching Stable Diffusion WebUI..." -ForegroundColor Green
    Start-Process -WorkingDirectory $installDir -FilePath (Join-Path $installDir "webui-user.bat")

    Write-Host "Installation complete. The WebUI should open shortly at http://127.0.0.1:7860" -ForegroundColor Green
} catch {
    Write-Error "An error occurred: $_"
} finally {
    Write-Host ""
    Read-Host -Prompt "Press Enter to exit"
}
#endregion
