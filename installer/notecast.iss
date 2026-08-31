#define MyAppName "Notecast"
#ifndef MyAppVersion
  #define MyAppVersion "1.1.1"
#endif
#ifndef BuildDir
  #define BuildDir "..\build\windows\x64\runner\Release"
#endif

[Setup]
AppId={{B7315D9D-2773-4AAC-AFCD-42C0D62AB661}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher=runninhwater25-svg
DefaultDirName={autopf}\Notecast
DefaultGroupName=Notecast
DisableProgramGroupPage=yes
OutputDir=..\release
OutputBaseFilename=Notecast-Windows-Setup
SetupIconFile=..\windows\runner\resources\app_icon.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
UninstallDisplayIcon={app}\Notecast.exe

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Notecast"; Filename: "{app}\Notecast.exe"
Name: "{autodesktop}\Notecast"; Filename: "{app}\Notecast.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "创建桌面快捷方式"; GroupDescription: "附加图标："; Flags: unchecked

[Run]
Filename: "{app}\Notecast.exe"; Description: "启动 Notecast"; Flags: nowait postinstall skipifsilent
