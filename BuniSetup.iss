#define MyAppName "Buni"
#define MyAppVersion "1.3.6"
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
Source: "installer-input\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
; 훅 설치 스크립트 및 관련 파일
Source: "installer-input\install_hooks.py"; DestDir: "{app}"; Flags: ignoreversion
Source: "installer-input\requirements.txt"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; Python이 없으면 winget으로 자동 설치
Filename: "powershell.exe"; \
  Parameters: "-ExecutionPolicy Bypass -Command ""if (-not (Get-Command python -ErrorAction SilentlyContinue)) {{ winget install -e --id Python.Python.3 --silent --accept-package-agreements --accept-source-agreements }}"""; \
  StatusMsg: "Python 설치 중..."; Flags: runhidden waituntilterminated
; pip 패키지 설치
Filename: "python.exe"; Parameters: "-m pip install -r ""{app}\requirements.txt"" --quiet"; \
  StatusMsg: "패키지 설치 중..."; Flags: runhidden waituntilterminated
; Claude Code 훅 자동 등록
Filename: "python.exe"; Parameters: """{app}\install_hooks.py"""; \
  StatusMsg: "Claude Code 훅 설치 중..."; Flags: runhidden waituntilterminated
; 설치 완료 후 Buni 자동 실행
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; \
  Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "python.exe"; Parameters: "-c ""import pathlib; [p.unlink(missing_ok=True) for p in (pathlib.Path.home()/'.claude').glob('companion-*.py')]"""; \
  RunOnceId: "RemoveHooks"; Flags: runhidden waituntilterminated

[Code]
function IsPythonInstalled(): Boolean;
var
  ResultCode: Integer;
begin
  Result := Exec('python.exe', '--version', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) and (ResultCode = 0);
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: Integer;
begin
  Result := '';
  if not IsPythonInstalled() then begin
    // winget 없는 환경 대비: python.org에서 직접 다운로드
    if not Exec('winget.exe', '--version', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then begin
      if MsgBox('Python이 설치되어 있지 않습니다.' + #13#10 +
                '지금 python.org를 열어 설치하시겠습니까?', mbConfirmation, MB_YESNO) = IDYES then begin
        ShellExec('open', 'https://www.python.org/downloads/', '', '', SW_SHOW, ewNoWait, ResultCode);
        Result := 'Python을 설치한 후 다시 실행해주세요.';
      end else
        Result := 'Python 설치가 필요합니다.';
    end;
  end;
end;
