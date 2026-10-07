; Inno Setup script. Build: iscc /DMyVersion=0.1.0 packaging\windows\canto.iss
#ifndef MyVersion
  #define MyVersion "0.1.0"
#endif
[Setup]
AppId={{6F1C2C4E-7E43-4C5B-9C3E-CA7700C0A001}
AppName=Canto
AppVersion={#MyVersion}
AppPublisher=chinatsu033
AppPublisherURL=https://github.com/chinatsu033/Canto
DefaultDirName={autopf}\Canto
DefaultGroupName=Canto
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputDir=..\..\dist
OutputBaseFilename=Canto-{#MyVersion}-windows-x86-setup
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\Canto.exe
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "ja"; MessagesFile: "compiler:Languages\Japanese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{group}\Canto"; Filename: "{app}\Canto.exe"
Name: "{autodesktop}\Canto"; Filename: "{app}\Canto.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\Canto.exe"; Description: "{cm:LaunchProgram,Canto}"; Flags: nowait postinstall skipifsilent
