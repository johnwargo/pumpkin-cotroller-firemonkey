unit main;

interface

uses

  log, RzCommon,

  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ListBox, FMX.Edit,

  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent;

type
  TfrmMain = class(TForm)
    StatusBar1: TStatusBar;
    Label1: TLabel;
    btnYellow: TButton;
    btnRed: TButton;
    btnPurple: TButton;
    btnOrange: TButton;
    btnGreen: TButton;
    btnBlue: TButton;
    btnLightning: TButton;
    btnRandom: TButton;
    btnAllOff: TButton;
    Label2: TLabel;
    ComboOption: TComboBox;
    Option0: TListBoxItem;
    Option1: TListBoxItem;
    Option2: TListBoxItem;
    Option3: TListBoxItem;
    Option4: TListBoxItem;
    Option5: TListBoxItem;
    Label3: TLabel;
    editHostAddress: TEdit;
    Registry: TRzRegIniFile;
    StyleBook1: TStyleBook;
    HTTP: TNetHTTPRequest;
    HttpClient: TNetHTTPClient;
    procedure editHostAddressChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnAllOffClick(Sender: TObject);
    procedure btnRandomClick(Sender: TObject);
    procedure btnLightningClick(Sender: TObject);
    procedure btnBlueClick(Sender: TObject);
    procedure btnGreenClick(Sender: TObject);
    procedure btnOrangeClick(Sender: TObject);
    procedure btnPurpleClick(Sender: TObject);
    procedure btnRedClick(Sender: TObject);
    procedure btnYellowClick(Sender: TObject);
    procedure ComboOptionChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HTTPClientSendData(const Sender: TObject;
      AContentLength, AWriteCount: Int64; var AAbort: Boolean);
    procedure HTTPClientReceiveData(const Sender: TObject;
      AContentLength, AReadCount: Int64; var AAbort: Boolean);
    procedure HTTPClientRequestCompleted(const Sender: TObject;
      const AResponse: IHTTPResponse);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  RegistrySection: String = 'Pumpkin Controller';
  KeyHostAddress: String = 'HostAddress';

var
  frmMain: TfrmMain;
  selectedOption: Integer = -1;

implementation

{$R *.fmx}

Procedure SendCommand(cmdStr: String);
var
  cmd, HostAddress: String;
begin
  HostAddress := frmMain.editHostAddress.Text;
  if Length(HostAddress) > 0 then begin
    cmd := 'http://' + HostAddress + '/' + cmdStr;
    LogMessage('Sending command: ' + cmd);
    frmMain.HttpClient.Get(cmd);
  end else begin
    LogMessage('Error: Missing Host Address');
    MessageDlg('You must provide a valid Host Address first',
      TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);
  end;
end;

Procedure DoColor(colorIdx: Integer);
var
  cmdStr: String;
begin
  if selectedOption < 1 then
    cmdStr := 'color:' + IntToStr(colorIdx)
  else
    cmdStr := 'flash:' + IntToStr(colorIdx) + ':' + IntToStr(selectedOption);
  SendCommand(cmdStr);
end;

// ==================================================================

procedure TfrmMain.btnAllOffClick(Sender: TObject);
begin
  SendCommand('off');
end;

procedure TfrmMain.btnRandomClick(Sender: TObject);
begin
  SendCommand('random');
end;

procedure TfrmMain.btnLightningClick(Sender: TObject);
begin
  SendCommand('lightning');
end;

procedure TfrmMain.btnBlueClick(Sender: TObject);
begin
  DoColor(0);
end;

procedure TfrmMain.btnGreenClick(Sender: TObject);
begin
  DoColor(1);
end;

procedure TfrmMain.btnOrangeClick(Sender: TObject);
begin
  DoColor(2);
end;

procedure TfrmMain.btnPurpleClick(Sender: TObject);
begin
  DoColor(3);
end;

procedure TfrmMain.btnRedClick(Sender: TObject);
begin
  DoColor(4);
end;

procedure TfrmMain.btnYellowClick(Sender: TObject);
begin
  DoColor(5);
end;

procedure TfrmMain.ComboOptionChange(Sender: TObject);
begin
  selectedOption := ComboOption.ItemIndex;
end;

procedure TfrmMain.editHostAddressChange(Sender: TObject);
begin
  // save the changes to the registry
  Registry.WriteString(RegistrySection, KeyHostAddress,
    Trim(editHostAddress.Text));
end;

procedure TfrmMain.FormActivate(Sender: TObject);
begin
  OpenLog;
  editHostAddress.Text := Registry.ReadString(RegistrySection,
    KeyHostAddress, '');
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CloseLog;
end;

procedure TfrmMain.HTTPClientReceiveData(const Sender: TObject;
  AContentLength, AReadCount: Int64; var AAbort: Boolean);
begin
  LogMessage('Data received: Content Length ' + IntToStr(AContentLength) +
    ' Read Count ' + IntToStr(AReadCount));
end;

procedure TfrmMain.HTTPClientRequestCompleted(const Sender: TObject;
  const AResponse: IHTTPResponse);
begin
  LogMessage('Request completed: ' + AResponse.StatusText + ' (' +
    IntToStr(AResponse.StatusCode) + ')');
  if AResponse.StatusCode <> 200 then begin
    MessageDlg(IntToStr(AResponse.StatusCode) + ': ' + AResponse.StatusText,
      TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);
  end;
end;

procedure TfrmMain.HTTPClientSendData(const Sender: TObject;
  AContentLength, AWriteCount: Int64; var AAbort: Boolean);
begin
  LogMessage('Data sent: Content Length ' + IntToStr(AContentLength) +
    ' Write Count ' + IntToStr(AWriteCount));
end;

end.
