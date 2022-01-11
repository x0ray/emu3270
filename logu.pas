///////////////////////////////////////////////////////////////////////////
// Project:   Emu3270
// Program:   logu.pas
// Language:  Object Pascal - Delphi ver 2.0
// Support:   David Fahey
// Date:      14Apr97
// Purpose:   To display debugging info on a scrollable log.
// History:   14Apr97  Initial coding                              DAF
// Notes:     None
///////////////////////////////////////////////////////////////////////////

unit logu;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  Tlogf = class(TForm)
    Memo1: TMemo;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  logf: Tlogf;

implementation

{$R *.DFM}

uses
  Screenu ;

procedure Tlogf.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  deb := false ;
end;

end.
