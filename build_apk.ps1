$jdkHome = "C:\Program Files\Microsoft\jdk-17.0.19.10-hotspot"
$sdkDir  = "$env:LOCALAPPDATA\Android\Sdk"
$env:JAVA_HOME      = $jdkHome
$env:ANDROID_HOME   = $sdkDir
$env:ANDROID_SDK_ROOT = $sdkDir
$env:Path = "$jdkHome\bin;$sdkDir\cmdline-tools\latest\bin;$sdkDir\platform-tools;" + $env:Path
Write-Host "Java: $(java -version 2>&1 | Select-Object -First 1)"
Write-Host "Building APK..."
flutter build apk --release
Write-Host "BUILD DONE - Exit: $LASTEXITCODE"
