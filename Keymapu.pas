///////////////////////////////////////////////////////////////////////////
// Project:   Emu3270
// Program:   keymapu.pas
// Language:  Object Pascal - Delphi ver 2.0
// Support:   David Fahey
// Date:      14Apr97
// Purpose:   Changes the keyboard mapping used by the screenu unit.
// History:   14Apr97  Initial coding                              DAF
// Notes:     None
///////////////////////////////////////////////////////////////////////////

unit Keymapu;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, screenu ;

type
  Tkeymap = class(TForm)
    TabControl1: TTabControl;
    KEsc: TButton;
    KF1: TButton;
    KF2: TButton;
    KF3: TButton;
    KF4: TButton;
    KF5: TButton;
    KF6: TButton;
    KF7: TButton;
    KF8: TButton;
    KF9: TButton;
    Ktic: TButton;
    KTab: TButton;
    K1: TButton;
    K2: TButton;
    KF10: TButton;
    KF11: TButton;
    KF12: TButton;
    KPrt: TButton;
    KSLk: TButton;
    KPse: TButton;
    K3: TButton;
    K4: TButton;
    K5: TButton;
    K6: TButton;
    K7: TButton;
    K8: TButton;
    K9: TButton;
    K0: TButton;
    KMinus1: TButton;
    KEqual: TButton;
    KBkSpc: TButton;
    KCaps: TButton;
    KShift1: TButton;
    KCtrl1: TButton;
    KAlt1: TButton;
    KSpace: TButton;
    KAlt2: TButton;
    KCtrl2: TButton;
    KIns: TButton;
    KHom: TButton;
    KPUp: TButton;
    KDel: TButton;
    KEnd: TButton;
    KPDn: TButton;
    kUp: TButton;
    KDn: TButton;
    KLe: TButton;
    KRi: TButton;
    KQ: TButton;
    KW: TButton;
    KE: TButton;
    KR: TButton;
    KT: TButton;
    KY: TButton;
    KU: TButton;
    KI: TButton;
    KO: TButton;
    KP: TButton;
    KLSq: TButton;
    KRSq: TButton;
    KBkSlash: TButton;
    KA: TButton;
    KS: TButton;
    KD: TButton;
    KF: TButton;
    KG: TButton;
    KH: TButton;
    KJ: TButton;
    KK: TButton;
    KL: TButton;
    KSemi: TButton;
    KQuote: TButton;
    KEnter1: TButton;
    KZ: TButton;
    KX: TButton;
    KC: TButton;
    KV: TButton;
    KB: TButton;
    KN: TButton;
    KM: TButton;
    KComma: TButton;
    KDot1: TButton;
    KSlash1: TButton;
    KShift2: TButton;
    KNum: TButton;
    KSlash2: TButton;
    KStar: TButton;
    KMinus2: TButton;
    K7n: TButton;
    K8n: TButton;
    K9n: TButton;
    K6n: TButton;
    K3n: TButton;
    KDot2: TButton;
    K2n: TButton;
    K1n: TButton;
    K4n: TButton;
    K5n: TButton;
    K0n: TButton;
    KPlus: TButton;
    KEnter2: TButton;
    ListBox1: TListBox;
    Label1: TLabel;
    SetFn: TButton;
    OK: TButton;
    Cancel: TButton;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Panel1: TPanel;
    Label2: TLabel;
    KeyLabOld: TLabel;
    FuncLabOld: TLabel;
    Label3: TLabel;
    KeyLabNew: TLabel;
    FuncLabNew: TLabel;
    procedure KEscClick(Sender: TObject);
    procedure KF2Click(Sender: TObject);
    procedure KF3Click(Sender: TObject);
    procedure KF4Click(Sender: TObject);
    procedure KF5Click(Sender: TObject);
    procedure KF6Click(Sender: TObject);
    procedure KF7Click(Sender: TObject);
    procedure KF8Click(Sender: TObject);
    procedure KF9Click(Sender: TObject);
    procedure KF10Click(Sender: TObject);
    procedure KF11Click(Sender: TObject);
    procedure KF12Click(Sender: TObject);
    procedure KSLkClick(Sender: TObject);
    procedure KPseClick(Sender: TObject);
    procedure KticClick(Sender: TObject);
    procedure K1Click(Sender: TObject);
    procedure K2Click(Sender: TObject);
    procedure K3Click(Sender: TObject);
    procedure K4Click(Sender: TObject);
    procedure K5Click(Sender: TObject);
    procedure K6Click(Sender: TObject);
    procedure K7Click(Sender: TObject);
    procedure K8Click(Sender: TObject);
    procedure K9Click(Sender: TObject);
    procedure K0Click(Sender: TObject);
    procedure KMinus1Click(Sender: TObject);
    procedure KEqualClick(Sender: TObject);
    procedure KBkSpcClick(Sender: TObject);
    procedure KInsClick(Sender: TObject);
    procedure KHomClick(Sender: TObject);
    procedure KPUpClick(Sender: TObject);
    procedure KNumClick(Sender: TObject);
    procedure KSlash2Click(Sender: TObject);
    procedure KStarClick(Sender: TObject);
    procedure KMinus2Click(Sender: TObject);
    procedure KQClick(Sender: TObject);
    procedure KWClick(Sender: TObject);
    procedure KEClick(Sender: TObject);
    procedure KRClick(Sender: TObject);
    procedure KTClick(Sender: TObject);
    procedure KYClick(Sender: TObject);
    procedure KUClick(Sender: TObject);
    procedure KIClick(Sender: TObject);
    procedure KOClick(Sender: TObject);
    procedure KPClick(Sender: TObject);
    procedure KLSqClick(Sender: TObject);
    procedure KRSqClick(Sender: TObject);
    procedure KBkSlashClick(Sender: TObject);
    procedure KDelClick(Sender: TObject);
    procedure KEndClick(Sender: TObject);
    procedure KPDnClick(Sender: TObject);
    procedure K7nClick(Sender: TObject);
    procedure K8nClick(Sender: TObject);
    procedure K9nClick(Sender: TObject);
    procedure KPlusClick(Sender: TObject);
    procedure KCapsClick(Sender: TObject);
    procedure KAClick(Sender: TObject);
    procedure KSClick(Sender: TObject);
    procedure KDClick(Sender: TObject);
    procedure KFClick(Sender: TObject);
    procedure KGClick(Sender: TObject);
    procedure KHClick(Sender: TObject);
    procedure KJClick(Sender: TObject);
    procedure KKClick(Sender: TObject);
    procedure KLClick(Sender: TObject);
    procedure KSemiClick(Sender: TObject);
    procedure KQuoteClick(Sender: TObject);
    procedure KEnter1Click(Sender: TObject);
    procedure K4nClick(Sender: TObject);
    procedure K5nClick(Sender: TObject);
    procedure K6nClick(Sender: TObject);
    procedure KShift1Click(Sender: TObject);
    procedure KZClick(Sender: TObject);
    procedure KXClick(Sender: TObject);
    procedure KCClick(Sender: TObject);
    procedure KVClick(Sender: TObject);
    procedure KBClick(Sender: TObject);
    procedure KNClick(Sender: TObject);
    procedure KMClick(Sender: TObject);
    procedure KCommaClick(Sender: TObject);
    procedure KDot1Click(Sender: TObject);
    procedure KSlash1Click(Sender: TObject);
    procedure KShift2Click(Sender: TObject);
    procedure kUpClick(Sender: TObject);
    procedure K1nClick(Sender: TObject);
    procedure K2nClick(Sender: TObject);
    procedure K3nClick(Sender: TObject);
    procedure KEnter2Click(Sender: TObject);
    procedure KCtrl1Click(Sender: TObject);
    procedure KAlt1Click(Sender: TObject);
    procedure KSpaceClick(Sender: TObject);
    procedure KAlt2Click(Sender: TObject);
    procedure KCtrl2Click(Sender: TObject);
    procedure KLeClick(Sender: TObject);
    procedure KDnClick(Sender: TObject);
    procedure KRiClick(Sender: TObject);
    procedure K0nClick(Sender: TObject);
    procedure KDot2Click(Sender: TObject);
    procedure SetFnClick(Sender: TObject);
    procedure OKClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
    procedure KF1Click(Sender: TObject);
  private
    { Private declarations }   
    procedure DispAssoc ;
  public
    { Public declarations }
  end;

var
  keymap: Tkeymap;
  curKeyCode: integer ;
  tempKeyTable: TKeyTable ;

implementation

{$R *.DFM}

procedure Tkeymap.KEscClick(Sender: TObject);
begin
  curKeyCode := $1B ; { escape }   
  DispAssoc ;
end;

procedure Tkeymap.KF1Click(Sender: TObject);
begin 
  curKeyCode := $70 ; { F1 }
  DispAssoc ;
end;

procedure Tkeymap.KF2Click(Sender: TObject);
begin
  curKeyCode := $71 ; { F2 }  
  DispAssoc ;
end;

procedure Tkeymap.KF3Click(Sender: TObject);
begin
  curKeyCode := $72 ; { F3 }  
  DispAssoc ;
end;

procedure Tkeymap.KF4Click(Sender: TObject);
begin
  curKeyCode := $73 ; { F4 }  
  DispAssoc ;
end;

procedure Tkeymap.KF5Click(Sender: TObject);
begin
  curKeyCode := $74 ; { F5 }  
  DispAssoc ;
end;

procedure Tkeymap.KF6Click(Sender: TObject);
begin
  curKeyCode := $75 ; { F6 }  
  DispAssoc ;
end;

procedure Tkeymap.KF7Click(Sender: TObject);
begin
  curKeyCode := $76 ; { F7 }  
  DispAssoc ;
end;

procedure Tkeymap.KF8Click(Sender: TObject);
begin
  curKeyCode := $77 ; { F8 }  
  DispAssoc ;
end;

procedure Tkeymap.KF9Click(Sender: TObject);
begin
  curKeyCode := $78 ; { F9 }   
  DispAssoc ;
end;

procedure Tkeymap.KF10Click(Sender: TObject);
begin
  curKeyCode := $79 ; { F10 }  
  DispAssoc ;
end;

procedure Tkeymap.KF11Click(Sender: TObject);
begin
  curKeyCode := $7A ; { F11 }  
  DispAssoc ;
end;

procedure Tkeymap.KF12Click(Sender: TObject);
begin
  curKeyCode := $7B ; { F12 } 
  DispAssoc ;
end;

procedure Tkeymap.KSLkClick(Sender: TObject);
begin
  curKeyCode := $91 ; { Scroll Lock }   
  DispAssoc ;
end;

procedure Tkeymap.KPseClick(Sender: TObject);
begin
  curKeyCode := $13 ; { Pause }  
  DispAssoc ;
end;

procedure Tkeymap.KticClick(Sender: TObject);
begin
  curKeyCode := $C0 ; { Back Tick and Tilde }
  DispAssoc ;
end;

procedure Tkeymap.K1Click(Sender: TObject);
begin
  curKeyCode := $31 ; { Number 1 and Excalamation point ! }  
  DispAssoc ;
end;

procedure Tkeymap.K2Click(Sender: TObject);
begin
  curKeyCode := $32 ; { Number 2 and at sign @ }     
  DispAssoc ;
end;

procedure Tkeymap.K3Click(Sender: TObject);
begin
  curKeyCode := $33 ; { Number 3 and hatch #}  
  DispAssoc ;
end;

procedure Tkeymap.K4Click(Sender: TObject);
begin
  curKeyCode := $34 ; { Number 4 and dollar $ }   
  DispAssoc ;
end;

procedure Tkeymap.K5Click(Sender: TObject);
begin
  curKeyCode := $35 ; { Number 5 and percent % }  
  DispAssoc ;
end;

procedure Tkeymap.K6Click(Sender: TObject);
begin
  curKeyCode := $36 ; { Number 6 and carret ^ }   
  DispAssoc ;
end;

procedure Tkeymap.K7Click(Sender: TObject);
begin
  curKeyCode := $37 ; { Number 7 and ampersand & }    
  DispAssoc ;
end;

procedure Tkeymap.K8Click(Sender: TObject);
begin
  curKeyCode := $38 ; { Number 8 and star * } 
  DispAssoc ;
end;

procedure Tkeymap.K9Click(Sender: TObject);
begin
  curKeyCode := $39 ; { Number 9 and left parenthsis ( }   
  DispAssoc ;
end;

procedure Tkeymap.K0Click(Sender: TObject);
begin
  curKeyCode := $30 ; { Number 0 and right parenthesis ) } 
  DispAssoc ;
end;

procedure Tkeymap.KMinus1Click(Sender: TObject);
begin
  curKeyCode := $BD ; { minus and under score }    
  DispAssoc ;
end;

procedure Tkeymap.KEqualClick(Sender: TObject);
begin
  curKeyCode := $BB ; { equals and plus }    
  DispAssoc ;
end;

procedure Tkeymap.KBkSpcClick(Sender: TObject);
begin
  curKeyCode := $08 ; { back space }  
  DispAssoc ;
end;

procedure Tkeymap.KInsClick(Sender: TObject);
begin
  curKeyCode := $2D ; { insert }  
  DispAssoc ;
end;

procedure Tkeymap.KHomClick(Sender: TObject);
begin
  curKeyCode := $24 ; { home }      
  DispAssoc ;
end;

procedure Tkeymap.KPUpClick(Sender: TObject);
begin
  curKeyCode := $21 ; { page up }    
  DispAssoc ;
end;

procedure Tkeymap.KNumClick(Sender: TObject);
begin
  curKeyCode := $90 ; { Num lock }   
  DispAssoc ;
end;

procedure Tkeymap.KSlash2Click(Sender: TObject);
begin
  curKeyCode := $6F ; { slash }  
  DispAssoc ;
end;

procedure Tkeymap.KStarClick(Sender: TObject);
begin
  curKeyCode := $6A ; { star }   
  DispAssoc ;
end;

procedure Tkeymap.KMinus2Click(Sender: TObject);
begin
  curKeyCode := $6D ; { minus } 
  DispAssoc ;
end;

procedure Tkeymap.KQClick(Sender: TObject);
begin
  curKeyCode := $51 ; { Letter Q } 
  DispAssoc ;
end;

procedure Tkeymap.KWClick(Sender: TObject);
begin
  curKeyCode := $57 ; { Letter W }     
  DispAssoc ;
end;

procedure Tkeymap.KEClick(Sender: TObject);
begin
  curKeyCode := $45 ; { Letter E }    
  DispAssoc ;
end;

procedure Tkeymap.KRClick(Sender: TObject);
begin
  curKeyCode := $52 ; { Letter R }   
  DispAssoc ;
end;

procedure Tkeymap.KTClick(Sender: TObject);
begin
  curKeyCode := $54 ; { Letter T }  
  DispAssoc ;
end;

procedure Tkeymap.KYClick(Sender: TObject);
begin
  curKeyCode := $59 ; { Letter T }  
  DispAssoc ;
end;

procedure Tkeymap.KUClick(Sender: TObject);
begin
  curKeyCode := $55 ; { Letter U }  
  DispAssoc ;
end;

procedure Tkeymap.KIClick(Sender: TObject);
begin
  curKeyCode := $49 ; { Letter I }   
  DispAssoc ;
end;

procedure Tkeymap.KOClick(Sender: TObject);
begin
  curKeyCode := $4F ; { Letter O }  
  DispAssoc ;
end;

procedure Tkeymap.KPClick(Sender: TObject);
begin
  curKeyCode := $50 ; { Letter P }  
  DispAssoc ;
end;

procedure Tkeymap.KLSqClick(Sender: TObject);
begin
  curKeyCode := $DB ; { Left square brackets }  
  DispAssoc ;
end;

procedure Tkeymap.KRSqClick(Sender: TObject);
begin
  curKeyCode := $DD ; { Right square brackets }  
  DispAssoc ;
end;

procedure Tkeymap.KBkSlashClick(Sender: TObject);
begin
  curKeyCode := $DC ; { back slash \ and vertical bar | }  
  DispAssoc ;
end;

procedure Tkeymap.KDelClick(Sender: TObject);
begin
  curKeyCode := $2E ; { delete } 
  DispAssoc ;
end;

procedure Tkeymap.KEndClick(Sender: TObject);
begin
  curKeyCode := $23 ; { end }  
  DispAssoc ;
end;

procedure Tkeymap.KPDnClick(Sender: TObject);
begin
  curKeyCode := $22 ; { page down }   
  DispAssoc ;
end;

procedure Tkeymap.K7nClick(Sender: TObject);
begin
  curKeyCode := $24 ; { home and number 7 }  
  DispAssoc ;
end;

procedure Tkeymap.K8nClick(Sender: TObject);
begin
  curKeyCode := $26 ; { up arrow and number 8 } 
  DispAssoc ;
end;

procedure Tkeymap.K9nClick(Sender: TObject);
begin
  curKeyCode := $21 ; { page up and number 9 } 
  DispAssoc ;
end;

procedure Tkeymap.KPlusClick(Sender: TObject);
begin
  curKeyCode := $6b ; { plus }  
  DispAssoc ;
end;

procedure Tkeymap.KCapsClick(Sender: TObject);
begin
  curKeyCode := $14 ; { Caps Lock } 
  DispAssoc ;
end;

procedure Tkeymap.KAClick(Sender: TObject);
begin
  curKeyCode := $41 ; { Letter A }    
  DispAssoc ;
end;

procedure Tkeymap.KSClick(Sender: TObject);
begin
  curKeyCode := $53 ; { Letter S } 
  DispAssoc ;
end;

procedure Tkeymap.KDClick(Sender: TObject);
begin
  curKeyCode := $44 ; { Letter D }  
  DispAssoc ;
end;

procedure Tkeymap.KFClick(Sender: TObject);
begin
  curKeyCode := $46 ; { Letter F }   
  DispAssoc ;
end;

procedure Tkeymap.KGClick(Sender: TObject);
begin
  curKeyCode := $47 ; { Letter G }   
  DispAssoc ;
end;

procedure Tkeymap.KHClick(Sender: TObject);
begin
  curKeyCode := $48 ; { Letter H }   
  DispAssoc ;
end;

procedure Tkeymap.KJClick(Sender: TObject);
begin
  curKeyCode := $4A ; { Letter J }  
  DispAssoc ;
end;

procedure Tkeymap.KKClick(Sender: TObject);
begin
  curKeyCode := $4B ; { Letter K }  
  DispAssoc ;
end;

procedure Tkeymap.KLClick(Sender: TObject);
begin
  curKeyCode := $4C ; { Letter Q }   
  DispAssoc ;
end;

procedure Tkeymap.KSemiClick(Sender: TObject);
begin
  curKeyCode := $BA ; { semi colon and colon }  
  DispAssoc ;
end;

procedure Tkeymap.KQuoteClick(Sender: TObject);
begin
  curKeyCode := $DE ; { single and double quotes }  
  DispAssoc ;
end;

procedure Tkeymap.KEnter1Click(Sender: TObject);
begin
  curKeyCode := $0D ; { Enter }     
  DispAssoc ;
end;

procedure Tkeymap.K4nClick(Sender: TObject);
begin
  curKeyCode := $25 ; { left arrow and number 4 }   
  DispAssoc ;
end;

procedure Tkeymap.K5nClick(Sender: TObject);
begin
  curKeyCode := $0C ; { nothing and number 5 }  
  DispAssoc ;
end;

procedure Tkeymap.K6nClick(Sender: TObject);
begin
  curKeyCode := $27 ; { right arrow and number 6 }   
  DispAssoc ;
end;

procedure Tkeymap.KShift1Click(Sender: TObject);
begin
  curKeyCode := $10 ; { Shift }       
  DispAssoc ;
end;

procedure Tkeymap.KZClick(Sender: TObject);
begin
  curKeyCode := $5A ; { Letter Z }    
  DispAssoc ;
end;

procedure Tkeymap.KXClick(Sender: TObject);
begin
  curKeyCode := $58 ; { Letter X }     
  DispAssoc ;
end;

procedure Tkeymap.KCClick(Sender: TObject);
begin
  curKeyCode := $43 ; { Letter C }    
  DispAssoc ;
end;

procedure Tkeymap.KVClick(Sender: TObject);
begin
  curKeyCode := $56 ; { Letter V }  
  DispAssoc ;
end;

procedure Tkeymap.KBClick(Sender: TObject);
begin
  curKeyCode := $42 ; { Letter B }  
  DispAssoc ;
end;

procedure Tkeymap.KNClick(Sender: TObject);
begin
  curKeyCode := $4E ; { Letter N }   
  DispAssoc ;
end;

procedure Tkeymap.KMClick(Sender: TObject);
begin
  curKeyCode := $4D ; { Letter M } 
  DispAssoc ;
end;

procedure Tkeymap.KCommaClick(Sender: TObject);
begin
  curKeyCode := $BC ; { comma and less than < }   
  DispAssoc ;
end;

procedure Tkeymap.KDot1Click(Sender: TObject);
begin
  curKeyCode := $BE ; { dot and greater than > }  
  DispAssoc ;
end;

procedure Tkeymap.KSlash1Click(Sender: TObject);
begin
  curKeyCode := $BF ; { slash / and question mark ? }   
  DispAssoc ;
end;

procedure Tkeymap.KShift2Click(Sender: TObject);
begin
  curKeyCode := $10 ; { Shift }  
  DispAssoc ;
end;

procedure Tkeymap.kUpClick(Sender: TObject);
begin
  curKeyCode := $26 ; { Up arrow }   
  DispAssoc ;
end;

procedure Tkeymap.K1nClick(Sender: TObject);
begin
  curKeyCode := $23 ; { end and number 1 }   
  DispAssoc ;
end;

procedure Tkeymap.K2nClick(Sender: TObject);
begin
  curKeyCode := $28 ; { down arrow and number 2 }    
  DispAssoc ;
end;

procedure Tkeymap.K3nClick(Sender: TObject);
begin
  curKeyCode := $22 ; { page dowm and number 3 }    
  DispAssoc ;
end;

procedure Tkeymap.KEnter2Click(Sender: TObject);
begin
  curKeyCode := $0D ; { Enter } 
  DispAssoc ;
end;

procedure Tkeymap.KCtrl1Click(Sender: TObject);
begin
  curKeyCode := $11 ; { Ctrl } 
  DispAssoc ;
end;

procedure Tkeymap.KAlt1Click(Sender: TObject);
begin
  curKeyCode := $12 ; { Alt } 
  DispAssoc ;
end;

procedure Tkeymap.KSpaceClick(Sender: TObject);
begin
  curKeyCode := $20 ; { Space }  
  DispAssoc ;
end;

procedure Tkeymap.KAlt2Click(Sender: TObject);
begin
  curKeyCode := $12 ; { Alt }  
  DispAssoc ;
end;

procedure Tkeymap.KCtrl2Click(Sender: TObject);
begin
  curKeyCode := $11 ; { Ctrl }     
  DispAssoc ;
end;

procedure Tkeymap.KLeClick(Sender: TObject);
begin
  curKeyCode := $25 ; { Left arrow }   
  DispAssoc ;
end;

procedure Tkeymap.KDnClick(Sender: TObject);
begin
  curKeyCode := $28 ; { Down Arrow } 
  DispAssoc ;
end;

procedure Tkeymap.KRiClick(Sender: TObject);
begin
  curKeyCode := $27 ; { Right Arrow }  
  DispAssoc ;
end;

procedure Tkeymap.K0nClick(Sender: TObject);
begin
  curKeyCode := $2D ; { insert and number 0 }  
  DispAssoc ;
end;

procedure Tkeymap.KDot2Click(Sender: TObject);
begin
  curKeyCode := $2E ; { delete and dot }
  DispAssoc ;
end;

procedure Tkeymap.SetFnClick(Sender: TObject);
begin
  if TabControl1.TabIndex = 0 then  { standard }
    tempKeyTable[curKeyCode].StdCode := Listbox1.ItemIndex
  else if TabControl1.TabIndex = 1 then  { shift }
    tempKeyTable[curKeyCode].ShiftCode := Listbox1.ItemIndex 
  else if TabControl1.TabIndex = 2 then  { ctrl }
    tempKeyTable[curKeyCode].CtrlCode := Listbox1.ItemIndex
  else   { alt }
    tempKeyTable[curKeyCode].AltCode := Listbox1.ItemIndex ;
  DispAssoc ;
end;

procedure Tkeymap.OKClick(Sender: TObject);
var
  i: integer ;
begin   
  for i := 1 to KEYCODES do
    KeyTable[i] := tempKeyTable[i] ;
  keymap.Close() ;
end;

procedure Tkeymap.CancelClick(Sender: TObject);
begin
  keymap.Close() ;
end;

procedure Tkeymap.FormCreate(Sender: TObject);
var
  i: integer ;
begin
  curKeyCode := $1B ; { escape }

  for i := 1 to KEYCODES do
    tempKeyTable[i] := KeyTable[i] ;

  i := 0 ;
  while FuncNameTable[i] <> '' do
    begin
      Listbox1.Items.Add(FuncNameTable[i]) ;
      i := i + 1 ;
      if i > KEYFUNCS then
        break ;
    end ;
     
  DispAssoc ;
end;

procedure Tkeymap.DispAssoc ;
begin
  if TabControl1.TabIndex = 0 then   { Standard }
    begin
      KeyLabNew.Caption := 'Key named: '+KeyNameTable[curKeyCode]
        +Format('   (Keycode:%.2x)',[curKeyCode]) ;
      KeyLabOld.Caption := 'Key named: '+KeyNameTable[curKeyCode]
        +Format('   (Keycode:%.2x)',[curKeyCode]) ;
      FuncLabNew.Caption := 'Performs function: '
        +FuncNameTable[tempKeyTable[curKeyCode].StdCode] ;
      FuncLabOld.Caption := 'Performs function: '
        +FuncNameTable[KeyTable[curKeyCode].StdCode] ;
    end
  else if (curKeyCode <> $10) and (curKeyCode <> $11) and (curKeyCode <> $12) then
    begin
      if TabControl1.TabIndex = 1 then   { Shift }
        begin
          KeyLabNew.Caption := 'Key named: '+KeyNameTable[curKeyCode]
            +Format(' + Shift   (Keycode:%.2x)',[curKeyCode]) ;
          KeyLabOld.Caption := 'Key named: '+KeyNameTable[curKeyCode]
            +Format(' + Shift   (Keycode:%.2x)',[curKeyCode]) ;
          FuncLabNew.Caption := 'Performs function: '
            +FuncNameTable[tempKeyTable[curKeyCode].ShiftCode] ;
          FuncLabOld.Caption := 'Performs function: '
            +FuncNameTable[KeyTable[curKeyCode].ShiftCode] ;
        end
      else if TabControl1.TabIndex = 2 then   { Control }
        begin
          KeyLabNew.Caption := 'Key named: '+KeyNameTable[curKeyCode]
            +Format(' + Ctrl   (Keycode:%.2x)',[curKeyCode]) ;
          KeyLabOld.Caption := 'Key named: '+KeyNameTable[curKeyCode]
            +Format(' + Ctrl   (Keycode:%.2x)',[curKeyCode]) ;
          FuncLabNew.Caption := 'Performs function: '
            +FuncNameTable[tempKeyTable[curKeyCode].CtrlCode] ;
          FuncLabOld.Caption := 'Performs function: '
            +FuncNameTable[KeyTable[curKeyCode].CtrlCode] ;
        end
      else    { Alt }
        begin
          KeyLabNew.Caption := 'Key named: '+KeyNameTable[curKeyCode]
            +Format(' + Alt   (Keycode:%.2x)',[curKeyCode]) ;
          KeyLabOld.Caption := 'Key named: '+KeyNameTable[curKeyCode]
            +Format(' + Alt   (Keycode:%.2x)',[curKeyCode]) ;
          FuncLabNew.Caption := 'Performs function: '
            +FuncNameTable[tempKeyTable[curKeyCode].AltCode] ;
          FuncLabOld.Caption := 'Performs function: '
            +FuncNameTable[KeyTable[curKeyCode].AltCode] ;
        end ;
    end
  else
    begin
      ShowMessage('Accelerator not valid with this key.') ;
      TabControl1.TabIndex := 0 ;  { remove accelerator }
      DispAssoc ;  { reshow the key association }
    end ;
end ;

procedure Tkeymap.TabControl1Change(Sender: TObject);
begin
  DispAssoc ;
end;

end.
