#define MyAppName "Buni"
#define MyAppVersion "1.3.3"
#define MyAppPublisher "EloyYang"
#define MyAppURL "https://github.com/EloyYang/buni"
#define MyAppExeName "Buni.exe"

[Setup]
AppId={{6A3F2E1D-8B4C-4F7A-9E2D-1C5A3B8F2E4D}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={localappdata}\Programs\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=dist
OutputBaseFilename=BuniSetup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
; Buni 메인 실행 파일 (PyInstaller 빌드 결과물)
Source: "..\buni\windows\dist\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
; 훅 설치 스크립트 및 관련 파일
Source: "..\buni\windows\install_hooks.py"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\buni\windows\requirements.txt"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; 설치 후 Claude Code 훅 자동 등록
Filename: "python.exe"; Parameters: """{app}\install_hooks.py"""; \
  Description: "Claude Code 훅 설치"; Flags: runhidden waituntilterminated
; 설치 완료 후 Buni 자동 실행
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; \
  Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "python.exe"; Parameters: "-c ""import shutil, pathlib; [p.unlink(missing_ok=True) for p in (pathlib.Path.home()/'.claude').glob('companion-*.py')]"""; \
  Flags: runhidden waituntilterminated

[Code]
function IsPythonInstalled(): Boolean;
var
  ResultCode: Integer;
begin
  Result := Exec('python.exe', '--version', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) and (ResultCode = 0);
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
  if not IsPythonInstalled() then begin
    MsgBox('Python이 설치되어 있지 않습니다.' + #13#10 +
           'https://www.python.org 에서 Python 3.10 이상을 설치 후 다시 실행해주세요.', mbError, MB_OK);
    Result := False;
  end;
end;
