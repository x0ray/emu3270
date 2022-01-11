///////////////////////////////////////////////////////////////////////////   
// Project:   Emu3270
// Program:   ConnectU.pas
// Language:  Object Pascal - Delphi ver 2.0
// Support:   David Fahey
// Date:      06Mar97
// Purpose:   To request the name of the host system to connect to. A
//            blank host name is not acceptable.
// History:   05Mar97  Initial coding                              DAF
// Notes:     None
///////////////////////////////////////////////////////////////////////////

unit ConnectU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls ;

type
  TConnectHost = class(TForm)
    Con: TButton;
    Can: TButton;
    HostName: TEdit;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ConClick(Sender: TObject);
    procedure CanClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ConnectHost: TConnectHost;

implementation

{$R *.DFM}

uses screenu ;

procedure TConnectHost.FormCreate(Sender: TObject);
begin
  ConnectHostName := '' ;
  HostName.Text := '' ;
end;

procedure TConnectHost.ConClick(Sender: TObject);
begin
  if HostName.Text <> '' then
    begin
      ConnectHostName := HostName.Text ;
      ConnectHost.Close() ;
    end
  else
    ShowMessage('Host name can not be blank.') ;
end;

procedure TConnectHost.CanClick(Sender: TObject);
begin
  ConnectHost.Close() ;
end;


end.
