{*******************************************************}
{                     PHP4Delphi                        }
{               PHP - Delphi interface                  }
{ Author:                                               }
{ Serhiy Perevoznyk                                     }
{ serge_perevoznyk@hotmail.com                          }
{ http://users.telenet.be/ws36637                       }
{*******************************************************}

{$I PHP.INC}

unit frm_phpDemo;

{ $Id: frm_phpDemo.pas,v 7.4 10/2009 delphi32 Exp $ }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OleCtrls, SHDocVw, StdCtrls, ExtCtrls, ActiveX,  php4delphi, PHPCommon,
  PHPCustomLibrary, phpLibrary;

type
  TfrmPHPDemo = class(TForm)
    pnlButtons: TPanel;
    Panel2: TPanel;
    btnExecuteCode: TButton;
    WebBrowser1: TWebBrowser;
    psvPHP: TpsvPHP;
    btnExecuteFile: TButton;
    OpenDialog1: TOpenDialog;
    Panel3: TPanel;
    memPHPCode: TMemo;
    lbVariables: TListBox;
    Splitter1: TSplitter;
    Label1: TLabel;
    Label2: TLabel;
    PHPEngine: TPHPEngine;
    PHPSystemLibrary1: TPHPSystemLibrary;
    procedure FormCreate(Sender: TObject);
    procedure btnExecuteFileClick(Sender: TObject);
    procedure btnExecuteCodeClick(Sender: TObject);
    procedure psvPHPReadPost(Sender: TObject; Stream: TStream);
    procedure FormDestroy(Sender: TObject);
    procedure PHPEngineLogMessage(Sender: TObject; AText: AnsiString);
  private
    { Private declarations }
  public
    { Public declarations }
     procedure DisplayResultInBrowser(AStr : AnsiString);
     procedure DisplayVariables;
  end;

var
  frmPHPDemo: TfrmPHPDemo;

implementation



{$R *.DFM}
{$R internal.res}

function StringToOleStream(const AString: AnsiString): IStream;
var
  MemHandle: THandle;
  Len : integer;
begin
  Len := strlen(PAnsiChar(AString));
  MemHandle := GlobalAlloc(GPTR, len + 1);
  if MemHandle <> 0 then begin
    Move(AString[1], PChar(MemHandle)^, strlen(PAnsiChar(AString)) + 1);
    CreateStreamOnHGlobal(MemHandle, True, Result);
  end else
    Result := nil;
end;

procedure TfrmPHPDemo.FormCreate(Sender: TObject);
var
 Url : OleVariant;
 Doc : AnsiString;
begin
  PHPEngine.StartupEngine;
  Url := 'about:blank';
  Webbrowser1.Navigate2(Url);
  Doc := psvPHP.RunCode('phpinfo();');
  DisplayResultInBrowser(Doc);
  DisplayVariables;
end;



procedure TfrmPHPDemo.btnExecuteFileClick(Sender: TObject);
var
 doc : string;
begin
  if OpenDialog1.Execute then
   begin
     doc := '';
     MemPHPCode.Lines.Clear;
     MemPHPCode.Lines.LoadFromFile(OpenDialog1.FileName);
     doc := psvPHP.Execute(OpenDialog1.FileName);
     DisplayResultInBrowser(doc);
     DisplayVariables;
   end;
end;

procedure TfrmPHPDemo.DisplayResultInBrowser(AStr: AnsiString);
var
 Stream: IStream;
 StreamInit: IPersistStreamInit;
begin
  if AStr = '' then
   begin
     WebBrowser1.Navigate('about:The script returns no result');
     Exit;
   end;
  AStr := StringReplace(AStr, 'src="?=PHPE9568F34-D428-11d2-A769-00AA001ACF42"',
  'src="res://'+ParamStr(0)+'/php"', [rfReplaceAll, rfIgnoreCase]);

  AStr := StringReplace(AStr, 'src="?=PHPE9568F35-D428-11d2-A769-00AA001ACF42"',
  'src="res://'+ ParamStr(0) + '/zend2"', [rfReplaceAll, rfIgnoreCase]);

  Stream := StringToOleStream(AStr);
  StreamInit := Webbrowser1.Document as IPersistStreamInit;
  StreamInit.InitNew;
  StreamInit.Load(Stream);
end;

procedure TfrmPHPDemo.DisplayVariables;
var
 i : integer;
begin
  lbVariables.Items.Clear;
  for i := 0 to psvPHP.Variables.Count - 1 do
   begin
     lbVariables.Items.Add(psvphp.Variables[i].Name + '=' + psvPHP.Variables[i].Value);
   end;
  lbVariables.Items.Add('');
  lbVariables.Items.Add('Headers:');
  lbVariables.Items.Add('');
  for i := 0 to psvPHP.Headers.Count - 1 do
   lbVariables.Items.Add(psvPHP.Headers[i].Header);
end;

procedure TfrmPHPDemo.btnExecuteCodeClick(Sender: TObject);
var
 doc : string;
begin
  doc := '';
  doc := psvPHP.RunCode(memPHPCode.Text);
  DisplayResultInBrowser(doc);
  DisplayVariables;
end;

procedure TfrmPHPDemo.psvPHPReadPost(Sender: TObject; Stream: TStream);
var
  PostData : string;
begin
  PostData :='postname=postvalue'#0;
  Stream.Write(PostData[1], length(PostData));
end;

procedure TfrmPHPDemo.FormDestroy(Sender: TObject);
begin
   PHPEngine.ShutdownAndWaitFor;
end;

procedure TfrmPHPDemo.PHPEngineLogMessage(Sender: TObject; AText: AnsiString);
begin
  ShowMessage('Trapped ' + AText);
end;

end.
