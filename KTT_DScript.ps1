function DownloadFileIfNotExists {
    param (
        [string]$url,
        [string]$destinationPath
    )

    if (-Not (Test-Path -Path $destinationPath)) {
        Invoke-WebRequest -Uri $url -OutFile $destinationPath
        Write-Host "Pobrano: $destinationPath" -ForegroundColor Cyan
    } else {
        Write-Host "Plik $destinationPath juz istnieje. Pomijanie pobierania." -ForegroundColor Yellow
    }
}

Write-Host "Wybierz jedna z ponizszych opcji:" -ForegroundColor Cyan
Write-Host "1: Jestem uzytkownikiem Minecraft Premium i chce uzyc oficjalnego launchera (UZYWAC TYLKO W OSTATECZNOSCI)" -ForegroundColor Red -BackgroundColor Gray
Write-Host "2: Jestem uzytkownikiem Minecraft Premium i chce uzyc Prism Launcher (rekomendowane)"
Write-Host "3: Jestem uzytkownikiem Minecraft Non-Premium i chce uzyc Fjord Launcher"
Write-Host "4: Przywroc konfiguracje Minecraft sprzed instalacji (Wylacznie do uzytku po uzyciu opcji 1)"
Write-Host "5: Przenies pliki konfiguracyjne miedzy instancjami" 
Write-Host "6: Wyjscie" -ForegroundColor Yellow

$choice = Read-Host "Wpisz numer odpowiadajacy Twojemu wyborowi"

switch ($choice) {
    "1" {
        Write-Host "Wybrano: Oficjalny launcher Minecraft Premium." -ForegroundColor Green
        # Pobieranie plikow
        $scriptPath = (Get-Location).Path
        $file1 = Join-Path $scriptPath "KTT MiniGry Alpha.mrpack"
        $file2 = Join-Path $scriptPath "mrpack-downloader-win.exe"
        $fabricInstaller = Join-Path $scriptPath "fabric-installer-1.0.1.exe"

        DownloadFileIfNotExists -url "https://dobraszajba.com:8000/KTT%20MiniGry%20Alpha.mrpack" -destinationPath $file1
        DownloadFileIfNotExists -url "https://dobraszajba.com:8000/mrpack-downloader-win.exe" -destinationPath $file2
        DownloadFileIfNotExists -url "https://dobraszajba.com:8000/fabric-installer-1.0.1.exe" -destinationPath $fabricInstaller

        # Instalacja Fabric
        $userProfile = [Environment]::GetFolderPath("UserProfile")
        $outputDir = Join-Path $userProfile "AppData\Roaming\.minecraft"
        Start-Process -FilePath "java" -ArgumentList "-jar `"$fabricInstaller`" client -dir `"$outputDir`" -mcversion 1.20.4" -Wait
        Write-Host "Zakonczono instalacje Fabric" -ForegroundColor Green

        # Uruchamianie mrpack-downloader-win.exe
        Start-Process -FilePath $file2 -ArgumentList "`"$file1`" `"$outputDir`"" -Wait
        Write-Host "Zakonczono proces uruchamiania mrpack-downloader-win.exe" -ForegroundColor Green

        # Zapytanie o usuniecie plikow
        $removeFiles = Read-Host "Czy chcesz usunac pobrane pliki instalacyjne? (y/n)"
        if ($removeFiles -eq "y") {
            Remove-Item -Path $file1, $file2, $fabricInstaller -Force
            Write-Host "Pobrane pliki instalacyjne zostaly usuniete." -ForegroundColor Green
        } else {
            Write-Host "Pobrane pliki instalacyjne nie zostaly usuniete." -ForegroundColor Yellow
        }
    }
    "2" {

        Write-Host "Wybrano: Prism Launcher (rekomendowane dla uzytkownikow Minecraft Premium)." -ForegroundColor Green
        
        # Okreslenie sciezki do pliku konfiguracyjnego
        $userProfile = [Environment]::GetFolderPath("UserProfile")
        $prismLauncherDir = Join-Path $userProfile "AppData\Roaming\PrismLauncher"
        $configFile = Join-Path $prismLauncherDir "prismlauncher.cfg"

        # Sprawdzenie, czy plik istnieje i zawiera dane
        if (Test-Path -Path $configFile) {
            $fileContent = Get-Content -Path $configFile -ErrorAction Stop
            if ($fileContent.Trim() -ne "") {
                Write-Host "Plik 'prismlauncher.cfg' znaleziony i zawiera dane. Pomijanie instalacji." -ForegroundColor Green
                return
            }
        }
        
        Write-Host "Plik 'prismlauncher.cfg' nie istnieje lub jest pusty. Pobieranie instalatora Prism Launcher..." -ForegroundColor Yellow
        
        # Ścieżka do zapisu instalatora
        $tempPath = [System.IO.Path]::GetTempPath()
        $installerPath = Join-Path $tempPath "PrismLauncher-Setup.exe"
        $downloadUrl = "https://github.com/PrismLauncher/PrismLauncher/releases/download/9.2/PrismLauncher-Windows-MSVC-Setup-9.2.exe"

        # Pobranie instalatora
        Download-FileIfNotExists -url $downloadUrl -destinationPath $installerPath

        # Uruchamianie instalatora
        Start-Process -FilePath $installerPath -Wait
        Write-Host "Uruchomiono instalator Prism Launcher. Kontynuuj instalację zgodnie z instrukcjami." -ForegroundColor Green

        $prismInstallation = Read-Host "czy instalacja zostala zakonczona pomyślnie? (y/n)" -ForegroundColor Yellow
        if ($prismInstallation -eq "y") {
            Write-Host "Instalacja Prism Launcher zostala zakonczona." -ForegroundColor Green
        } else {
            Write-Host "Sprobuj ponowic instalacje recznie a nastepnie uruchom ponownie skrypt" -ForegroundColor Red
        }
    }

    "3" {
        Write-Host "Wybrano: Fjord Launcher dla uzytkownikow Minecraft Non-Premium." -ForegroundColor Green
        # Tutaj mozna dodac kod do instalacji lub konfiguracji Fjord Launchera
        Write-Host "Ta opcja nie jest jeszcze dostepna (Work in progress)" -ForegroundColor Yellow
    }
    "4" {
        Write-Host "Wybrano: Przywracanie konfiguracji Minecraft sprzed instalacji." -ForegroundColor Yellow
        # Tutaj mozna dodac kod do przywracania poprzedniej konfiguracji
        Write-Host "Ta opcja nie jest jeszcze dostepna (Work in progress)" -ForegroundColor Yellow
    }
    "5" {
        Write-Host "Wybrano: Przenoszenie plikow konfiguracyjnych miedzy instancjami." -ForegroundColor Yellow
        Write-Host "Szukam instancji Minecraft..." -ForegroundColor Yellow
        $userProfile = [Environment]::GetFolderPath("UserProfile")
        $minecraftDir = Join-Path $userProfile ".\AppData\Roaming\.minecraft\versions"
        $prismLauncherDir = Join-Path $userProfile ".\AppData\Roaming\PrismLauncher\instances"
        $fjordLauncherDir = Join-Path $userProfile ".\AppData\Roaming\FjordLauncher\instances"

        $instanceDirs = @()

        if (Test-Path -Path $minecraftDir) {
            $minecraftInstances = Get-ChildItem -Path $minecraftDir -Directory | Select-Object -ExpandProperty Name
            $instanceDirs += $minecraftInstances
        }

        if (Test-Path -Path $prismLauncherDir) {
            $prismInstances = Get-ChildItem -Path $prismLauncherDir -Directory | Select-Object -ExpandProperty Name
            $instanceDirs += $prismInstances
        }

        if (Test-Path -Path $fjordLauncherDir) {
            $fjordInstances = Get-ChildItem -Path $fjordLauncherDir -Directory | Select-Object -ExpandProperty Name
            $instanceDirs += $fjordInstances
        }

        if ($instanceDirs.Count -eq 0) {
            Write-Host "Nie znaleziono zadnych instancji Minecraft." -ForegroundColor Red
        } else {
            Write-Host "Znalezione instancje Minecraft:" -ForegroundColor Green
            $instanceDirs | ForEach-Object { Write-Host $_ -ForegroundColor Cyan }
        }

        $sourceInstance = Read-Host "Podaj nazwe instancji z ktorej chcesz przeniesc pliki konfiguracyjne" -ForegroundColor Yellow
        $destinationInstance = Read-Host "Podaj nazwe instancji do ktorej chcesz przeniesc pliki konfiguracyjne" -ForegroundColor Yellow

        $sourcePath = ""
        $destinationPath = ""

        if (Test-Path -Path (Join-Path $minecraftDir $sourceInstance)) {
            $sourcePath = Join-Path $minecraftDir $sourceInstance
        } elseif (Test-Path -Path (Join-Path $prismLauncherDir $sourceInstance)) {
            $sourcePath = Join-Path $prismLauncherDir $sourceInstance
        } elseif (Test-Path -Path (Join-Path $fjordLauncherDir $sourceInstance)) {
            $sourcePath = Join-Path $fjordLauncherDir $sourceInstance
        } else {
            Write-Host "Nie znaleziono instancji zrodlowej." -ForegroundColor Red
            return
        }

        if (Test-Path -Path (Join-Path $minecraftDir $destinationInstance)) {
            $destinationPath = Join-Path $minecraftDir $destinationInstance
        } elseif (Test-Path -Path (Join-Path $prismLauncherDir $destinationInstance)) {
            $destinationPath = Join-Path $prismLauncherDir $destinationInstance
        } elseif (Test-Path -Path (Join-Path $fjordLauncherDir $destinationInstance)) {
            $destinationPath = Join-Path $fjordLauncherDir $destinationInstance
        } else {
            Write-Host "Nie znaleziono instancji docelowej." -ForegroundColor Red
            return
        }

        $sourceOptionsPath = Join-Path $sourcePath "minecraft\options.txt"
        $destinationOptionsPath = Join-Path $destinationPath "minecraft\options.txt"

        if (Test-Path -Path $sourceOptionsPath) {
            Copy-Item -Path $sourceOptionsPath -Destination $destinationOptionsPath -Force
            Write-Host "Plik 'options.txt' zostal skopiowany z $sourceInstance do $destinationInstance." -ForegroundColor Green
        } else {
            Write-Host "Plik 'options.txt' nie istnieje w instancji zrodlowej." -ForegroundColor Red
        }
    }
    "6" {
        exit
    }
    default {
        Write-Host "Nieprawidlowy wybor. Sprobuj ponownie." -ForegroundColor Red
    }
}