#define MyAppName "Notecast 课程笔记"
#ifndef MyAppVersion
  #define MyAppVersion "1.1.0"
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
UninstallDisplayIcon={app}\course_notes_flutter.exe

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Notecast 课程笔记"; Filename: "{app}\course_notes_flutter.exe"
Name: "{autodesktop}\Notecast 课程笔记"; Filename: "{app}\course_notes_flutter.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "创建桌面快捷方式"; GroupDescription: "附加图标："; Flags: unchecked

[Run]
Filename: "{app}\course_notes_flutter.exe"; Description: "启动 Notecast 课程笔记"; Flags: nowait postinstall skipifsilent
