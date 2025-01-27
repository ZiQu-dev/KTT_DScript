function DownloadFileIfNotExists {
    param (
        [string]$url,
        [string]$destinationPath
    )

    if (-Not (Test-Path -Path $destinationPath)) {
        Write-Host "Rozpoczynanie pobierania: $destinationPath" -ForegroundColor Green
        Invoke-WebRequest -Uri $url -OutFile $destinationPath
        Write-Host "Pobrano: $destinationPath" -ForegroundColor Cyan
    } else {
        Write-Host "Plik $destinationPath juz istnieje. Pomijanie pobierania." -ForegroundColor Yellow
    }
}
1
function Remove-FilesIfExist {
    param (
        [string]$FolderPath
    )

    if (-Not (Test-Path -Path $FolderPath)) {
        Write-Host "FOLDER NIE ISTNIEJE (BŁĄD INSTALACJI!)" -ForegroundColor Red
        return
    }

    # Get the files in the folder
    $files = Get-ChildItem -Path $FolderPath -File

    # Check if there are any files
    if ($files.Count -gt 0) {
        Write-Host "Znaleziono poprzednią paczkę w folderze mods. Usuwam." -ForegroundColor Green
        
        # Delete the files
        foreach ($file in $files) {
            Remove-Item -Path $file.FullName -Force
            Write-Host "Deleted: $($file.FullName)"
        }

        Write-Host "Usunięto pliki z folderu mods!" -ForegroundColor Green
    } else {
        Write-Host "Nie znaleziono plikow w folderze mods." -ForegroundColor Yellow
    }
}

# Example usage
$mods = Join-Path $userProfile "AppData\Roaming\.minecraft\mods"
# Remove-FilesIfExist -FolderPath $folderPath

while ($true) {
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
            
            $userProfile = [Environment]::GetFolderPath("UserProfile")
            $minecraftDir = Join-Path $userProfile "AppData\Roaming\.minecraft"
            
            if (-Not (Test-Path -Path $minecraftDir)) {
                Write-Host "Nie znaleziono folderu .minecraft. Twoja instalacja Minecraft moze byc uszkodzona" -ForegroundColor Red
                return
            }

            # Pobieranie plikow
            $scriptPath = (Get-Location).Path
            $mrpack1 = Join-Path $scriptPath "ZENA.mrpack"
            $mrpack2 = Join-Path $scriptPath "Battles.mrpack"
            $mrpack3 = Join-Path $scriptPath "Bingo.mrpack"
            $downloader = Join-Path $scriptPath "mrpack-downloader-win.exe"
            $fabricInstaller = Join-Path $scriptPath "fabric-installer-1.0.1.exe"

            while($true) {
                Write-Host "Wybierz, które :" -ForegroundColor Cyan
                Write-Host "1: ZENA" -ForegroundColor Green
                Write-Host "2: Battles" -ForegroundColor Yellow
                Write-Host "3: Bingo" -ForegroundColor Blue
                $chooseModpack = Read-Host "Wpisz numer odpowiadajacy Twojemu wyborowi"
                switch ($chooseModpack) {
                    "1" {
                        Write-Host "Wybrano ZENE" -ForegroundColor Green
                        DownloadFileIfNotExists -url "https://dobraszajba.com:8000/ZENA.mrpack" -destinationPath $mrpack1
                        $dwmrpack = $mrpack1
                        break
                    }
                    "2" {
                        Write-Host "Wybrano Battles" -ForegroundColor Yellow
                        DownloadFileIfNotExists -url "https://dobraszajba.com:8000/Battles.mrpack" -destinationPath $mrpack2
                        $dwmrpack = $mrpack2
                        break
                    }
                    "3" {
                        Write-Host "Wybrano Bingo" -ForegroundColor Blue
                        DownloadFileIfNotExists -url "https://dobraszajba.com:8000/Bingo.mrpack" -destinationPath $mrpack3
                        $dwmrpack = $mrpack3
                        break
                    }
                    default {
                        Write-Host "Nieprawidlowy wybor. Sprobuj ponownie." -ForegroundColor Red
                    }
                }
                if ($chooseModpack -in @("1", "2", "3")) {
                    break
                }
            }
            
            DownloadFileIfNotExists -url "https://dobraszajba.com:8000/mrpack-downloader-win.exe" -destinationPath $downloader
            DownloadFileIfNotExists -url "https://dobraszajba.com:8000/fabric-installer-1.0.1.exe" -destinationPath $fabricInstaller

            # Instalacja Fabric
            $outputDir = Join-Path $userProfile "AppData\Roaming\.minecraft"
            Start-Process -FilePath "java" -ArgumentList "-jar `"$fabricInstaller`" client -dir `"$outputDir`" -mcversion 1.20.4" -Wait
            Write-Host "Zakonczono instalacje Fabric" -ForegroundColor Green
            while($true) {
                Write-Host "UWAGA ABY KONTYNUOWAĆ NALEŻY USUNĄĆ POPRZEDNIE MODYFIKACJE Z FOLDERU MODS!" -ForegroundColor Red
                $askUser = Read-Host "Czy chcesz usunac pobrane poprzednio mody? (TAK/NIE)"
                switch($askUser) {
                    "TAK" {
                        Remove-FilesIfExist -FolderPath $mods
                        break
                    }
                    "NIE" {
                        Write-Host "Przerwano instalacje mrpack-downloader-win.exe" -ForegroundColor Red
                        Write-Host "Aby kontynuować należy usunąć lub przenieść pobrane modyfikacje." -ForegroundColor Yellow
                        while ($true) {
                            $continue = Read-Host "Czy chcesz kontynuować instalacje? (y/n)"
                            switch($continue) {
                                "y" {
                                    Remove-FilesIfExist -FolderPath $mods
                                    break
                                }
                                "n" {
                                    while($true) {
                                    $removeFiles = Read-Host "Czy chcesz usunac pobrane pliki instalacyjne? (y/n)"
                                    switch($removeFiles) {
                                        "y" {
                                            switch ($chooseModpack) {
                                                "1" {
                                                    Remove-Item -Path $mrpack1 -Force
                                                }
                                                "2" {
                                                    Remove-Item -Path $mrpack2 -Force
                                                }
                                                "3" {
                                                    Remove-Item -Path $mrpack3 -Force
                                                }
                                        }
                                            Remove-Item -Path $downloader, $fabricInstaller -Force
                                            Write-Host "Pobrane pliki instalacyjne zostaly usuniete." -ForegroundColor Green
                                            exit
                                        }
                                        "n" {
                                            Write-Host "Pobrane pliki instalacyjne nie zostaly usuniete." -ForegroundColor Yellow
                                            exit
                                        }
                                        default {
                                            Write-Host "Nieprawidlowy wybor. Sprobuj ponownie." -ForegroundColor Red
                                        }
                                        }
                                        if ($removeFiles -in @("y", "n")) {
                                            break
                                        }
                                    return
                                }
                                }
                                default {
                                    Write-Host "Nieprawidlowy wybor. Sprobuj ponownie." -ForegroundColor Red
                                }
                            }
                        if ($continue -in @("y", "n")) {
                            break
                        }
                    }
                    }
                default {
                    Write-Host "Nieprawidlowy wybor. Sprobuj ponownie." -ForegroundColor Red
                }
                    
                }
                if ($askUser -in @("TAK", "NIE")) {
                    break
                }
            }
            # Uruchamianie mrpack-downloader-win.exe
            Start-Process -FilePath $downloader -ArgumentList "`"$dwmrpack`" `"$outputDir`"" -Wait
            Write-Host "Zakonczono proces uruchamiania mrpack-downloader-win.exe" -ForegroundColor Green

            while($true) {
            $removeFiles = Read-Host "Czy chcesz usunac pobrane pliki instalacyjne? (y/n)"
            switch($removeFiles) {
                "y" {
                    switch ($chooseModpack) {
                        "1" {
                            Remove-Item -Path $mrpack1 -Force
                        }
                        "2" {
                            Remove-Item -Path $mrpack2 -Force
                        }
                        "3" {
                            Remove-Item -Path $mrpack3 -Force
                        }
                }
                    Remove-Item -Path $downloader, $fabricInstaller -Force
                    Write-Host "Pobrane pliki instalacyjne zostaly usuniete." -ForegroundColor Green
                    break
                }
                "n" {
                    Write-Host "Pobrane pliki instalacyjne nie zostaly usuniete." -ForegroundColor Yellow
                    break
                }
                }
                if ($removeFiles -in @("y", "n")) {
                    break
                }
            }
        }
        "2" {
            Write-Host "Wybrano: Prism Launcher (rekomendowane dla uzytkownikow Minecraft Premium)." -ForegroundColor Green
            
            # Okreslenie sciezki do pliku konfiguracyjnego
            $userProfile = [Environment]::GetFolderPath("UserProfile")
            $prismLauncherDir = Join-Path $userProfile "AppData\Roaming\PrismLauncher"
            $configFile = Join-Path $prismLauncherDir "prismlauncher.cfg"
            $scriptPath = (Get-Location).Path
            $mrpack1 = Join-Path $scriptPath "ZENA.mrpack"
            $mrpack1 = Join-Path $scriptPath "Battles.mrpack"
            $mrpack3 = Join-Path $scriptPath "Bingo.mrpack"
            DownloadFileIfNotExists -url "https://dobraszajba.com:8000/ZENA.mrpack" -destinationPath $mrpack1
            DownloadFileIfNotExists -url "https://dobraszajba.com:8000/Battles.mrpack" -destinationPath $mrpack2
            DownloadFileIfNotExists -url "https://dobraszajba.com:8000/Bingo.mrpack" -destinationPath $mrpack3
            # Sprawdzenie, czy plik istnieje i zawiera dane
            if (Test-Path -Path $configFile) {
            $fileContent = Get-Content -Path $configFile -ErrorAction Stop
            if ($fileContent.Trim() -ne "") {
                Write-Host "Plik 'prismlauncher.cfg' znaleziony i zawiera dane. Pomijanie instalacji." -ForegroundColor Green
                return
            }
            }
            
            Write-Host "Plik 'prismlauncher.cfg' nie istnieje lub jest pusty. Pobieranie instalatora Prism Launcher..." -ForegroundColor Yellow
            
            $tempPath = [System.IO.Path]::GetTempPath()
            $installerPath = Join-Path $tempPath "PrismLauncher-Windows-MinGW-w64-9.2.zip"
            DownloadFileIfNotExists -url "https://dobraszajba.com:8000/PrismLauncher-Windows-MinGW-w64-9.2.zip" -destinationPath $installerPath
            $installPath = Join-Path $userProfile "AppData\Local\Programs\PrismLauncher"
            
            if (-Not (Test-Path -Path $installPath)) {
            mkdir $installPath
            }
            
            Expand-Archive -Path $installerPath -DestinationPath $installPath -Force
            Write-Host "Instalacja Prism Launcher zakonczona." -ForegroundColor Green

            $desktop = [Environment]::GetFolderPath("Desktop")
            $shortcutPath = Join-Path $desktop "PrismLauncher.lnk"
            $targetPath = Join-Path $installPath "PrismLauncher.exe"
            
            if (-Not (Test-Path -Path $shortcutPath)) {
            $WScriptShell = New-Object -ComObject WScript.Shell
            $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
            $shortcut.TargetPath = $targetPath
            $shortcut.Save()
            Write-Host "Skrot do PrismLauncher.exe zostal utworzony na pulpicie." -ForegroundColor Green
            } else {
            Write-Host "Skrot do PrismLauncher.exe juz istnieje na pulpicie." -ForegroundColor Yellow
            }

            # Uruchomienie Prism Launcher
            Start-Process -FilePath $targetPath
            Write-Host "Prism Launcher zostal uruchomiony." -ForegroundColor Green
        }
        "3" {
            Write-Host "Wybrano: Fjord Launcher dla uzytkownikow Minecraft Non-Premium." -ForegroundColor Green
            
            $userProfile = [Environment]::GetFolderPath("UserProfile")
            $fjordLauncherDir = Join-Path $userProfile "AppData\Roaming\FjordLauncher"
            $configFile = Join-Path $fjordLauncherDir "fjordlauncher.cfg"
            $scriptPath = (Get-Location).Path
            $mrpack1 = Join-Path $scriptPath "Battles.mrpack"
            $mrpack2 = Join-Path $scriptPath "ZENA.mrpack"
            $mrpack3 = Join-Path $scriptPath "Bingo.mrpack"
            DownloadFileIfNotExists -url "https://dobraszajba.com:8000/Battles.mrpack" -destinationPath $mrpack1
            DownloadFileIfNotExists -url "https://dobraszajba.com:8000/ZENA.mrpack" -destinationPath $mrpack2
            DownloadFileIfNotExists -url "https://dobraszajba.com:8000/Bingo.mrpack" -destinationPath $mrpack3
            
            if (Test-Path -Path $configFile) {
            $fileContent = Get-Content -Path $configFile -ErrorAction Stop
            if ($fileContent.Trim() -ne "") {
                Write-Host "Plik 'fjordlauncher.cfg' znaleziony i zawiera dane. Pomijanie instalacji." -ForegroundColor Green
                return
            }
            }
            
            Write-Host "Plik 'fjordlauncher.cfg' nie istnieje lub jest pusty. Pobieranie instalatora Fjord Launcher..." -ForegroundColor Yellow
            
            $tempPath = [System.IO.Path]::GetTempPath()
            $installerPath = Join-Path $tempPath "FjordLauncher-Windows-MinGW-w64-Setup-9.2.1.zip"
            DownloadFileIfNotExists -url "https://dobraszajba.com:8000/FjordLauncher-Windows-MinGW-w64-9.2.1.zip" -destinationPath $installerPath
            
            $installPath = Join-Path $userProfile "AppData\Local\Programs\FjordLauncher"
            
            if (-Not (Test-Path -Path $installPath)) {
            mkdir $installPath
            }
            
            Expand-Archive -Path $installerPath -DestinationPath $installPath -Force
            Write-Host "Instalacja Fjord Launcher zakonczona." -ForegroundColor Green
            
            # Tworzenie skrotu na pulpicie
            $desktop = [Environment]::GetFolderPath("Desktop")
            $shortcutPath = Join-Path $desktop "FjordLauncher.lnk"
            $targetPath = Join-Path $installPath "FjordLauncher.exe"
            
            if (-Not (Test-Path -Path $shortcutPath)) {
            $WScriptShell = New-Object -ComObject WScript.Shell
            $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
            $shortcut.TargetPath = $targetPath
            $shortcut.Save()
            Write-Host "Skrot do FjordLauncher.exe zostal utworzony na pulpicie." -ForegroundColor Green
            } else {
            Write-Host "Skrot do FjordLauncher.exe juz istnieje na pulpicie." -ForegroundColor Yellow
            }

            # Uruchomienie Fjord Launcher
            Start-Process -FilePath $targetPath
            Write-Host "Fjord Launcher zostal uruchomiony." -ForegroundColor Green
        }
        "4" {
            Write-Host "Wybrano: Przywracanie konfiguracji Minecraft sprzed instalacji." -ForegroundColor Yellow
            # Tutaj mozna dodac kod do przywracania poprzedniej konfiguracji
            Write-Host "Ta opcja nie jest jeszcze dostepna (Work in progress)" -ForegroundColor Yellow
        }
        "5" {
            function TransferConfigFiles {
                Write-Host "Szukam instancji Minecraft..." -ForegroundColor Yellow
                $userProfile = [Environment]::GetFolderPath("UserProfile")
                $minecraftDir = Join-Path $userProfile ".\AppData\Roaming\.minecraft\versions"
                $prismLauncherDir = Join-Path $userProfile ".\AppData\Roaming\PrismLauncher\instances"
                $fjordLauncherDir = Join-Path $userProfile ".\AppData\Roaming\FjordLauncher\instances"

                $instanceDirs = @()

                if (Test-Path -Path $minecraftDir) {
                    $minecraftInstances = Get-ChildItem -Path $minecraftDir -Directory | Where-Object { Test-Path -Path (Join-Path $_.FullName "minecraft\options.txt") } | Select-Object -ExpandProperty Name | ForEach-Object { "$_ (Oficjalny Launcher)" }
                    $instanceDirs += $minecraftInstances
                }

                if (Test-Path -Path $prismLauncherDir) {
                    $prismInstances = Get-ChildItem -Path $prismLauncherDir -Directory | Where-Object { Test-Path -Path (Join-Path $_.FullName "minecraft\options.txt") } | Select-Object -ExpandProperty Name | ForEach-Object { "$_ (Prism Launcher)" }
                    $instanceDirs += $prismInstances
                }

                if (Test-Path -Path $fjordLauncherDir) {
                    $fjordInstances = Get-ChildItem -Path $fjordLauncherDir -Directory | Where-Object { Test-Path -Path (Join-Path $_.FullName "minecraft\options.txt") } | Select-Object -ExpandProperty Name | ForEach-Object { "$_ (Fjord Launcher)" }
                    $instanceDirs += $fjordInstances
                }

                if ($instanceDirs.Count -eq 0) {
                    Write-Host "Nie znaleziono zadnych instancji Minecraft z plikiem 'options.txt'." -ForegroundColor Red
                    return
                } else {
                    Write-Host "Znalezione instancje Minecraft:" -ForegroundColor Green
                    $instanceDirs | ForEach-Object { Write-Host $_ -ForegroundColor Cyan }
                }

                $sourceInstance = Read-Host "Podaj nazwe instancji z ktorej chcesz przeniesc pliki konfiguracyjne" 
                $destinationInstance = Read-Host "Podaj nazwe instancji do ktorej chcesz przeniesc pliki konfiguracyjne" 

                $sourcePath = ""
                $destinationPath = ""

                if (Test-Path -Path (Join-Path $minecraftDir $sourceInstance)) {
                    $sourcePath = Join-Path $minecraftDir $sourceInstance
                } elseif (Test-Path -Path (Join-Path $prismLauncherDir $sourceInstance)) {
                    $sourcePath = Join-Path $prismLauncherDir $sourceInstance
                } elseif (Test-Path -Path (Join-Path $fjordLauncherDir $sourceInstance)) {
                    $sourcePath = Join-Path $fjordLauncherDir $sourceInstance
                } else {
                    throw "Nie znaleziono instancji zrodlowej."
                }

                if (Test-Path -Path (Join-Path $minecraftDir $destinationInstance)) {
                    $destinationPath = Join-Path $minecraftDir $destinationInstance
                } elseif (Test-Path -Path (Join-Path $prismLauncherDir $destinationInstance)) {
                    $destinationPath = Join-Path $prismLauncherDir $destinationInstance
                } elseif (Test-Path -Path (Join-Path $fjordLauncherDir $destinationInstance)) {
                    $destinationPath = Join-Path $fjordLauncherDir $destinationInstance
                } else {
                    throw "Nie znaleziono instancji docelowej."
                }

                $sourceOptionsPath = Join-Path $sourcePath "minecraft\options.txt"
                $destinationOptionsPath = Join-Path $destinationPath "minecraft\options.txt"

                if (Test-Path -Path $sourceOptionsPath) {
                    Copy-Item -Path $sourceOptionsPath -Destination $destinationOptionsPath -Force
                    Write-Host "Plik 'options.txt' zostal skopiowany z $sourceInstance do $destinationInstance." -ForegroundColor Green
                } else {
                    throw "Plik 'options.txt' nie istnieje w instancji zrodlowej."
                }
            }

            try {
                TransferConfigFiles
            } catch {
                Write-Host "Wystapil blad: $_. Ponawianie operacji..." -ForegroundColor Red
                TransferConfigFiles
            }
        }
        "6" {
            exit
        }
        default {
            Write-Host "Nieprawidlowy wybor. Sprobuj ponownie." -ForegroundColor Red
        }
    }
}