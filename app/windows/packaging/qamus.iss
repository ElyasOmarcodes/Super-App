; Packs the Windows bundle into one self-contained .exe.
;
; Flutter's Windows output is an executable plus flutter_windows.dll, the
; plugin DLLs and a data/ tree; none of it runs on its own. Inno Setup folds
; the whole directory into a single file that installs, registers a Start-menu
; entry and uninstalls cleanly — which is what "one exe" means on Windows.
;
; Built in CI as:
;   iscc /DBundleDir=... /DAppVersion=... windows\packaging\qamus.iss

#ifndef BundleDir
  #define BundleDir "..\..\build\windows\x64\runner\Release"
#endif
#ifndef AppVersion
  #define AppVersion "1.2.0"
#endif

#define AppName "Qamus al-Maani"
#define AppPublisher "M. Elyas Omar"
#define AppExe "qamus.exe"

[Setup]
AppId={{7C5CFF01-6D3A-4A1C-9F7E-2C5A8B1D3E60}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={autopf}\Qamus
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
; No admin rights: the dictionary is a personal reference, and a per-user
; install lets anyone run it on a locked-down machine.
PrivilegesRequired=lowest
OutputBaseFilename=qamus-setup
; The corpus inside is already LZMA2; re-compressing it gains nothing, but
; the DLLs and the engine compress well, so LZMA2 with a large dictionary
; still pays for itself over the bundle as a whole.
Compression=lzma2/ultra64
SolidCompression=yes
LZMANumBlockThreads=4
WizardStyle=modern
UninstallDisplayIcon={app}\{#AppExe}
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "{#BundleDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent
