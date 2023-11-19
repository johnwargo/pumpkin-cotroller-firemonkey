unit Log;

interface

Uses

  SysUtils, System.IOUtils, Vcl.Dialogs;

// StBase, , StFileOp, StSpawn, StDate, StDateSt, StVInfo, stSystem, StFirst;

var
  LogOpen: boolean = false;
  LogFileName: string;
  F: TextFile;

procedure OpenLog;
procedure CloseLog;
procedure LogMessage(MessageText: string);
procedure LogBoolean(varName: string; boolVal: boolean);
function getLogFilePath: string;

implementation

procedure OpenLog;

begin
  // is the log already open?
  if LogOpen then
    // then leave
    Exit;

  // build a file name based on the app executable filename
  LogFileName := TPath.GetTempPath + TPath.GetFileNameWithoutExtension
    (ParamStr(0)) + '.log';

  try
    // try to create the log file and open it
    AssignFile(F, LogFileName);
    Rewrite(F);
    LogOpen := true;
    LogMessage('Log opened');
  except
    on E: Exception do begin
      LogOpen := false;
      MessageDlg(E.Message, mtError, [mbOk], 0, mbOk);
    end;
  end;

end;

procedure CloseLog;
begin
  LogOpen := false;
  LogMessage('Log closed');
  CloseFile(F);
end;

procedure LogMessage(MessageText: string);
begin
  if Not LogOpen then
    Exit;

  Writeln(F, DateTimeToStr(Now) + ' ' + MessageText);
  Flush(F);
end;

procedure LogBoolean(varName: string; boolVal: boolean);
begin

  if Not LogOpen then
    Exit;

  if boolVal then begin
    LogMessage(Format('Value: %s is True', [varName]));
  end else begin
    LogMessage(Format('Value: %s is False', [varName]));
  end;
end;

function getLogFilePath: string;
begin
  Result := LogFileName;
end;

end.
