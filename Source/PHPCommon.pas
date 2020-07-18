{*******************************************************}
{                     PHP4Delphi                        }
{               PHP - Delphi interface                  }
{                                                       }
{ Developers:                                           }
{ Serhiy Perevoznyk                                     }
{ serge_perevoznyk@hotmail.com                          }
{ Michael Maroszek                                      }
{ maroszek@gmx.net                                      }
{                                                       }
{ http://users.chello.be/ws36637                        }
{*******************************************************}
{$I PHP.INC}

{ $Id: phpcommon.pas,v 7.4 10/2009 delphi32 Exp $ }

unit PHPCommon;

interface

uses
  Windows, Messages, SysUtils, Classes,
  {$if CompilerVersion > 21}
  VCL.Controls,
  VCL.Dialogs,
  VCL.Forms, VCL.Graphics,
  {$elseif defined(FMX)}
  FMX.Controls,
  FMX.Dialogs,
  FMX.Forms, FMX.Graphics,
  {$else}
    {$ifdef KYLIX}
    QControls,
    QDialogs,
    QForms, QGraphics,
    {$else}
    Controls,
    Dialogs,
    Forms, Graphics,
    {$endif}
  {$ifend}

  ZendTypes, ZendAPI, PHPTypes, PHPAPI;

type
  EDelphiErrorEx = class(Exception);
  EPHPErrorEx = class(Exception);

  TPHPErrorType = (
  etError,      //0
  etWarning,    //1
  etParse,      //2
  etNotice,
  etCoreError,
  etCoreWarning,
  etCompileError,
  etCompileWarning,
  etUserError,
  etUserWarning,
  etUserNotice,
  etUnknown);

  TPHPExecuteMethod = (emServer, emGet);

  TPHPAboutInfo = (abPHP4Delphi);

  TPHPVariable = class(TCollectionItem)
  private
    FName  : zend_ustr;
    FValue : zend_ustr;
    function GetAsBoolean: boolean;
    function GetAsFloat: double;
    function GetAsInteger: integer;
    procedure SetAsBoolean(const Value: boolean);
    procedure SetAsFloat(const Value: double);
    procedure SetAsInteger(const Value: integer);
  protected
    function  GetDisplayName : string; override;
  public
    property AsInteger : integer read GetAsInteger write SetAsInteger;
    property AsBoolean : boolean read GetAsBoolean write SetAsBoolean;
    property AsString  : zend_ustr read FValue write FValue;
    property AsFloat   : double  read GetAsFloat write SetAsFloat;
  published
    property Name  : zend_ustr read FName write FName;
    property Value : zend_ustr read FValue write FValue;
  end;

  TPHPVariables = class(TCollection)
  private
    FOwner : TComponent;
    procedure SetItem(Index: Integer; const Value: TPHPVariable);
    function  GetItem(Index: Integer): TPHPVariable;
  protected
    function  GetOwner : TPersistent; override;
  public
    function Add: TPHPVariable;
    constructor Create(AOwner: TComponent);
    function GetVariables : zend_ustr;
    function IndexOf(AName : zend_ustr) : integer;
    procedure AddRawString(AString : zend_ustr);
    property Items[Index: Integer]: TPHPVariable read GetItem write SetItem; default;
    function ByName(AName : zend_ustr) : TPHPVariable;
  end;

  TPHPConstant = class(TCollectionItem)
  private
    FName  : zend_ustr;
    FValue : zend_ustr;
  protected
    function GetDisplayName : string; override;
  published
    property Name  : zend_ustr read FName write FName;
    property Value : zend_ustr read FValue write FValue;
  end;

  TPHPConstants = class(TCollection)
  private
    FOwner : TComponent;
    procedure SetItem(Index: Integer; const Value: TPHPConstant);
    function  GetItem(Index: Integer): TPHPConstant;
  protected
    function  GetOwner : TPersistent; override;
  public
    function Add: TPHPConstant;
    constructor Create(AOwner: TComponent);
    function IndexOf(AName : zend_ustr) : integer;
    property Items[Index: Integer]: TPHPConstant read GetItem write SetItem; default;
  end;

  TPHPHeader = class(TCollectionItem)
  private
   FHeader : String;
  published
   property Header : string read FHeader write FHeader;
  end;

  TPHPHeaders = class(TCollection)
   private
    FOwner : TComponent;
    procedure SetItem(Index: Integer; const Value: TPHPHeader);
    function  GetItem(Index: Integer): TPHPHeader;
  protected
    function  GetOwner : TPersistent; override;
  public
    function Add: TPHPHeader;
    constructor Create(AOwner: TComponent);
    function GetHeaders : zend_ustr;
    property Items[Index: Integer]: TPHPHeader read GetItem write SetItem; default;
  end;

  TPHPComponent = class(TComponent)
  private
    FAbout : TPHPAboutInfo;
  protected
  public
  published
    property  About : TPHPAboutInfo read FAbout write FAbout stored False;
  end;



implementation


{ TPHPVariables }

function TPHPVariables.Add: TPHPVariable;
begin
  result := TPHPVariable(inherited Add);
end;

constructor TPHPVariables.Create(AOwner: TComponent);
begin
 inherited create(TPHPVariable);
 FOwner := AOwner;
end;

function TPHPVariables.GetItem(Index: Integer): TPHPVariable;
begin
  Result := TPHPVariable(inherited GetItem(Index));
end;

procedure TPHPVariables.SetItem(Index: Integer; const Value: TPHPVariable);
begin
  inherited SetItem(Index, Value)
end;

function TPHPVariables.GetOwner : TPersistent;
begin
  Result := FOwner;
end;

function TPHPVariables.GetVariables: zend_ustr;
var i : integer;
begin
  for i := 0 to Count - 1 do
    begin
      Result := Result + Items[i].FName + '=' + Items[i].FValue;
      if i < Count - 1 then
        Result := Result + '&';
    end;
end;

function TPHPVariables.IndexOf(AName: zend_ustr): integer;
var
 i : integer;
begin
 Result := -1;
 for i := 0 to Count - 1 do
  begin
    if SameText(Items[i].Name, AName) then
     begin
       Result := i;
       break;
     end;
  end;
end;

procedure TPHPVariables.AddRawString(AString : zend_ustr);
var
 SL : TStringList;
 i  : integer;
 j  : integer;
 V  :  TPHPVariable;
begin
  if AString[Length(AString)] = ';' then
   SetLength(AString, Length(AString)-1);
  SL := TStringList.Create;

  ExtractStrings([';'], [], PWideChar(WideString(AString)), SL);

  for i := 0 to SL.Count - 1 do
   begin
     j := IndexOf(SL.Names[i]);
     if  j= -1 then
      begin
        V := Add;
        V.Name := SL.Names[i];
        V.Value := Copy(SL[I], Length(SL.Names[i]) + 2, MaxInt);
      end
       else
        begin
          Items[j].Value := Copy(SL[I], Length(SL.Names[i]) + 2, MaxInt);
        end;
   end;
  SL.Free;
end;

function TPHPVariables.ByName(AName: zend_ustr): TPHPVariable;
var
 i : integer;
begin
 Result := nil;
 for i := 0 to Count - 1 do
  begin
    if SameText(Items[i].Name, AName) then
     begin
       Result := Items[i];
       break;
     end;
  end;
end;


{ TPHPVariable }

function TPHPVariable.GetAsBoolean: boolean;
begin
  if FValue = '' then
   begin
    Result := false;
    Exit;
   end;

 if SameText(FValue, 'True') then
  Result := true
   else
    Result := false;
end;

function TPHPVariable.GetAsFloat: double;
begin
  if FValue = '' then
   begin
    Result := 0;
    Exit;
   end;

  Result := ValueToFloat(FValue);
end;

function TPHPVariable.GetAsInteger: integer;
var
 c: CharPtr;
begin
{$if CompilerVersion > 21}
  c := FormatSettings.DecimalSeparator;
  try
   FormatSettings.DecimalSeparator := '.';
   Result := Round(ValueToFloat(FValue));
  finally
    FormatSettings.DecimalSeparator := c;
  end;
{$else}
  c := DecimalSeparator;
  try
   DecimalSeparator := '.';
   Result := Round(ValueToFloat(FValue));
  finally
    DecimalSeparator := c;
  end;
{$ifend}
end;

function TPHPVariable.GetDisplayName: string;
begin
  if FName = '' then
   result := inherited GetDisplayName
    else
      Result := FName;
end;

procedure TPHPVariable.SetAsBoolean(const Value: boolean);
begin
  if Value then
   FValue := 'True'
    else
      FValue := 'False';
end;

procedure TPHPVariable.SetAsFloat(const Value: double);
begin
  FValue := FloatToValue(Value);
end;

procedure TPHPVariable.SetAsInteger(const Value: integer);
var
 c: CharPtr;
begin
{$if CompilerVersion > 21}
  c := FormatSettings.DecimalSeparator;
  try
   FormatSettings.DecimalSeparator := '.';
   FValue := IntToStr(Value);
  finally
    FormatSettings.DecimalSeparator := c;
  end;
{$else}
  c := DecimalSeparator;
  try
   DecimalSeparator := '.';
   FValue := IntToStr(Value);
  finally
    DecimalSeparator := c;
  end;
{$ifend}
end;

{ TPHPConstant }

function TPHPConstant.GetDisplayName: string;
begin
  if FName = '' then
   result := inherited GetDisplayName
    else
      Result := FName;
end;


{ TPHPConstants }

function TPHPConstants.Add: TPHPConstant;
begin
  result := TPHPConstant(inherited Add);
end;

constructor TPHPConstants.Create(AOwner: TComponent);
begin
 inherited Create(TPHPConstant);
 FOwner := AOwner;
end;

function TPHPConstants.GetItem(Index: Integer): TPHPConstant;
begin
  Result := TPHPConstant(inherited GetItem(Index));
end;

function TPHPConstants.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TPHPConstants.IndexOf(AName: zend_ustr): integer;
var
 i : integer;
begin
 Result := -1;
 for i := 0 to Count - 1 do
  begin
    if SameText(Items[i].Name, AName) then
     begin
       Result := i;
       break;
     end;
  end;
end;

procedure TPHPConstants.SetItem(Index: Integer; const Value: TPHPConstant);
begin
  inherited SetItem(Index, Value)
end;


{ TPHPHeaders }

function TPHPHeaders.Add: TPHPHeader;
begin
  result := TPHPHeader(inherited Add);
end;

constructor TPHPHeaders.Create(AOwner: TComponent);
begin
 inherited create(TPHPHeader);
 FOwner := AOwner;
end;

function TPHPHeaders.GetItem(Index: Integer): TPHPHeader;
begin
  Result := TPHPHeader(inherited GetItem(Index));
end;

procedure TPHPHeaders.SetItem(Index: Integer; const Value: TPHPHeader);
begin
  inherited SetItem(Index, Value)
end;

function TPHPHeaders.GetOwner : TPersistent;
begin
  Result := FOwner;
end;

function TPHPHeaders.GetHeaders: zend_ustr;
var i : integer;
begin
  for i := 0 to Count - 1 do
    begin
      Result := Result + Items[i].FHeader;
      if i < Count - 1 then
        Result := Result + #13#10;
    end;
end;

end.
