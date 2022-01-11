///////////////////////////////////////////////////////////////////////////
// Project:   Emu3270
// Program:   AboutU.pas
// Language:  Object Pascal - Delphi ver 2.0
// Support:   David Fahey
// Date:      06Mar97
// Purpose:   To display the about box.
// History:   05Mar97  Initial coding                              DAF
// Notes:     None
///////////////////////////////////////////////////////////////////////////

unit AboutU;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    OKButton: TButton;
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.DFM}

end.
 
