///////////////////////////////////////////////////////////////////////////
// Project:   Emu3270
// Program:   screenu.pas
// Language:  Object Pascal - Delphi ver 2.0
// Support:   David Fahey
// Date:      05Mar97
// Purpose:   To emulate an IBM 3270 screen.
// History:   05Mar97  Initial coding                              DAF
// Notes:     This unit emulates the 3270 physical screen on the window.
//            It processes the keyboard input into the screen buffer, and it
//            processes the windows menu commands. It receives commands from
//            the 3270 data stream processing unit (ds3270), and will send
//            commands to ds3270 when action keys or enter keys are pressed.
//
// End.
///////////////////////////////////////////////////////////////////////////

unit screenu;

interface

uses
  Windows, Winsock, Messages, SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, Menus,
  AboutU, ConnectU, RecThrd ;

const
  MAX_PATH = 255 ;

  { screen size }
  SCRROWS = 32 ;
  SCRCOLS = 80 ;

  KEYCODES = 256 ;
  KEYFUNCS = 256 ;
  csrUnderLine = 0 ;
  csrEmptyBox = 1 ;

  { AID values }
  ckAidNone   = $60 ;
  ckAidStruct = $88 ;
  ckAidReadPt = $61 ;
  ckAidTrig   = $7F ;
  ckAidTest   = $F0 ;

  ckAidPF1    = $F1 ;
  ckAidPF2    = $F2 ;
  ckAidPF3    = $F3 ;
  ckAidPF4    = $F4 ;
  ckAidPF5    = $F5 ;
  ckAidPF6    = $F6 ;
  ckAidPF7    = $F7 ;
  ckAidPF8    = $F8 ;
  ckAidPF9    = $F9 ;
  ckAidPF10   = $FA ;
  ckAidPF11   = $FB ;
  ckAidPF12   = $FC ;

  ckAidPF13   = $C1 ;
  ckAidPF14   = $C2 ;
  ckAidPF15   = $C3 ;
  ckAidPF16   = $C4 ;
  ckAidPF17   = $C5 ;
  ckAidPF18   = $C6 ;
  ckAidPF19   = $C7 ;
  ckAidPF20   = $C8 ;
  ckAidPF21   = $C9 ;
  ckAidPF22   = $4A ;
  ckAidPF23   = $4B ;
  ckAidPF24   = $4C ;

  ckAidPA1    = $6C ;
  ckAidPA2    = $6E ;
  ckAidPA3    = $6B ;
  ckAidClear  = $6D ;
  ckAidClearP = $6A ;
  ckAidEnter  = $7D ;
  ckAidMagID  = $E6 ;
  ckAidMagNum = $E7 ;

  { 3270 special data values }
  cdDefault   = $00 ;
  cdFieldAttr = $01 ;

  { 3270 cell attribute mask }
  caDefault   = $00 ;
  caProtect   = $20 ;
  caNumeric   = $10 ;
  caSelPen    = $04 ;
  caIntens    = $08 ;
  caNonDisp   = $0C ;
  caMDT       = $01 ;

  { 3270 cell colors }
  ccDefault   = $00 ; { green }
  ccBlue      = $F1 ;
  ccRed       = $F2 ;
  ccPink      = $F3 ;
  ccGreen     = $F4 ;
  ccTurquoise = $F5 ;
  ccYellow    = $F6 ;
  ccWhite     = $F7 ;

  { 3270 cell hilites }
  chDefault   = $00 ;
  chBlink     = $F1 ;
  chReverse   = $F2 ;
  chUnderLine = $F4 ;

  { 3270 cell character set }
  csDefault   = $00 ;
  csAPL       = $F1 ;

  { key function indexes }
  kcNA = 0 ;
  kcBackTab = 1 ;
  kcEraseToEof = 2 ;
  kcNewLine = 3 ;
  kcForwardTab = 4 ;
  kcClearScreen = 5 ;
  kcAlterCursor = 6 ;
  kcCursorHome = 7 ;
  kcCursorLeft = 8 ;
  kcCursorRight = 9 ;
  kcCursorDown = 10 ;
  kcCursorUp = 11 ;
  kcInsertOn = 12 ;
  kcDeleteChar = 13 ;
  kcCapsOn = 14 ;
  kcReset = 15 ;
  kcCapsOff = 16 ;
  kcNumber1 = 17 ;
  kcNumber2 = 18 ;
  kcNumber3 = 19 ;
  kcNumber4 = 20 ;
  kcNumber5 = 21 ;
  kcNumber6 = 22 ;
  kcNumber7 = 23 ;
  kcNumber8 = 24 ;
  kcNumber9 = 25 ;
  kcNumber0 = 26 ;
  kcSymbolRightParen = 27 ;
  kcExclamationMark = 28 ;
  kcSymbolAt = 29 ;
  kcSymbolHash = 30 ;
  kcSymbolDollar = 31 ;
  kcSymbolPercent = 32 ;
  kcSymbolCarret = 33 ;
  kcSymbolAmpersand = 34 ;
  kcSymbolStar = 35 ;
  kcSymbolLeftParen = 36 ;
  kcSmallLetterA = 37 ;
  kcCapitalLetterA = 38 ;
  kcSmallLetterB = 39 ;
  kcCapitalLetterB = 40 ;
  kcSmallLetterC = 41 ;
  kcCapitalLetterC = 42 ;
  kcSmallLetterD = 43 ;
  kcCapitalLetterD = 44 ;
  kcSmallLetterE = 45 ;
  kcCapitalLetterE = 46 ;
  kcSmallLetterF = 47 ;
  kcCapitalLetterF = 48 ;
  kcSmallLetterG = 49 ;
  kcCapitalLetterG = 50 ;
  kcSmallLetterH = 51 ;
  kcCapitalLetterH = 52 ;
  kcSmallLetterI = 53 ;
  kcCapitalLetterI = 54 ;
  kcSmallLetterJ = 55 ;
  kcCapitalLetterJ = 56 ;
  kcSmallLetterK = 57 ;
  kcCapitalLetterK = 58 ;
  kcSmallLetterL = 59 ;
  kcCapitalLetterL = 60 ;
  kcSmallLetterM = 61 ;
  kcCapitalLetterM = 62 ;
  kcSmallLetterN = 63 ;
  kcCapitalLetterN = 64 ;
  kcSmallLetterO = 65 ;
  kcCapitalLetterO = 66 ;
  kcSmallLetterP = 67 ;
  kcCapitalLetterP = 68 ;
  kcSmallLetterQ = 69 ;
  kcCapitalLetterQ = 70 ;
  kcSmallLetterR = 71 ;
  kcCapitalLetterR = 72 ;
  kcSmallLetterS = 73 ;
  kcCapitalLetterS = 74 ;
  kcSmallLetterT = 75 ;
  kcCapitalLetterT = 76 ;
  kcSmallLetterU = 77 ;
  kcCapitalLetterU = 78 ;
  kcSmallLetterV = 79 ;
  kcCapitalLetterV = 80 ;
  kcSmallLetterW = 81 ;
  kcCapitalLetterW = 82 ;
  kcSmallLetterX = 83 ;
  kcCapitalLetterX = 84 ;
  kcSmallLetterY = 85 ;
  kcCapitalLetterY = 86 ;
  kcSmallLetterZ = 87 ;
  kcCapitalLetterZ = 88 ;
  kcSymbolTick = 89 ;
  kcSymbolTilde = 90 ;
  kcSymbolMinus = 91 ;
  kcSymbolUnderScore = 92 ;
  kcSymbolEqual = 93 ;
  kcSymbolPlus = 94 ;
  kcSymbolBackSlash = 95 ;
  kcSymbolBar = 96 ;
  kcSymbolSlash = 97 ;
  kcSymbolLeftSquareBrace = 98 ;
  kcSymbolLeftCurlyBrace = 99 ;
  kcSymbolRightSquareBrace = 100 ;
  kcSymbolRightCurlyBrace = 101 ;
  kcSymbolSemiColon = 102 ;
  kcSymbolColon = 103 ;
  kcSymbolSingleQuote = 104 ;
  kcSymbolDoubleQuote = 105 ;
  kcSymbolComma = 106 ;
  kcSymbolLessThan = 107 ;
  kcSymbolDot = 108 ;
  kcSymbolGreaterThan = 109 ;
  kcSymbolQuestionMark = 110 ;
  kcSymbolSpace = 111 ;

  kcPF1 = 112 ;    
  kcPF2 = 113 ;
  kcPF3 = 114 ;
  kcPF4 = 115 ;
  kcPF5 = 116 ;
  kcPF6 = 117 ;
  kcPF7 = 118 ;
  kcPF8 = 119 ;
  kcPF9 = 120 ;
  kcPF10 = 121 ;
  kcPF11 = 122 ;
  kcPF12 = 123 ;
  kcPF13 = 124 ;
  kcPF14 = 125 ;
  kcPF15 = 126 ;
  kcPF16 = 127 ;
  kcPF17 = 128 ;
  kcPF18 = 129 ;
  kcPF19 = 130 ;
  kcPF20 = 131 ;
  kcPF21 = 132 ;
  kcPF22 = 133 ;
  kcPF23 = 134 ;
  kcPF24 = 135 ;

  kcColorRed = 136 ;
  kcExtStatus = 137 ;
  kcColorPink = 138 ;
  kcColorGreen = 139 ;
  kcColorYellow = 140 ;
  kcColorBlue = 141 ;
  kcColorTurquoise = 142 ;
  kcColorWhite = 143 ;
  kcColorDefault = 144 ;
  kcHiliteReverse = 145 ;
  kcHiliteBlink = 146 ;
  kcHiliteUnderLine = 147 ;
  kcHiliteDefault = 148 ;

  kcEnter = 149 ;   
  kcAttn = 150 ;
  kcSysreq = 151 ;
  kcSelectPSA = 152 ;
  kcSelectPSB = 153 ;
  kcSelectPSDefault = 154 ;
  kcPA1 = 155 ;
  kcPA2 = 156 ;
  kcPA3 = 157 ;
  kcRule = 158 ;
  kcAlt = 159 ;
  kcCursorLeftFast = 160 ;
  kcCursorRightFast = 161 ;
  kcCursorDownFast = 162 ;
  kcCursorUpFast = 163 ;

type
  TPath = array [0..MAX_PATH] of char ;

  TFuncNameTable = array [0..KEYFUNCS] of string[15] ;
  TKeyNameTable = array [1..KEYCODES] of string[15] ;

  TKeyFunc = record
    StdCode: byte ;   { function code applied for key press }
    AltCode: byte ;   { function code applied for Alt key press }
    CtrlCode: byte ;  { function code applied for Ctrl key press }
    ShiftCode: byte ; { function code applied for Shift key press }
  end ;

  TKeyTable = array [1..KEYCODES] of TKeyFunc ;

  TScrCell = record
    Data:    char ;   { presentation character (a,b,c,d,..) }
    Attrib:  char ;   { extended character attribute (Input,Prot,..) }
    Hilite:  char ;   { extended character hilight (Blink,Reverse,..) }
    CharSet: char ;   { character set to use (Default,APL,..) }
    Color:   char ;   { character color (Red,Pink,..) }
  end ;

  TScrBuf = array [1..SCRROWS,1..SCRCOLS] of TScrCell ;
  PScrBuf = ^TScrBuf ;

  Tscreenf = class(TForm)
    MainMenu1: TMainMenu;
    Connect: TMenuItem;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    Clear1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    TestOn: TMenuItem;
    TestOff: TMenuItem;
    FontDialog1: TFontDialog;
    ChangeFont1: TMenuItem;
    TestFieldsOn1: TMenuItem;
    TestFieldsOff1: TMenuItem;
    KeyMap1: TMenuItem;
    RemoteSystem: TMenuItem;
    Disconnect1: TMenuItem;
    TestMenu: TMenuItem;
    N1: TMenuItem;
    Debug1: TMenuItem;
    procedure Exit1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure TestOnClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TestOffClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ChangeFont1Click(Sender: TObject);
    procedure TestFieldsOn1Click(Sender: TObject);
    procedure TestFieldsOff1Click(Sender: TObject);
    procedure KeyMap1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure RemoteSystemClick(Sender: TObject);
    procedure Debug1Click(Sender: TObject);
    procedure Disconnect1Click(Sender: TObject);
  private
    { Private declarations }
  public     
    { Public declarations }
    function ColorMapW2I(ic: TColor): char ;
    function ColorMapI2W(ic: char): TColor ; 
    function ShiftRightData(col,row: integer; var ecol,erow: integer):boolean ;
    function EmptyCell: TScrCell ;
    function DeleteChar(col: integer; row: integer):boolean ;  
    function EraseToEof(sCol,sRow: integer; var eCol,eRow: integer):boolean ;
    procedure UnLockKeyBoard ;
    procedure LockKeyBoard(reason: string) ;
    procedure GetNextCell(var c,r: integer) ;
    procedure GetPrevCell(var c,r: integer) ;
    procedure SetPrevFieldAttr(col,row: integer; attr: byte) ;  
    procedure GetPrevFieldAttrs(col,row: integer;
      var attr,color,hilite,cset: byte) ;
    procedure DispCell(x: integer; y: integer; PaintBlanks: boolean) ;
    procedure DispCells(scol, srow, ecol, erow: integer; PaintBlanks: boolean) ;
    procedure DispLine(row: integer) ;
    procedure ReadBuffer(var os: string) ;
    procedure ReadModified(var os: string) ;
    procedure Field(row,col:integer; attr,color,hilite,cset:byte; data:string) ;
    procedure StartFieldExtended(row,col:integer; attr,color,hilite,cset:byte) ; 
    procedure StartField(row,col:integer; attr:byte) ;  
    procedure ResetDefaults ;
    procedure ResetMDT ;
    procedure EraseUnprotectedToAddress(var prow,pcol: integer;
      erow,ecol: integer) ;
    procedure EraseUnprotected ;
    procedure InsertCursor(row,col: integer) ;
    procedure ProgramTab(var row,col: integer; erase: boolean) ;
    procedure RepeatToAddress(var prow,pcol: integer; erow,ecol: integer;
      ch: byte; attr,color,hilite,cset: byte) ;
    procedure ModifyField(var row,col: integer; attr,color,hilite,cset: byte) ;
    procedure DisplayChar(row,col: integer; ch: byte;
      attr,color,hilite,cset: byte) ;
    procedure ClearCanvas ;
    procedure ClearScr ;
    procedure ClearBuf ;
    procedure FillBuf ;    
    procedure MakeFields ;  
    procedure ShowStatus ;
    procedure ShowBuf ;
    procedure SaveBuf ;
    procedure RestoreBuf ;
    procedure DrawCursor(x: integer; y: integer) ;
    procedure InitKeyTab ;
    procedure BackTab ;
    procedure EraseEof ;
    procedure NewLine ;
    procedure ForwardTab ;    
    procedure ClearScreen ;
    procedure AlterCursor ;
    procedure CursorHome ;
    procedure CursorLeft(speed: integer) ;
    procedure CursorUp(speed: integer) ;
    procedure CursorRight(speed: integer) ;
    procedure CursorDown(speed: integer) ;
    procedure DeleteCh ;
    procedure InsertOn ;
    procedure CapsOn ;
    procedure Reset ;
    procedure CapsOff ;  
    procedure Nothing ;
    procedure AddChar(ch: char; numeric: boolean ) ;
    procedure FunctionKey(keyno: integer) ;
    procedure ActionKey(keyno: integer) ;
    procedure SelectPS(SymbolSet: integer) ;
    procedure Attention ;
    procedure Sysreq ;
  end;

var
  screenf: Tscreenf ;
  CurCellColor: char ;  
  CurCellHilite: char ;
  ScrBuf: TScrBuf ;
  HoldBuf: TScrBuf ;
  Test: boolean ;
  TestFields: boolean ;
  Insert: boolean ;   
  Caps: boolean ;
  ExtStatus: boolean ; 
  Rule: boolean ;
  FontWidthPix: integer ;
  FontHeightPix: integer ;
  CsrCol, CsrRow: integer ;
  CsrShape: integer ;
  LastKey: word ;
  LastAlt: char ;
  KbdLocked: boolean ;
  LockReason: string[3] ;
  KeyTable: TKeyTable ;   
  KeyNameTable: TKeyNameTable ;
  FuncNameTable: TFuncNameTable ;

  ConnectHostName: string ;
  soc: TSocket ;
  RecThreadRunning: boolean ;
  socOpen: boolean ;
  Deb: boolean ;
  EorFlag: boolean ;
  RecThread: RecvThrd ;
  OutChar: byte ;
  OutLine: string ;
  LogLine: string ;
  DumpStr: string[16] ;
  DumpNum: integer ;
  DumpBytes: integer ;

implementation

uses
  Keymapu, Logu, Telnetu, ds3270u, utilu ;

{$R *.DFM}

//////////////////////////////////////////////////////////////////
// Service Routines
//////////////////////////////////////////////////////////////////

function Tscreenf.EmptyCell: TScrCell ;
{
  Returns an empty cell.
}
begin
  Result.Data := Char(cdDefault) ;
  Result.Attrib := Char(caDefault) ;
  Result.Hilite := Char(chDefault) ;
  Result.CharSet := Char(csDefault) ;
  Result.Color := Char(ccDefault) ;
end ;

function Tscreenf.ColorMapI2W(ic: char): TColor ;
{
  Maps an IBM 3270 color specification into a Windows Delphi color
  specification.
}
begin
  if Byte(ic) = ccDefault then Result := clLime
  else if Byte(ic) =  ccBlue then Result := clBlue
  else if Byte(ic) =  ccRed then Result := clRed
  else if Byte(ic) =  ccPink then Result := clPurple
  else if Byte(ic) =  ccGreen then Result := clLime
  else if Byte(ic) =  ccYellow then Result := clYellow
  else if Byte(ic) =  ccTurquoise then Result := clTeal
  else if Byte(ic) =  ccWhite then Result := clWhite
  else Result := clLime ;
end ;

function Tscreenf.ColorMapW2I(ic: TColor): char ;  
{
  Maps a Windows Delphi color specification into an IBM 3270 color
  specification.
}
begin
  if ic = clLime then Result := Char(ccGreen)
  else if ic = clBlue then Result := Char(ccBlue)
  else if ic = clRed then Result := Char(ccRed)
  else if ic = clPurple then Result := Char(ccPink)
  else if ic = clYellow then Result := Char(ccYellow)
  else if ic = clTeal then Result := Char(ccTurquoise)
  else if ic = clWhite then Result := Char(ccWhite)
  else Result := Char(ccGreen) ;
end ;

procedure Tscreenf.LockKeyBoard(reason: string) ;
{
  Locks the keyboard, so that no keys are useable except the reset
  key.
}
begin
  KbdLocked := true ;
  LockReason := reason ;
  Beep ;
end ;

procedure Tscreenf.UnLockKeyBoard ;    
{
  Unlocks the keyboard.
}
begin
  KbdLocked := False ;
  Insert := False ;
  LockReason := '' ;
end ;

procedure Tscreenf.SaveBuf ;
{
  Makes a copy of the current screen buffer.
}
var
  i, j: integer ;
begin
  for i := 1 to SCRROWS do
    for j := 1 to SCRCOLS do
      HoldBuf[i,j] := ScrBuf[i,j] ;
end ;

procedure Tscreenf.RestoreBuf ;   
{
  Restores the previously saved copy of the screen buffer.
}
var
  i, j: integer ;
begin
  for i := 1 to SCRROWS do
    for j := 1 to SCRCOLS do
      ScrBuf[i,j] := HoldBuf[i,j] ;
end ;

procedure Tscreenf.DispCell(x: integer; y: integer; PaintBlanks: boolean) ;
{
  Given a buffer cell location this routine displays the buffer contents
  for that cell on the screen window using that cells attributes.
}
var
  xpos, ypos: integer ;
begin
  xpos := (x * FontWidthPix)-FontWidthPix ;
  ypos := (y * FontHeightPix)-FontHeightPix ;
  with canvas do
    begin
      Brush.Style := bsSolid ;
      Brush.Color := clBlack ;

      { if null or attribute then paint as blank }
      if (ScrBuf[y,x].data = Char(cdDefault)) or
         (ScrBuf[y,x].data = Char(cdFieldAttr)) then
        begin
          if PaintBlanks then
            begin
              Font.Style := [] ;
              TextOut(xpos,ypos,' ') ;
            end ;
        end
      else   { paint presentation characters }
        begin
          if (Byte(ScrBuf[y,x].attrib) and caNonDisp) <> caNonDisp then
            begin
              Pen.Mode := pmCopy ;
              Font.Color := ColorMapI2W(ScrBuf[y,x].color) ;
              if ScrBuf[y,x].hilite = Char(chDefault) then
                Font.Style := []
              else if ScrBuf[y,x].hilite = Char(chReverse) then
                begin
                  Font.Style := [] ;
                  Pen.Mode := pmXor ;
                  Brush.Color := ColorMapI2W(ScrBuf[y,x].color) ;
                  Font.Color := clBlack ;
                end
              else if ScrBuf[y,x].hilite = Char(chUnderLine) then
                Font.Style := [fsUnderline]
              else if ScrBuf[y,x].hilite = Char(chBlink) then
                Font.Style := [fsStrikeout]
              else
                Font.Style := [] ;

              if (Byte(ScrBuf[y,x].attrib) and caIntens) = caIntens then
                Font.Style := Font.Style + [fsBold] ;

              TextOut(xpos,ypos,ScrBuf[y,x].data) ;
            end
          else
            TextOut(xpos,ypos,' ') ;
        end ;
    end ;
end ;

procedure Tscreenf.DispCells(scol, srow,              { start col/row }
                             ecol, erow: integer;     { end col/row }
                             PaintBlanks: boolean) ;  { paint blanks ? }
{
  Given two buffer cell locations this routine displays the buffer contents
  for those cells and all cells between them on the screen window using
  their cell attributes.
}
var
  r,c: integer ;
begin
  r := srow ;
  c := scol ;
  while not( (r = erow) and (c = ecol)) do
    begin
      DispCell(c,r,PaintBlanks) ;
      GetNextCell(c,r) ;
    end ;
  DispCell(c,r,PaintBlanks) ;
end ;

procedure Tscreenf.DrawCursor(x: integer; y: integer) ;
{
  Draws the cursor on the emulator screen window at the cell location
  specified, using the current cursor shape.
}
var
  xpos, ypos: integer ;
begin
  xpos := (x * FontWidthPix)-FontWidthPix ;
  ypos := (y * FontHeightPix)-1 ;
  with canvas do
    begin
      if csrShape = csrUnderLine then
        begin
          Pen.Mode := pmWhite ;
          Pen.Color := clWhite ;
          Brush.Style := bsSolid ;
          Brush.Color := clWhite ;
          MoveTo(xpos,ypos) ;
          LineTo(xpos+FontWidthPix,ypos) ;
        end
      else
        begin
          Pen.Mode := pmXor ;
          Pen.Color := ColorMapI2W(ScrBuf[y,x].color) ;
          Brush.Style := bsSolid ;
          Brush.Color := ColorMapI2W(ScrBuf[y,x].color) ;
          Rectangle(xpos,ypos-FontHeightPix+1,xpos+FontWidthPix,ypos) ;
        end ;
    end ;
end ;

procedure Tscreenf.GetNextCell(var c,r: integer) ;
{
  Given a buffer cell location this routine returns the location of the
  next cell in the buffer, as organized in row major order.
}
begin
  c := c+1 ;
  if c > SCRCOLS then
    begin
      c := 1 ;
      r := r+1 ;
      if r > SCRROWS then
        r := 1 ;
    end ;
end ;

procedure Tscreenf.GetPrevCell(var c,r: integer) ;
{
  Given a buffer cell location this routine returns the location of the
  previous cell in the buffer, as organized in row major order.
}
begin
  c := c-1 ;
  if c = 0 then
    begin
      c := SCRCOLS ;
      r := r-1 ;
      if r = 0 then
        r := SCRROWS ;
   end ;
end ;

procedure Tscreenf.SetPrevFieldAttr(col,row: integer; attr: byte) ;
{
  Given a buffer cell location this routine finds the location of the
  previous field attribute cell in the buffer and sets the supplied
  attributes.
}
var
  j: integer ;
begin
  j := 1 ;
  while not(ScrBuf[row,col].data = Char(cdFieldAttr) ) do
    begin
      GetPrevCell(col,row) ;
      j := j + 1 ;
      if j > (SCRCOLS * SCRROWS) then
        break ;
    end ;
  { if found the previous field then set the supplied attributes }
  if ScrBuf[row,col].data = Char(cdFieldAttr) then
    ScrBuf[row,col].attrib := Char(Byte(ScrBuf[row,col].attrib) or attr) ;
end ;

procedure Tscreenf.GetPrevFieldAttrs(col,row: integer;
                                     var attr,color,hilite,cset: byte) ;
{
  Given a buffer cell location this routine finds the location of the
  previous field attribute cell in the buffer and returns all the fields
  attributes.
}
var
  j: integer ;
begin
  j := 1 ;
  while not(ScrBuf[row,col].data = Char(cdFieldAttr) ) do
    begin
      GetPrevCell(col,row) ;
      j := j + 1 ;
      if j > (SCRCOLS * SCRROWS) then
        break ;
    end ;
  { if found the previous field then get the field attributes }
  if ScrBuf[row,col].data = Char(cdFieldAttr) then
    begin
      attr := Byte(ScrBuf[row,col].Attrib) ;
      hilite := Byte(ScrBuf[row,col].Hilite) ;
      cset := Byte(ScrBuf[row,col].CharSet) ;
      color := Byte(ScrBuf[row,col].Color) ;
    end
  else
    begin  
      attr := caDefault ;
      hilite := chDefault ;
      cset := csDefault ;
      color := ccDefault ;
    end ;
end ;

function Tscreenf.DeleteChar(col: integer; row: integer):boolean ;
{
  This routine deletes a character from the buffer, shifting characters to
  the left that follow the deleted character, up until the first attribute
  character or the end of a display line.
}
var
  i: integer ;
begin
  if (Byte(ScrBuf[row,col].attrib) and caProtect) <> caProtect then
    begin  { field not protected }
      for i := col to SCRCOLS do  { cols to first field attr }
        begin
          if ScrBuf[row,i+1].data <> Char(cdFieldAttr) then
            begin
              if i < SCRCOLS then
                ScrBuf[row,i] := ScrBuf[row,i+1]
              else    { at last col, replace last char with null }
                begin
                  ScrBuf[row,i] := ScrBuf[row,i-1] ;
                  ScrBuf[row,i].Data := Char(cdDefault) ;
                end ;
            end
          else   { field attr byte reached }
            begin
              ScrBuf[row,i] := ScrBuf[row,i-1] ;
              ScrBuf[row,i].Data := Char(cdDefault) ;
              break ;
            end ;
        end ;  { of cols to first field attr }
      result := true ;
    end   { of field not protected }
  else
    result := false ;
end ;

function Tscreenf.EraseToEof(sCol,sRow: integer;    { start col and row }
                             var eCol,eRow:integer  { returned end col/row }
                            ):boolean ;             { return code }
{
  This routine erases all characters in an unprotected field unitl the first
  attribute byte. Erasure can span lines, and wrap from the last buffer location to the
  first buffer location.
}
var
  j,r,c: integer ;
begin
  if (Byte(ScrBuf[sRow,sCol].attrib) and caProtect) <> caProtect then
    begin  { field not protected }
      r := sRow ;
      c := sCol ;
      j := 1 ;  { over run counter }
      while not(ScrBuf[r,c].data = Char(cdFieldAttr) ) do
        begin
          ScrBuf[r,c].data := Char(cdDefault) ;
          eCol := c ;
          eRow := r ;
          GetNextCell(c,r) ;
          j := j + 1 ;
          if j > (SCRCOLS * SCRROWS) then
            break ;
        end ;           
      SetPrevFieldAttr(sCol,sRow,caMDT) ;
      result := true ;
    end   { of field not protected }
  else
    result := false ;
end ;

function Tscreenf.ShiftRightData(col,row: integer;       { start col and row }
                                 var ecol, erow: integer { returned end col/row}
                                ):boolean ;              { return code }
{
  This routine performs insertion of one character into the buffer, shifting
  all characters to its right to the right. Characters are only shifted right
  if a null character exists to their right, before the next field attribute.
  Insertion can span lines, and wrap from the last buffer location to the
  first buffer location. If no null characters exist insertion fails.
}
var
  j,rr,cc,r,c: integer ;
begin
  r := row ;
  c := col ;
  j := 1 ;  { over run counter }
  while not( (ScrBuf[r,c].data = Char(cdDefault)) or
    (ScrBuf[r,c].data = Char(cdFieldAttr)) ) do
    begin
      GetNextCell(c,r) ;
      j := j + 1 ;
      if j > (SCRCOLS * SCRROWS) then
        break ;
    end ;
  if ScrBuf[r,c].data = Char(cdDefault) then
    begin
      ecol := c ;  { save returned end row and col }
      erow := r ;
      rr := r ;
      cc := c ;
      GetPrevCell(cc,rr) ;
      while not( (r = row) and (c = col)) do
        begin
          ScrBuf[r,c] := ScrBuf[rr,cc] ;
          GetPrevCell(c,r) ;
          GetPrevCell(cc,rr) ;
        end ;            
      SetPrevFieldAttr(col,row,caMDT) ;
      result := true ;
    end
  else
    begin
      { field attr found before null - no shift done }
      result := false ;
      ecol := 0 ;  { returned end row and col not valid }
      erow := 0 ;
    end ;
end ;

procedure Tscreenf.ClearBuf ;
{
  This routine erases the entire buffer, removing all fields, and setting
  all attributes to their defaults.
}
var
  i, j: integer ;
begin
  for i := 1 to SCRROWS do
    for j := 1 to SCRCOLS do
      begin
        ScrBuf[i,j].data := Char(cdDefault) ;
        ScrBuf[i,j].Attrib := Char(caDefault) ;
        ScrBuf[i,j].Hilite := Char(chDefault) ;
        ScrBuf[i,j].CharSet := Char(csDefault) ;
        ScrBuf[i,j].Color := Char(ccDefault) ;
      end ;
end ;

procedure Tscreenf.ReadBuffer(var os: string) ;
{
  This routine reads the entire buffer, and builds a data stream containing
  all data on the screen. Field attributes are represemnted by embeded
  SF orders. Nulls are not inserted into the generated data stream.

  ** This is the field version only
}
var
  i, j: integer ;
begin
  for i := 1 to SCRROWS do
    for j := 1 to SCRCOLS do
      begin
        if ScrBuf[i,j].data = Char(cdFieldAttr) then
          os := os + Char(IO_SF) + ScrBuf[i,j].Attrib
        else
          os := os + Char(as2eb(Byte(ScrBuf[i,j].data))) ;
      end ;
end ;

procedure Tscreenf.ReadModified(var os: string) ;
{
  This routine reads the modified fields from the buffer, and builds a data
  stream containing all data on the screen. Field attributes are represemnted
  by embeded SF orders. Nulls are not inserted into the generated data stream.

  ** This is the field version only
}
var
  i, j: integer ;
  SendField: boolean ;
  ba1, ba2: byte ;
  row, col: integer ;
begin
  for i := 1 to SCRROWS do
    for j := 1 to SCRCOLS do
      begin
        if ScrBuf[i,j].data <> Char(cdDefault) then  { not a null }
          begin
            if ScrBuf[i,j].data = Char(cdFieldAttr) then  { a field attr }
              begin
                SendField := False ;
                if ((Byte(ScrBuf[i,j].attrib) and caMDT) = caMDT) then
                  begin                               { field is modified }
                    { turn off MDT - modified data tag }
                    ScrBuf[i,j].attrib := Char(Byte(ScrBuf[i,j].attrib)
                      xor caMDT) ;
                    SendField := True ;
                    row := i ;
                    col := j ;
                    GetNextCell(col,row) ;
                    Ds3270.rc2sba(row,col,ba1,ba2) ;
                    os := os + Char(IO_SBA) + Char(ba1) + Char(ba2) ;
                  end ;
              end 
            else
              begin
                if SendField then
                  os := os + Char(as2eb(Byte(ScrBuf[i,j].data))) ;
              end ;
          end ;
      end ;
end ;

procedure  Tscreenf.Field(row,col: integer;
                 attr,color,hilite,cset: byte;
                 data: string) ;    
{
  This routine builds an extended field and inserts data into the field. The
  routine is used by the test field generator.
}
var
  c,j,r: integer ;
begin
  ScrBuf[row,col].data := Char(cdFieldAttr) ;
  ScrBuf[row,col].Attrib := Char(attr) ;
  ScrBuf[row,col].Hilite := Char(hilite) ;
  ScrBuf[row,col].CharSet := Char(cset) ;
  ScrBuf[row,col].Color := Char(color) ;

  r := row ;
  c := col+1 ;
  j := 1 ;
  if c > SCRCOLS then
    begin
      c := 1 ;
      r := r + 1 ;
      if r > SCRROWS then
        r := 1 ;
    end ;

  while ScrBuf[r,c].data <> Char(cdFieldAttr) do
    begin
      ScrBuf[r,c] := ScrBuf[row,col] ;
      if j <= length(data) then
        begin
          ScrBuf[r,c].data := data[j] ;
          j := j + 1 ;
        end
      else
        ScrBuf[r,c].data := Char(cdDefault) ;
      c := c + 1 ;
      if c > SCRCOLS then
        begin
          c := 1 ;
          r := r + 1 ;
          if r > SCRROWS then
            r := 1 ;
        end ;
    end ;
end ;

procedure  Tscreenf.StartFieldExtended(row,col: integer;
                      attr,color,hilite,cset: byte) ;
{
  This routine emulates the Start Field Extended (SFE) 3270 data stream order.
  The SFE order indicates the start of an extended field. The
  display then stores the extended field attributes at the current buffer
  address and increments the buffer address by one.
}
begin
  ScrBuf[row,col].data := Char(cdFieldAttr) ;
  ScrBuf[row,col].Attrib := Char(attr) ;
  ScrBuf[row,col].Hilite := Char(hilite) ;
  ScrBuf[row,col].CharSet := Char(cset) ;
  ScrBuf[row,col].Color := Char(color) ;
end ;

procedure  Tscreenf.StartField(row,col: integer; attr: byte) ;
{                    
  This routine emulates the Start Field (SF) 3270 data stream order.
  The SF order indicates the start of a field. In the write data stream
  the SF order identifies that the next byte is a field attribute. The
  display then stores the field attribute at the current buffer address
  and increments the buffer address by one.
  The associated extended field attributes are set to their default value.
}
begin
  ScrBuf[row,col].data := Char(cdFieldAttr) ;
  ScrBuf[row,col].Attrib := Char(attr) ;
  ScrBuf[row,col].Hilite := Char(chDefault) ;
  ScrBuf[row,col].CharSet := Char(csDefault) ;
  ScrBuf[row,col].Color := Char(ccDefault) ;
end ;

procedure Tscreenf.ResetMDT ;
{
  All MDT bits in the devices existing character buffer are reset before
  any data is written or orders are performed.
}
var
  r, c: integer ;
begin
  { turn off MDT on all cells }
  for r := 1 to SCRROWS do
    for c := 1 to SCRCOLS do
      if ((Byte(ScrBuf[r,c].attrib) and caMDT) = caMDT) then
        ScrBuf[r,c].Attrib := Char(Byte(ScrBuf[r,c].Attrib) xor caMDT) ;
end ;

procedure Tscreenf.EraseUnprotected ;
var
  r, c: integer ;
begin
  for r := 1 to SCRROWS do
    for c := 1 to SCRCOLS do
      begin
        if (ScrBuf[r,c].data <> Char(cdFieldAttr)) then
          begin
            if ((Byte(ScrBuf[r,c].attrib) and caProtect) <> caProtect) then
              begin
                ScrBuf[r,c].data := Char(cdDefault) ;
                if ((Byte(ScrBuf[r,c].attrib) and caMDT) = caMDT) then
                  ScrBuf[r,c].Attrib := Char(Byte(ScrBuf[r,c].Attrib) xor caMDT) ;
              end ;
          end
        else { turn off MDT on all field attrs }
          begin
            if ((Byte(ScrBuf[r,c].attrib) and caMDT) = caMDT) then
              ScrBuf[r,c].Attrib := Char(Byte(ScrBuf[r,c].Attrib) xor caMDT) ;
          end ;
      end ;
end ;

procedure Tscreenf.EraseUnprotectedToAddress(var prow,pcol: integer;
                                               erow,ecol: integer) ;
{   
  This routine emulates the Erase Unprotected to Address (EUA) 3270 data
  stream order.
  The EUA order stores nulls in all unprotected character locations
  starting at the current buffer address and ending at, but not including
  the specified stop address.
  The buffer address is relative to the origin of the buffer of the
  partition to which the orders and data are directed, and only the
  character buffer locations of that partition are filled with nulls.
  When the stop address is lower than the current buffer address, EUA
  wraps from the last buffer location to the first. When the stop address
  equals the current buffer address, all unprotected character locations
  in the buffer are erased. The current buffer address after successfull
  execution of EUA is the stop address.
  Field attributes and extended field attributes are not affected by EUA.
  Character attributes for every character changed are reset to their
  defaults.
}
var
  j,r,c: integer ;
begin
  r := prow ;
  c := pcol ;
  j := 1 ;  { over run counter }
  while (r <> erow) and (c <> ecol) do
    begin
      if (ScrBuf[r,c].data <> Char(cdFieldAttr)) then
        begin
          if ((Byte(ScrBuf[r,c].attrib) and caProtect) <> caProtect) then
            begin
              ScrBuf[r,c].data := Char(cdDefault) ;
              if ((Byte(ScrBuf[r,c].attrib) and caMDT) = caMDT) then
                ScrBuf[r,c].Attrib := Char(Byte(ScrBuf[r,c].Attrib) xor caMDT) ;
            end ;
        end
      else { turn off MDT on all field attrs }
        begin
          if ((Byte(ScrBuf[r,c].attrib) and caMDT) = caMDT) then
            ScrBuf[r,c].Attrib := Char(Byte(ScrBuf[r,c].Attrib) xor caMDT) ;
        end ;
      GetNextCell(c,r) ;
      j := j + 1 ;
      if j > (SCRCOLS * SCRROWS) then
        break ;
    end ;
  prow := erow ;
  pcol := ecol ;
end ;

procedure Tscreenf.InsertCursor(row,col: integer) ;
{
  This routine emulates the Insert Cursor (IC) 3270 data stream order.
  The IC order repositions the cursor to the location specified by the
  current buffer address. Execution of this order does not change the
  current buffer address.
}
begin
  { redraw cell that cursor inhabited }
  DispCell(CsrCol,CsrRow,true) ;
  { advance the cursor up }
  CsrRow := row ;
  CsrCol := col ;
  DrawCursor(CsrCol,CsrRow) ;
end ;

procedure Tscreenf.ProgramTab(var row,col: integer; erase: boolean) ;
{             
  This routine emulates the Program Tab (PT) 3270 data stream order.
  The PT order advances the current buffer address to the address of the
  first character position of the next unprotected field. If PT is issued
  when the curent buffer address is the location of a field attribute
  of an unprotected field, the buffer advances to the next location of
  that field (one location). In addition, if PT does not immediately
  follow a command, order or order sequence (such as after the WCC, IC,
  or RA respectively), nulls are inserted in the buffer from the current
  buffer address to the end of the field, regardless of the value of
  bit 2 (protected/unprotected) of the field attribute for the field.
  When PT immediately follows a command, order or order sequence, the
  buffer is not modified.
}
var
  r,c: integer ;
begin
  r := row ;
  c := col ;
  if (ScrBuf[r,c].data = Char(cdFieldAttr)) and
    ((Byte(ScrBuf[r,c].attrib) and caProtect) <> caProtect) then
    { on unprotected field attr byte - juat advance 1 }
    GetNextCell(c,r)
  else
    begin
      while (r <= SCRROWS) and (c <= SCRCOLS) do
        begin    
          if (ScrBuf[r,c].data = Char(cdFieldAttr)) and
            ((Byte(ScrBuf[r,c].attrib) and caProtect) <> caProtect) then
            { unprotected field attr byte - end of search }
            begin
              GetNextCell(c,r) ;
              break ;
            end ;
          if erase and (ScrBuf[r,c].data <> Char(cdFieldAttr)) then
            begin
              ScrBuf[r,c].data := Char(cdDefault) ;
              { ** should reset char attr to field attr here }
              if ((Byte(ScrBuf[r,c].attrib) and caMDT) = caMDT) then
                ScrBuf[r,c].Attrib := Char(Byte(ScrBuf[r,c].Attrib) xor caMDT) ;
            end ;       
          GetNextCell(c,r) ;
        end ;
    end ;
  row := r ;
  col := c ;
end ;
      
procedure Tscreenf.RepeatToAddress(var prow,pcol: integer;
                                    erow,ecol: integer;
                                    ch: byte;
                                    attr,color,hilite,cset: byte) ; 
{
  This routine emulates the Repeat to Address (RA) 3270 data stream order.
  The RA order stores a specified character in all character buffer
  locations, starting at the current buffer address and ending at (but
  not including) the specified stop address. The buffer address is
  relative to the origin of the buffer of the partition to which the
  orders and data are directed and only the character buffer locations
  of that partition are filled.
  Attribute values defined by a previous SA order are applied to each
  repeated character.
  When the stop address is lower than the current buffer address, RA
  wraps from the last buffer location to the first. When the stop address
  equals the current address, the specified character is stored in all
  buffer locations.
  The current buffer address after successfull completion of RA is the
  stop address, that is, one greater than the last buffer location stored
  into by RA.
  Field attributes an their corosponding extended field attributes are
  overwritten by the RA order, if encountered.
}
var
  j,r,c: integer ;
begin
  r := prow ;
  c := pcol ;
  j := 1 ;  { over run counter }
  while not((r = erow) and (c = ecol)) do
    begin
      ScrBuf[r,c].data := Char(ch) ;
      ScrBuf[r,c].Attrib := Char(attr) ;
      ScrBuf[r,c].Hilite := Char(hilite) ;
      ScrBuf[r,c].CharSet := Char(cset) ;
      ScrBuf[r,c].Color := Char(color) ;
      GetNextCell(c,r) ;
      j := j + 1 ;
      if j > (SCRCOLS * SCRROWS) then
        break ;
    end ;
  prow := erow ;
  pcol := ecol ;
end ;

procedure Tscreenf.ModifyField(var row,col: integer;
                                attr,color,hilite,cset: byte) ;  
{
  This routine emulates the Modify Field (MF) 3270 data stream order.
  The MF order changes the attributes and extended attributes of the
  field at the current buffer location. After the attributes have been
  updated, the current buffer address is incremented by one.
  If no attributes are specified (number of value type pairs fiield is 0)
  then the MF order determines if there is a field attribute at the
  current buffer address. If so, the current buffer address is incremented
  by one, and no change is made to the fields properties.
}
begin          
  if (ScrBuf[row,col].data = Char(cdFieldAttr)) then
    begin    
      ScrBuf[row,col].Attrib := Char(attr) ;
      ScrBuf[row,col].Hilite := Char(hilite) ;
      ScrBuf[row,col].CharSet := Char(cset) ;
      ScrBuf[row,col].Color := Char(color) ;  
      GetNextCell(col,row) ;
    end ;
end ;

procedure Tscreenf.DisplayChar(row,col: integer;
                            ch: byte;
                            attr,color,hilite,cset: byte) ;
{
  This routine inserts a displayable character into the buffer at the
  location specified, with the attributes specified.
}
begin
  ScrBuf[row,col].data := Char(ch) ;
  ScrBuf[row,col].Attrib := Char(attr) ;
  ScrBuf[row,col].Hilite := Char(hilite) ;
  ScrBuf[row,col].CharSet := Char(cset) ;
  ScrBuf[row,col].Color := Char(color) ;
end ;

procedure Tscreenf.FillBuf ;
{
  This procedure fills the display buffer with all the possible displayable
  characters (including characters outside the 3270s display range 00-40).
  This is used as a simple test of the display.
}
var
  i, j, k: integer ;
  ch: char ;
begin
  k := 0 ;
  for i := 1 to SCRROWS do
    for j := 1 to SCRCOLS do
      begin
        ch := chr(k) ;
        ScrBuf[i,j].data := ch ;
        k := k + 1 ;
        if k > 255 then
          k := 0 ;
      end ;
end ;
 
procedure Tscreenf.MakeFields ;
{
  This procedure fills the buffer with a variety of all the possible fields
  that the emulator can display. This is used as a test of the display
  functions, and keyboard input.
}
begin
  Field(1,1,(caProtect or caIntens),ccWhite,chUnderLine,csDefault,
    'Field Test Screen') ;
  Field(3,1,caProtect,ccWhite,chUnderLine,csDefault,
    '            Default      Reverse      Blink        Underline    ') ;
  Field(4,1,caProtect,ccRed,chDefault,csDefault,'Red:') ;
  Field(4,13,caDefault,ccRed,chDefault,csDefault,'ABCabc123') ;
  Field(4,26,caDefault,ccRed,chReverse,csDefault,'ABCabc123') ;
  Field(4,39,caDefault,ccRed,chBlink,csDefault,'ABCabc123') ;
  Field(4,52,caDefault,ccRed,chUnderLine,csDefault,'ABCabc123') ;
  Field(4,65,caProtect,ccRed,chDefault,csDefault,'') ;

  Field(5,1,caProtect,ccPink,chDefault,csDefault,'Pink:') ;
  Field(5,13,caDefault,ccPink,chDefault,csDefault,'ABCabc123') ;
  Field(5,26,caDefault,ccPink,chReverse,csDefault,'ABCabc123') ;
  Field(5,39,caDefault,ccPink,chBlink,csDefault,'ABCabc123') ;
  Field(5,52,caDefault,ccPink,chUnderLine,csDefault,'ABCabc123') ;
  Field(5,65,caProtect,ccPink,chDefault,csDefault,'') ;

  Field(6,1,caProtect,ccGreen,chDefault,csDefault,'Green:') ;
  Field(6,13,caDefault,ccGreen,chDefault,csDefault,'ABCabc123') ;
  Field(6,26,caDefault,ccGreen,chReverse,csDefault,'ABCabc123') ;
  Field(6,39,caDefault,ccGreen,chBlink,csDefault,'ABCabc123') ;
  Field(6,52,caDefault,ccGreen,chUnderLine,csDefault,'ABCabc123') ;
  Field(6,65,caProtect,ccGreen,chDefault,csDefault,'') ;

  Field(7,1,caProtect,ccYellow,chDefault,csDefault,'Yellow:') ;
  Field(7,13,caDefault,ccYellow,chDefault,csDefault,'ABCabc123') ;
  Field(7,26,caDefault,ccYellow,chReverse,csDefault,'ABCabc123') ;
  Field(7,39,caDefault,ccYellow,chBlink,csDefault,'ABCabc123') ;
  Field(7,52,caDefault,ccYellow,chUnderLine,csDefault,'ABCabc123') ;
  Field(7,65,caProtect,ccYellow,chDefault,csDefault,'') ;

  Field(8,1,caProtect,ccBlue,chDefault,csDefault,'Blue:') ;
  Field(8,13,caDefault,ccBlue,chDefault,csDefault,'ABCabc123') ;
  Field(8,26,caDefault,ccBlue,chReverse,csDefault,'ABCabc123') ;
  Field(8,39,caDefault,ccBlue,chBlink,csDefault,'ABCabc123') ;
  Field(8,52,caDefault,ccBlue,chUnderLine,csDefault,'ABCabc123') ;
  Field(8,65,caProtect,ccBlue,chDefault,csDefault,'') ;

  Field(9,1,caProtect,ccTurquoise,chDefault,csDefault,'Turquoise:') ;
  Field(9,13,caDefault,ccTurquoise,chDefault,csDefault,'ABCabc123') ;
  Field(9,26,caDefault,ccTurquoise,chReverse,csDefault,'ABCabc123') ;
  Field(9,39,caDefault,ccTurquoise,chBlink,csDefault,'ABCabc123') ;
  Field(9,52,caDefault,ccTurquoise,chUnderLine,csDefault,'ABCabc123') ;
  Field(9,65,caProtect,ccTurquoise,chDefault,csDefault,'') ;

  Field(10,1,caProtect,ccWhite,chDefault,csDefault,'White:') ;
  Field(10,13,caDefault,ccWhite,chDefault,csDefault,'ABCabc123') ;
  Field(10,26,caDefault,ccWhite,chReverse,csDefault,'ABCabc123') ;
  Field(10,39,caDefault,ccWhite,chBlink,csDefault,'ABCabc123') ;
  Field(10,52,caDefault,ccWhite,chUnderLine,csDefault,'ABCabc123') ;
  Field(10,65,caProtect,ccWhite,chDefault,csDefault,'') ;
  
  Field(11,1,caProtect,ccWhite,chUnderLine,csDefault,
    '                                                                ') ;

  Field(13,1,caProtect,ccDefault,chDefault,csDefault,'Intens.Hi:') ;
  Field(13,13,caIntens,ccDefault,chDefault,csDefault,'ABCabc123') ;

  Field(14,1,caProtect,ccDefault,chDefault,csDefault,'Intens.Lo:') ;
  Field(14,13,caDefault,ccDefault,chDefault,csDefault,'ABCabc123') ;

  Field(15,1,caProtect,ccDefault,chDefault,csDefault,'NonDisplay:') ;
  Field(15,13,caNonDisp,ccDefault,chDefault,csDefault,' ') ;

  Field(16,1,caProtect,ccDefault,chDefault,csDefault,'Numeric:') ;
  Field(16,13,caNumeric,ccDefault,chDefault,csDefault,'123') ;

  Field(17,1,caProtect,ccDefault,chDefault,csDefault,' ') ;
end ;

procedure Tscreenf.DispLine(row: integer) ;
{
  Given a display row this routine displays the buffer contents
  for all the cells in that row upon the screen window using
  their cell attributes.
}
var
  i: integer ;
begin
  for i := 1 to SCRCOLS do
    DispCell(i,row,true) ;
end ;

procedure Tscreenf.ShowStatus ;
{
  Status Area format.

  +------------------------------------------------------------------------------+
  TTTTTT  EEEEE       H B NNN I S KKKKKK   DDDDDDDDDDDDDDDDDDDDDDDDDD      RR/CCC
  1---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

  T - Connection indicator or test.
  E - Error indication area.
      X -f   = The key pressed has no function.
      X <->  = The key pressed will not function in this cursor location.
      X Num  = Only numeric keys can be used in this location.
  H - Current character hilite (normal, reverse, underline, or blink)
  B = Block showing currently selected color. 
  N - Contains NUM - Indicates cursor is over a numeric field.
  I - Contains ^ - Indicates insert mode is on.
  S - Contains upward pointing arrow - Indicates caps is on.
  K - Contains K=a xx - Shows the key code (xx) of the last key pressed,
      and if Alt Shift or Ctrl were pressed as well (a). This is only
      displayed after the toggle key Ctrl-F1 is pressed.
  D - Shows information about the cell the cursor is over. The format of
      this is: D=dd A=aa H=hh S=ss C=cc
      Where: dd is the hex value of the data converted to ascii.
             aa is the hex value of the attributes as described in the
                3270 data stream ref.
                00 = Default
             hh is the hex value of the hilite as described in the
                3270 data stream ref.
                00 = Default
                F1 = Blink
                F2 = Reverse video
                F4 = Underscore
             ss is the hex value of the symbol set as described in the
                3270 data stream ref.
                00 = Default
             cc is the hex value of the color as described in the
                3270 data stream ref.
                00 = Default
                F1 = Blue
                F2 = Red
                F3 = Pink
                F4 = Green
                F5 = Turquoise
                F6 = Yellow
                F7 = White
      This is only displayed after the toggle key Ctrl-F1 is pressed.
  R - Cursor row.
  C - Cursor column.

}
var
  StatY, SepX, SepY: integer ;
  i,j: integer ;
begin
  SepX := SCRCOLS * FontWidthPix ;
  SepY := SCRROWS * FontHeightPix ;
  StatY := SCRROWS * FontHeightPix + (FontHeightPix+2) ;
  with canvas do
    begin
      { draw seperator line }
      Pen.Mode := pmCopy ;
      Pen.Color := clBlue ;
      Brush.Style := bsClear ;
      Brush.Color := clBlack ;
      MoveTo(0,SepY) ;
      LineTo(SepX,SepY) ;

      { draw status text }
      Font.Style := [] ;
      Font.Color := clBlue ;
      if test then
        begin
          { draw status box }
          Rectangle(0,SepY+2,FontWidthPix,StatY) ;
          TextOut(FontWidthPix*2,SepY+2,'TEST') ;
        end
      else
        begin
          TextOut(0,SepY+2,'4') ;
          { draw status box }    
          Pen.Mode := pmXor ;
          Rectangle(0,SepY+2,FontWidthPix,StatY) ; 
          Pen.Mode := pmCopy ;

          { connected indicator face = stick man }
          TextOut(FontWidthPix*2,SepY+2,Char($02)) ;

          { display error indicator }
          Font.Color := clRed ;
          if KbdLocked then
            TextOut(FontWidthPix*8,SepY+2,'X '+LockReason)
          else
            TextOut(FontWidthPix*8,SepY+2,'     ') ;

          { display current character hilite }   
          Font.Color := clBlue ;
          if CurCellHilite = Char(chDefault) then
            Font.Style := []
          else if CurCellHilite = Char(chReverse) then
            begin
              Font.Style := [] ;
              Pen.Mode := pmXor ;
              Brush.Color := clBlue ;
              Font.Color := clBlack ;
            end
          else if CurCellHilite = Char(chUnderLine) then
            Font.Style := [fsUnderline]
          else if CurCellHilite = Char(chBlink) then
            Font.Style := [fsStrikeout]
          else
            Font.Style := [] ;
          TextOut(FontWidthPix*21,FontHeightPix*SCRROWS+2,'a') ;
          Pen.Mode := pmCopy ; 
          Font.Style := [] ; 
          Brush.Color := clBlack ;

          { display current character color as a block }
          Font.Color := ColorMapI2W(CurCellColor) ;
          TextOut(FontWidthPix*23,FontHeightPix*SCRROWS+2,#219) ;

          { display NUM indicator }
          Font.Color := clBlue ;
          if (Byte(ScrBuf[CsrRow,CsrCol].attrib) and caNumeric) = caNumeric then
            TextOut(FontWidthPix*25,FontHeightPix*SCRROWS+2,'NUM')
          else
            TextOut(FontWidthPix*25,SCRROWS*FontHeightPix+2,'   ') ;

          { display insert indicator }
          if insert then
            TextOut(FontWidthPix*29,SepY+2,#94)  { up arrow insert indicator }
          else
            TextOut(FontWidthPix*29,SepY+2,' ') ;

          { display caps indicator }
          if Caps then
            TextOut(FontWidthPix*31,SepY+2,#24)  { up arrow caps indicator }
          else
            TextOut(FontWidthPix*31,SepY+2,' ') ;

          { display debug information }
          if ExtStatus then
            begin
              i := CsrRow ;
              j := CsrCol ;
              TextOut(FontWidthPix*42,SepY+2,
                Format('D=%.2x A=%.2x H=%.2x S=%.2x C=%.2x',
                 [Byte(ScrBuf[i,j].data),
                  Byte(ScrBuf[i,j].Attrib),Byte(ScrBuf[i,j].Hilite),
                  Byte(ScrBuf[i,j].CharSet),Byte(ScrBuf[i,j].Color)
                 ]) ) ;
              TextOut(FontWidthPix*33,SepY+2,
                Format('K=%s %.2x',[LastAlt,LastKey])+'  ') ;
            end
          else
            begin
              TextOut(FontWidthPix*33,SepY+2,'      ') ;
              TextOut(FontWidthPix*42,SepY+2,'                         ') ;
            end ;

          { display row and column indicator }
          Font.Color := clWhite ;
          TextOut(FontWidthPix*74,SepY+2,Format('%.2d/%.3d',[CsrRow,CsrCol])) ;
        end ;
    end ;
end ;

procedure Tscreenf.ShowBuf ;
{
  This routine displays the buffer contents for all the cells in the buffer
  upon the screen window using their cell attributes.
}
var
  i, j: integer ;
begin       
  with canvas do
    begin
      Brush.Style := bsSolid ;
      Brush.Color := clBlack ;
      FillRect(ClipRect) ;
    end ;
  for i := 1 to SCRROWS do
    for j := 1 to SCRCOLS do
      DispCell(j,i,false) ;   {dont paint blanks}
  if not test then
    DrawCursor(CsrCol,CsrRow) ; 
  ShowStatus ;
end ;

procedure Tscreenf.ClearCanvas ;
{
  This routine quickly clears the screen window. It does not alter the
  contents of the display buffer.
}
begin
  with canvas do
    begin
      Brush.Style := bsSolid ;
      Brush.Color := clBlack ;
      FillRect(ClipRect) ;
    end ;
end ;

procedure Tscreenf.ClearScr ;   
{
  This routine clears the screen window and the contents of the display
  buffer.
}
begin   
  if not Test then
    begin
      ClearBuf ;
      ClearCanvas ;
      { set the cursor to home }
      CsrCol := 1 ;
      CsrRow := 1 ;
    end ;
end ;

procedure Tscreenf.InitKeyTab ;
{
  This routine initializes the keyboard mapping, which maps the keyboard
  key codes and their shift, alt, and ctrl settings to the emulator
  function they are to perform. It also assigns names to the keys and
  to the emulator functions.
}
begin
  { 08 }
  KeyNameTable[$08] := 'Backspace' ;
  KeyTable[$08].StdCode := kcBackTab ;
  FuncNameTable[kcBackTab] := 'BackTab' ;
  KeyTable[$08].AltCode := kcNA ;
  KeyTable[$08].CtrlCode := kcNA ;
  KeyTable[$08].ShiftCode := kcNA ;
  FuncNameTable[kcNA] := 'NoOpperation' ;
  { 10 }
  KeyNameTable[$10] := 'Shift' ;
  KeyTable[$10].StdCode := kcCapsOff ;
  FuncNameTable[kcCapsOff] := 'CapsOff' ;
  { 11 }                  
  KeyNameTable[$11] := 'Ctrl' ;
  KeyTable[$11].StdCode := kcReset ;
  FuncNameTable[kcReset] := 'Reset' ;   
  { 12 }                       
  KeyNameTable[$12] := 'Alt' ;
  KeyTable[$12].StdCode := kcAlt ;
  FuncNameTable[kcAlt] := 'Alt' ;
  { 13 }         
  KeyNameTable[$13] := 'Pause' ;
  KeyTable[$13].StdCode := kcEraseToEof ;
  FuncNameTable[kcEraseToEof] := 'EraseToEof' ;
  { 14 }                
  KeyNameTable[$14] := 'Caps Lock' ;
  KeyTable[$14].StdCode := kcCapsOn ;
  FuncNameTable[kcCapsOn] := 'CapsOn' ;
  { 1B }                      
  KeyNameTable[$1B] := 'Esc' ;
  KeyTable[$1B].StdCode := kcClearScreen ;
  FuncNameTable[kcClearScreen] := 'ClearScreen' ;
  { 21 }                               
  KeyNameTable[$21] := 'Page Up' ;
  KeyTable[$21].StdCode := kcAlterCursor ;
  FuncNameTable[kcAlterCursor] := 'AlterCursor' ;
  { 22 }                     
  KeyNameTable[$22] := 'Page Down' ;
  KeyTable[$22].StdCode := kcNewLine ;
  FuncNameTable[kcNewLine] := 'NewLine' ;
  { 23 }            
  KeyNameTable[$23] := 'End' ;
  KeyTable[$23].StdCode := kcForwardTab ;
  FuncNameTable[kcForwardTab] := 'ForwardTab' ;
  { 24 }             
  KeyNameTable[$24] := 'Home' ;
  KeyTable[$24].StdCode := kcCursorHome ;
  FuncNameTable[kcCursorHome] := 'CursorHome' ;
  { 25 }                  
  KeyNameTable[$25] := 'Left Arrow' ;
  KeyTable[$25].StdCode := kcCursorLeft ;
  FuncNameTable[kcCursorLeft] := 'CursorLeft' ;
  KeyTable[$25].AltCode := kcCursorLeftFast ;
  FuncNameTable[kcCursorLeftFast] := 'CursorLeftFast' ;
  { 26 }             
  KeyNameTable[$26] := 'Up Arrow' ;
  KeyTable[$26].StdCode := kcCursorUp ;
  FuncNameTable[kcCursorUp] := 'CursorUp' ; 
  KeyTable[$26].AltCode := kcCursorUpFast ;
  FuncNameTable[kcCursorUpFast] := 'CursorUpFast' ;
  { 27 }
  KeyNameTable[$27] := 'Right Arrow' ;
  KeyTable[$27].StdCode := kcCursorRight ;
  FuncNameTable[kcCursorRight] := 'CursorRight' ; 
  KeyTable[$27].AltCode := kcCursorRightFast ;
  FuncNameTable[kcCursorRightFast] := 'CursorRightFast' ;
  { 28 }               
  KeyNameTable[$28] := 'Down Arrow' ;
  KeyTable[$28].StdCode := kcCursorDown ;
  FuncNameTable[kcCursorDown] := 'CursorDown' ; 
  KeyTable[$28].AltCode := kcCursorDownFast ;
  FuncNameTable[kcCursorDownFast] := 'CursorDownFast' ;
  { 2D }                      
  KeyNameTable[$2D] := 'Insert' ;
  KeyTable[$2D].StdCode := kcInsertOn ;
  FuncNameTable[kcInsertOn] := 'InsertOn' ;
  { 2E }      
  KeyNameTable[$2E] := 'Delete' ;
  KeyTable[$2E].StdCode := kcDeleteChar ;
  FuncNameTable[kcDeleteChar] := 'DeleteChar' ;
  { 30 }                
  KeyNameTable[$30] := '0' ;
  KeyTable[$30].StdCode := kcNumber0 ;
  FuncNameTable[kcNumber0] := '0' ;
  KeyTable[$30].ShiftCode := kcSymbolRightParen ;
  FuncNameTable[kcSymbolRightParen] := ')' ;
  { 31 }        
  KeyNameTable[$31] := '1' ;
  KeyTable[$31].StdCode := kcNumber1 ;
  FuncNameTable[kcNumber1] := '1' ;
  KeyTable[$31].ShiftCode := kcExclamationMark ;
  FuncNameTable[kcExclamationMark] := '!' ;
  { 32 }         
  KeyNameTable[$32] := '2' ;
  KeyTable[$32].StdCode := kcNumber2 ;
  FuncNameTable[kcNumber2] := '2' ;
  KeyTable[$32].ShiftCode := kcSymbolAt ;
  FuncNameTable[kcSymbolAt] := '@' ;
  { 33 }       
  KeyNameTable[$33] := '3' ;
  KeyTable[$33].StdCode := kcNumber3 ;
  FuncNameTable[kcNumber3] := '3' ;
  KeyTable[$33].ShiftCode := kcSymbolHash ;
  FuncNameTable[kcSymbolHash] := '#' ;
  { 34 }        
  KeyNameTable[$34] := '4' ;
  KeyTable[$34].StdCode := kcNumber4 ;
  FuncNameTable[kcNumber4] := '4' ;
  KeyTable[$34].ShiftCode := kcSymbolDollar ;
  FuncNameTable[kcSymbolDollar] := '$' ;
  { 35 }             
  KeyNameTable[$35] := '5' ;
  KeyTable[$35].StdCode := kcNumber5 ;
  FuncNameTable[kcNumber5] := '5' ;
  KeyTable[$35].ShiftCode := kcSymbolPercent ;
  FuncNameTable[kcSymbolPercent] := '%' ;
  { 36 }     
  KeyNameTable[$36] := '6' ;
  KeyTable[$36].StdCode := kcNumber6 ;
  FuncNameTable[kcNumber6] := '6' ;
  KeyTable[$36].ShiftCode := kcSymbolCarret ;
  FuncNameTable[kcSymbolCarret] := '^' ;
  { 37 }        
  KeyNameTable[$37] := '7' ;
  KeyTable[$37].StdCode := kcNumber7 ;
  FuncNameTable[kcNumber7] := '7' ;
  KeyTable[$37].ShiftCode := kcSymbolAmpersand ;
  FuncNameTable[kcSymbolAmpersand] := '&' ;
  { 38 }                  
  KeyNameTable[$38] := '8' ;
  KeyTable[$38].StdCode := kcNumber8 ;
  FuncNameTable[kcNumber8] := '8' ;
  KeyTable[$38].ShiftCode := kcSymbolStar ;
  FuncNameTable[kcSymbolStar] := '*' ;
  { 39 }               
  KeyNameTable[$39] := '9' ;
  KeyTable[$39].StdCode := kcNumber9 ;
  FuncNameTable[kcNumber9] := '9' ;
  KeyTable[$39].ShiftCode := kcSymbolLeftParen ;
  FuncNameTable[kcSymbolLeftParen] := '(' ;
  { 41 }         
  KeyNameTable[$41] := 'A' ;
  KeyTable[$41].StdCode := kcSmallLetterA ;
  FuncNameTable[kcSmallLetterA] := 'a' ;
  KeyTable[$41].ShiftCode := kcCapitalLetterA ;
  FuncNameTable[kcCapitalLetterA] := 'A' ;
  { 42 }   
  KeyNameTable[$42] := 'B' ;
  KeyTable[$42].StdCode := kcSmallLetterB ;
  FuncNameTable[kcSmallLetterB] := 'b' ;
  KeyTable[$42].ShiftCode := kcCapitalLetterB ;
  FuncNameTable[kcCapitalLetterB] := 'B' ;
  { 43 }          
  KeyNameTable[$43] := 'C' ;
  KeyTable[$43].StdCode := kcSmallLetterC ;
  FuncNameTable[kcSmallLetterC] := 'c' ;
  KeyTable[$43].ShiftCode := kcCapitalLetterC ;
  FuncNameTable[kcCapitalLetterC] := 'C' ;
  { 44 }                
  KeyNameTable[$44] := 'D' ;
  KeyTable[$44].StdCode := kcSmallLetterD ;
  FuncNameTable[kcSmallLetterD] := 'd' ;
  KeyTable[$44].ShiftCode := kcCapitalLetterD ;
  FuncNameTable[kcCapitalLetterD] := 'D' ;
  { 45 }       
  KeyNameTable[$45] := 'E' ;
  KeyTable[$45].StdCode := kcSmallLetterE ;
  FuncNameTable[kcSmallLetterE] := 'e' ;
  KeyTable[$45].ShiftCode := kcCapitalLetterE ;
  FuncNameTable[kcCapitalLetterE] := 'E' ;
  { 46 }         
  KeyNameTable[$46] := 'F' ;
  KeyTable[$46].StdCode := kcSmallLetterF ;
  FuncNameTable[kcSmallLetterF] := 'f' ;
  KeyTable[$46].ShiftCode := kcCapitalLetterF ;
  FuncNameTable[kcCapitalLetterF] := 'F' ;
  { 47 }                   
  KeyNameTable[$47] := 'G' ;
  KeyTable[$47].StdCode := kcSmallLetterG ;
  FuncNameTable[kcSmallLetterG] := 'g' ;
  KeyTable[$47].ShiftCode := kcCapitalLetterG ;
  FuncNameTable[kcCapitalLetterG] := 'G' ;
  { 48 }           
  KeyNameTable[$48] := 'H' ;
  KeyTable[$48].StdCode := kcSmallLetterH ;
  FuncNameTable[kcSmallLetterH] := 'h' ;
  KeyTable[$48].ShiftCode := kcCapitalLetterH ;
  FuncNameTable[kcCapitalLetterH] := 'H' ;
  { 49 }       
  KeyNameTable[$49] := 'I' ;
  KeyTable[$49].StdCode := kcSmallLetterI ;
  FuncNameTable[kcSmallLetterI] := 'i' ;
  KeyTable[$49].ShiftCode := kcCapitalLetterI ;
  FuncNameTable[kcCapitalLetterI] := 'I' ;
  { 4A }             
  KeyNameTable[$4A] := 'J' ;
  KeyTable[$4A].StdCode := kcSmallLetterJ ;
  FuncNameTable[kcSmallLetterJ] := 'j' ;
  KeyTable[$4A].ShiftCode := kcCapitalLetterJ ;
  FuncNameTable[kcCapitalLetterJ] := 'J' ;
  { 4B }                
  KeyNameTable[$4B] := 'K' ;
  KeyTable[$4B].StdCode := kcSmallLetterK ;
  FuncNameTable[kcSmallLetterK] := 'k' ;
  KeyTable[$4B].ShiftCode := kcCapitalLetterK ;
  FuncNameTable[kcCapitalLetterK] := 'K' ;
  { 4C }              
  KeyNameTable[$4C] := 'L' ;
  KeyTable[$4C].StdCode := kcSmallLetterL ;
  FuncNameTable[kcSmallLetterL] := 'l' ;
  KeyTable[$4C].ShiftCode := kcCapitalLetterL ;
  FuncNameTable[kcCapitalLetterL] := 'L' ;
  { 4D }        
  KeyNameTable[$4D] := 'M' ;
  KeyTable[$4D].StdCode := kcSmallLetterM ;
  FuncNameTable[kcSmallLetterM] := 'm' ;
  KeyTable[$4D].ShiftCode := kcCapitalLetterM ;
  FuncNameTable[kcCapitalLetterM] := 'M' ;
  { 4E }   
  KeyNameTable[$4E] := 'N' ;
  KeyTable[$4E].StdCode := kcSmallLetterN ;
  FuncNameTable[kcSmallLetterN] := 'n' ;
  KeyTable[$4E].ShiftCode := kcCapitalLetterN ;
  FuncNameTable[kcCapitalLetterN] := 'N' ;
  { 4F }            
  KeyNameTable[$4F] := 'O' ;
  KeyTable[$4F].StdCode := kcSmallLetterO ;
  FuncNameTable[kcSmallLetterO] := 'o' ;
  KeyTable[$4F].ShiftCode := kcCapitalLetterO ;
  FuncNameTable[kcCapitalLetterO] := 'O' ;
  { 50 }         
  KeyNameTable[$50] := 'P' ;
  KeyTable[$50].StdCode := kcSmallLetterP ;
  FuncNameTable[kcSmallLetterP] := 'p' ;
  KeyTable[$50].ShiftCode := kcCapitalLetterP ;
  FuncNameTable[kcCapitalLetterP] := 'P' ;
  { 51 }               
  KeyNameTable[$51] := 'Q' ;
  KeyTable[$51].StdCode := kcSmallLetterQ ;
  FuncNameTable[kcSmallLetterQ] := 'q' ;
  KeyTable[$51].ShiftCode := kcCapitalLetterQ ;
  FuncNameTable[kcCapitalLetterQ] := 'Q' ;
  { 52 }      
  KeyNameTable[$52] := 'R' ;
  KeyTable[$52].StdCode := kcSmallLetterR ;
  FuncNameTable[kcSmallLetterR] := 'r' ;
  KeyTable[$52].ShiftCode := kcCapitalLetterR ;
  FuncNameTable[kcCapitalLetterR] := 'R' ;
  { 53 }   
  KeyNameTable[$53] := 'S' ;
  KeyTable[$53].StdCode := kcSmallLetterS ;
  FuncNameTable[kcSmallLetterS] := 's' ;
  KeyTable[$53].ShiftCode := kcCapitalLetterS ;
  FuncNameTable[kcCapitalLetterS] := 'S' ;
  { 54 }              
  KeyNameTable[$54] := 'T' ;
  KeyTable[$54].StdCode := kcSmallLetterT ;
  FuncNameTable[kcSmallLetterT] := 't' ;
  KeyTable[$54].ShiftCode := kcCapitalLetterT ;
  FuncNameTable[kcCapitalLetterT] := 'T' ;
  { 55 }                
  KeyNameTable[$55] := 'U' ;
  KeyTable[$55].StdCode := kcSmallLetterU ;
  FuncNameTable[kcSmallLetterU] := 'u' ;
  KeyTable[$55].ShiftCode := kcCapitalLetterU ;
  FuncNameTable[kcCapitalLetterU] := 'U' ;
  { 56 }                   
  KeyNameTable[$56] := 'V' ;
  KeyTable[$56].StdCode := kcSmallLetterV ;
  FuncNameTable[kcSmallLetterV] := 'v' ;
  KeyTable[$56].ShiftCode := kcCapitalLetterV ;
  FuncNameTable[kcCapitalLetterV] := 'V' ;
  { 57 }        
  KeyNameTable[$57] := 'W' ;
  KeyTable[$57].StdCode := kcSmallLetterW ;
  FuncNameTable[kcSmallLetterW] := 'w' ;
  KeyTable[$57].ShiftCode := kcCapitalLetterW ;
  FuncNameTable[kcCapitalLetterW] := 'W' ;
  { 58 }           
  KeyNameTable[$58] := 'X' ;
  KeyTable[$58].StdCode := kcSmallLetterX ;
  FuncNameTable[kcSmallLetterX] := 'x' ;
  KeyTable[$58].ShiftCode := kcCapitalLetterX ;
  FuncNameTable[kcCapitalLetterX] := 'X' ;
  { 59 }            
  KeyNameTable[$59] := 'Y' ;
  KeyTable[$59].StdCode := kcSmallLetterY ;
  FuncNameTable[kcSmallLetterY] := 'y' ;
  KeyTable[$59].ShiftCode := kcCapitalLetterY ;
  FuncNameTable[kcCapitalLetterY] := 'Y' ;
  { 5A }                 
  KeyNameTable[$5A] := 'Z' ;
  KeyTable[$5A].StdCode := kcSmallLetterZ ;
  FuncNameTable[kcSmallLetterZ] := 'z' ;
  KeyTable[$5A].ShiftCode := kcCapitalLetterZ ;
  FuncNameTable[kcCapitalLetterZ] := 'Z' ;
  { C0 }      
  KeyNameTable[$C0] := '`' ;
  KeyTable[$C0].StdCode := kcSymbolTick ;
  FuncNameTable[kcSymbolTick] := '`' ;
  KeyTable[$C0].ShiftCode := kcSymbolTilde ;
  FuncNameTable[kcSymbolTilde] := '~' ;
  { BD }    
  KeyNameTable[$BD] := '-' ;
  KeyTable[$BD].StdCode := kcSymbolMinus ;
  FuncNameTable[kcSymbolMinus] := '-' ;
  KeyTable[$BD].ShiftCode := kcSymbolUnderScore ;
  FuncNameTable[kcSymbolUnderScore] := '_' ;
  { BB }     
  KeyNameTable[$BB] := '=' ;
  KeyTable[$BB].StdCode := kcSymbolEqual ;
  FuncNameTable[kcSymbolEqual] := '=' ;
  KeyTable[$BB].ShiftCode := kcSymbolPlus ;
  FuncNameTable[kcSymbolPlus] := '+' ;
  { DC }       
  KeyNameTable[$DC] := '\' ;
  KeyTable[$DC].StdCode := kcSymbolBackSlash ;
  FuncNameTable[kcSymbolBackSlash] := '\' ;
  KeyTable[$DC].ShiftCode := kcSymbolBar ;
  FuncNameTable[kcSymbolBar] := '|' ;
  { 90 }    
  KeyNameTable[$90] := 'Num Lock' ;
  KeyTable[$90].StdCode := kcNA ;  { NumLock }
  { 6F }              
  KeyNameTable[$6F] := '/' ;
  KeyTable[$6F].StdCode := kcSymbolSlash ;
  FuncNameTable[kcSymbolSlash] := '/' ;
  { 6A }        
  KeyNameTable[$6A] := '*' ;
  KeyTable[$6A].StdCode := kcSymbolStar ; { see above }
  { 6D }            
  KeyNameTable[$6D] := '-' ;
  KeyTable[$6D].StdCode := kcSymbolMinus ; { see above }
  { DB }              
  KeyNameTable[$DB] := '[' ;
  KeyTable[$DB].StdCode := kcSymbolLeftSquareBrace ;
  FuncNameTable[kcSymbolLeftSquareBrace] := '[' ;
  KeyTable[$DB].ShiftCode := kcSymbolLeftCurlyBrace ;
  FuncNameTable[kcSymbolLeftCurlyBrace] := '{' ;
  { DD }          
  KeyNameTable[$DD] := ']' ;
  KeyTable[$DD].StdCode := kcSymbolRightSquareBrace ;
  FuncNameTable[kcSymbolRightSquareBrace] := ']' ;
  KeyTable[$DD].ShiftCode := kcSymbolRightCurlyBrace ;
  FuncNameTable[kcSymbolRightCurlyBrace] := '}' ;  
  { 6B }           
  KeyNameTable[$6B] := '+' ;
  KeyTable[$6B].StdCode := kcSymbolPlus ; { see above }
  { BA }     
  KeyNameTable[$BA] := ';' ;
  KeyTable[$BA].StdCode := kcSymbolSemiColon ;
  FuncNameTable[kcSymbolSemiColon] := ';' ;
  KeyTable[$BA].ShiftCode := kcSymbolColon ;
  FuncNameTable[kcSymbolColon] := ':' ;
  { DE }        
  KeyNameTable[$DE] := '''' ;
  KeyTable[$DE].StdCode := kcSymbolSingleQuote ;
  FuncNameTable[kcSymbolSingleQuote] := '''' ;
  KeyTable[$DE].ShiftCode := kcSymbolDoubleQuote ;
  FuncNameTable[kcSymbolDoubleQuote] := '"' ;
  { BC }          
  KeyNameTable[$BC] := ',' ;
  KeyTable[$BC].StdCode := kcSymbolComma ;
  FuncNameTable[kcSymbolComma] := ',' ;
  KeyTable[$BC].ShiftCode := kcSymbolLessThan ;
  FuncNameTable[kcSymbolLessThan] := '<' ;
  { BE }             
  KeyNameTable[$BE] := '.' ;
  KeyTable[$BE].StdCode := kcSymbolDot ;
  FuncNameTable[kcSymbolDot] := '.' ;
  KeyTable[$BE].ShiftCode := kcSymbolGreaterThan ;
  FuncNameTable[kcSymbolGreaterThan] := '>' ;
  { BF }               
  KeyNameTable[$BF] := '/' ;
  KeyTable[$BF].StdCode := kcSymbolSlash ;  { see above }
  KeyTable[$BF].ShiftCode := kcSymbolQuestionMark ;
  FuncNameTable[kcSymbolQuestionMark] := '?' ;
  { 20 }               
  KeyNameTable[$20] := ' ' ;
  KeyTable[$20].StdCode := kcSymbolSpace ;
  FuncNameTable[kcSymbolSpace] := ' ' ;
  { 70 }        
  KeyNameTable[$70] := 'F1' ;
  KeyTable[$70].StdCode := kcPF1 ;
  FuncNameTable[kcPF1] := 'PF1' ;
  KeyTable[$70].ShiftCode := kcPF13 ;
  FuncNameTable[kcPF13] := 'PF13' ;
  KeyTable[$70].AltCode := kcColorRed ;
  FuncNameTable[kcColorRed] := 'ColorRed' ;
  KeyTable[$70].CtrlCode := kcExtStatus ;
  FuncNameTable[kcExtStatus] := 'ExtStatus' ;
  { 71 }         
  KeyNameTable[$71] := 'F2' ;
  KeyTable[$71].StdCode := kcPF2 ;
  FuncNameTable[kcPF2] := 'PF2' ;
  KeyTable[$71].ShiftCode := kcPF14 ;
  FuncNameTable[kcPF14] := 'PF14' ;
  KeyTable[$71].AltCode := kcColorPink ;
  FuncNameTable[kcColorPink] := 'ColorPink' ;
  { 72 }                
  KeyNameTable[$72] := 'F3' ;
  KeyTable[$72].StdCode := kcPF3 ;
  FuncNameTable[kcPF3] := 'PF3' ;
  KeyTable[$72].ShiftCode := kcPF15 ;
  FuncNameTable[kcPF15] := 'PF15' ;
  KeyTable[$72].AltCode := kcColorGreen ;
  FuncNameTable[kcColorGreen] := 'ColorGreen' ;
  { 73 }                       
  KeyNameTable[$73] := 'F4' ;
  KeyTable[$73].StdCode := kcPF4 ;
  FuncNameTable[kcPF4] := 'PF4' ;
  KeyTable[$73].ShiftCode := kcPF16 ;
  FuncNameTable[kcPF16] := 'PF16' ;
  KeyTable[$73].AltCode := kcColorYellow ;
  FuncNameTable[kcColorYellow] := 'ColorYellow' ;
  { 74 }                       
  KeyNameTable[$74] := 'F5' ;
  KeyTable[$74].StdCode := kcPF5 ;
  FuncNameTable[kcPF5] := 'PF5' ;
  KeyTable[$74].ShiftCode := kcPF17 ;
  FuncNameTable[kcPF17] := 'PF17' ;
  KeyTable[$74].AltCode := kcColorBlue ;
  FuncNameTable[kcColorBlue] := 'ColorBlue' ;
  { 75 }                             
  KeyNameTable[$75] := 'F6' ;
  KeyTable[$75].StdCode := kcPF6 ;
  FuncNameTable[kcPF6] := 'PF6' ;
  KeyTable[$75].ShiftCode := kcPF18 ;
  FuncNameTable[kcPF18] := 'PF18' ;
  KeyTable[$75].AltCode := kcColorTurquoise ;
  FuncNameTable[kcColorTurquoise] := 'ColorTurquoise' ;
  { 76 }                          
  KeyNameTable[$76] := 'F6' ;
  KeyTable[$76].StdCode := kcPF7 ;
  FuncNameTable[kcPF7] := 'PF7' ;
  KeyTable[$76].ShiftCode := kcPF19 ;
  FuncNameTable[kcPF19] := 'PF19' ;
  KeyTable[$76].AltCode := kcColorWhite ;
  FuncNameTable[kcColorWhite] := 'ColorWhite' ;
  { 77 }       
  KeyNameTable[$77] := 'F8' ;
  KeyTable[$77].StdCode := kcPF8 ;
  FuncNameTable[kcPF8] := 'PF8' ;
  KeyTable[$77].ShiftCode := kcPF20 ;
  FuncNameTable[kcPF20] := 'PF20' ;
  KeyTable[$77].AltCode := kcColorDefault ;
  FuncNameTable[kcColorDefault] := 'ColorDefault' ;
  { 78 }              
  KeyNameTable[$78] := 'F9' ;
  KeyTable[$78].StdCode := kcPF9 ;
  FuncNameTable[kcPF9] := 'PF9' ;
  KeyTable[$78].ShiftCode := kcPF21 ;
  FuncNameTable[kcPF21] := 'PF21' ;
  KeyTable[$78].AltCode := kcHiliteReverse ;
  FuncNameTable[kcHiliteReverse] := 'HiliteReverse' ;
  { 79 }            
  KeyNameTable[$79] := 'F10' ;
  KeyTable[$79].StdCode := kcPF10 ;
  FuncNameTable[kcPF10] := 'PF10' ;
  KeyTable[$79].ShiftCode := kcPF22 ;
  FuncNameTable[kcPF22] := 'PF22' ;
  KeyTable[$79].AltCode := kcHiliteBlink ;
  FuncNameTable[kcHiliteBlink] := 'HiliteBlink' ;
  { 7A }                  
  KeyNameTable[$7A] := 'F11' ;
  KeyTable[$7A].StdCode := kcPF11 ;
  FuncNameTable[kcPF11] := 'PF11' ;
  KeyTable[$7A].ShiftCode := kcPF23 ;
  FuncNameTable[kcPF23] := 'PF23' ;
  KeyTable[$7A].AltCode := kcHiliteUnderLine ;
  FuncNameTable[kcHiliteUnderLine] := 'HiliteUnderLine' ;
  { 7B }              
  KeyNameTable[$7B] := 'F12' ;
  KeyTable[$7B].StdCode := kcPF12 ;
  FuncNameTable[kcPF12] := 'PF12' ;
  KeyTable[$7B].ShiftCode := kcPF24 ;
  FuncNameTable[kcPF24] := 'PF24' ;
  KeyTable[$7B].AltCode := kcHiliteDefault ;
  FuncNameTable[kcHiliteDefault] := 'HiliteDefault' ;
  { 0D }      
  KeyNameTable[$0D] := 'Enter' ;
  KeyTable[$0D].StdCode := kcEnter ;
  FuncNameTable[kcEnter] := 'Enter' ;

  { codes not currently allocated a key }
  FuncNameTable[kcAttn] := 'Attn' ;
  FuncNameTable[kcSysreq] := 'Sysreq' ;
  FuncNameTable[kcSelectPSA] := 'SelectPSA' ;
  FuncNameTable[kcSelectPSB] := 'SelectPSB' ;
  FuncNameTable[kcSelectPSDefault] := 'SelectPSDefault' ;
  FuncNameTable[kcPA1] := 'PA1' ;
  FuncNameTable[kcPA2] := 'PA2' ;
  FuncNameTable[kcPA3] := 'PA3' ;
  FuncNameTable[kcRule] := 'Rule' ;
end ;

procedure Tscreenf.BackTab ;
{
  Emulates the 3270 back tab keyboard function. Positions the cursor at
  the beginning of the previous unprotected field. This function can span
  multiple rows, and can wrap from the first buffer location to the last
  location.
}
var
  r,c: integer ;  { temp row and col }
  j: integer ;    { temp counter     }
begin  { back space = back tab }
  { redraw cell that cursor inhabited }
  DispCell(CsrCol,CsrRow,true) ;
  { get index of byte left of the cursor }
  c := CsrCol ;
  r := CsrRow ;
  GetPrevCell(c,r) ;
  { r,c is now byte left of cursor }
  if (ScrBuf[r,c].data = Char(cdFieldAttr)) or
    (ScrBuf[CsrRow,CsrCol].data = Char(cdFieldAttr)) then
    { use byte left of field attribute }
    GetPrevCell(c,r)
  else   { use current cursor loc as start point }
    begin
      c := CsrCol ;
      r := CsrRow ;
    end ;

  { advance the cursor to the next left attr byte }
  j := 0 ;
  while not(
    (ScrBuf[r,c].data = Char(cdFieldAttr)) and
    ((Byte(ScrBuf[r,c].attrib) and caProtect) <> caProtect)
    ) do
    begin
      j := j + 1 ;
      GetPrevCell(c,r) ;
      if j > (SCRROWS*SCRCOLS) then  { buffer has no attr }
        break ;
    end ;  { of while }

  { adjust to byte following attribute byte }
  if j <= (SCRROWS*SCRCOLS) then
    begin
      CsrCol := c ;
      CsrRow := r ;
      GetNextCell(CsrCol,CsrRow) ;
    end ;
  DrawCursor(CsrCol,CsrRow) ;
end ;

procedure Tscreenf.EraseEof ;    
{
  Emulates the 3270 erase to end of field keyboard function. Erases
  data from the end of an unprotected field until the beginning of the
  next field. This function can span multiple rows, and can wrap from
  the last buffer location to the first location.
}
var      
  r,c: integer ;  { temp row and col }
  ok: boolean ;   { return code }
begin  { pause = erase to eof }
  { erase data from cursor to end of field, returns eof }
  ok := EraseToEof(CsrCol,CsrRow,c,r) ;
  if ok then
    begin
      { display all erased cells }
      DispCells(CsrCol,CsrRow,c,r,true) ;
      DrawCursor(CsrCol,CsrRow) ;
    end
  else
    LockKeyBoard('<->') ;
end ;

procedure Tscreenf.NewLine ;
{
  Emulates the 3270 new line (tab down and left) keyboard function. The
  cursor is moved down at least one line until an unprotected field
  exists on that line. Then the cursor is positioned in the first
  cell of the left most unprotected field.
}
var
  r,c: integer ;  { temp row and col }
  j: integer ;    { temp counter     }
begin  { page down = down and left tab - newline }
  { redraw cell that cursor inhabited }
  DispCell(CsrCol,CsrRow,true) ;
  { copy the cursor lock, only ajust real cursor at end }
  c := CsrCol ;
  r := CsrRow ;
  { advance the cursor down and to the left most col }
  if r = SCRROWS then
    r := 1
  else
    r := r + 1 ;
  c := 1 ;
  j := 0 ; { over run counter }
  while not(
    (ScrBuf[r,c].data = Char(cdFieldAttr)) and
    ((Byte(ScrBuf[r,c].attrib) and caProtect) <> caProtect)
    ) do
    begin
      j := j + 1 ;
      GetNextCell(c,r) ;
      if j > (SCRROWS*SCRCOLS) then  { buffer has no attr }
        break ;
    end ;  { of while }

  { adjust to byte following attribute byte }
  if j <= (SCRROWS*SCRCOLS) then
    begin
      CsrCol := c ;
      CsrRow := r ;
      GetNextCell(CsrCol,CsrRow) ;
    end ;
  DrawCursor(CsrCol,CsrRow) ;
end ;

procedure Tscreenf.ForwardTab ;
{
  Emulates the 3270 forward tab keyboard function. Positions the cursor at
  the beginning of the next unprotected field. This function can span
  multiple rows, and can wrap from the last buffer location to the first
  location.
}
var
  r,c: integer ;  { temp row and col }
  j: integer ;    { temp counter     }
begin  { end = forward tab }
  { redraw cell that cursor inhabited }
  DispCell(CsrCol,CsrRow,true) ;
  c := CsrCol ;
  r := CsrRow ;
  { advance the cursor to the next left attr byte }
  j := 0 ;
  while not(
    (ScrBuf[r,c].data = Char(cdFieldAttr)) and
    ((Byte(ScrBuf[r,c].attrib) and caProtect) <> caProtect)
    ) do
    begin
      j := j + 1 ;
      GetNextCell(c,r) ;
      if j > (SCRROWS*SCRCOLS) then { buffer has no attr }
        break ;
    end ;  { of while }

  { adjust to byte following attribute byte }
  if j <= (SCRROWS*SCRCOLS) then
    begin
      CsrCol := c ;
      CsrRow := r ;
      GetNextCell(CsrCol,CsrRow) ;
    end ;
  DrawCursor(CsrCol,CsrRow) ;
end ;

procedure Tscreenf.ClearScreen ; 
{
  Emulates the 3270 clear keyboard function. Positions the cursor at
  the first location on the screen, and removes all data and attributes
  from the buffer, leaving entire screen as one unprotected field.
}
begin  { ESC = clear screen }
  { clear the screen }
  ClearScr ; 
  { set the cursor to home }
  CsrCol := 1 ;
  CsrRow := 1 ;
  DrawCursor(CsrCol,CsrRow) ;
  { send data back to host }
  Ds3270.DataOutShort(ckAidClear) ;
end ;

procedure Tscreenf.AlterCursor ;
{
  Emulates the 3270 alt-cursor keyboard function. The cursor shape is
  toggled from an underscore to a block, and viz.
}
begin  { page up = Alt Cursor }
  if csrShape = csrUnderLine then
    csrShape := csrEmptyBox
  else
    csrShape := csrUnderLine ;
  DrawCursor(CsrCol,CsrRow) ;
end  ;

procedure Tscreenf.CursorHome ;
{
  Emulates the 3270 home keyboard function. The cursor is moved to the
  first character in the first unprotected field on the screen.
}
begin  { home = home }
  { redraw cell that cursor inhabited }
  DispCell(CsrCol,CsrRow,true) ;
  { advance the cursor left }
  CsrCol := 1 ;
  CsrRow := 1 ;
  DrawCursor(CsrCol,CsrRow) ;
end ;

procedure Tscreenf.CursorLeft(speed: integer) ;
{
  Emulates the 3270 left arrow keyboard function. The cursor is moved left
  one cell. If the cursor crosses the left boundary it is repositioned
  on the same row next to the right boundary.
}
begin  { left arrow and back space }
  { redraw cell that cursor inhabited }
  DispCell(CsrCol,CsrRow,true) ;
  { advance the cursor left }  
  CsrCol := CsrCol - speed ;
  if CsrCol <= 0 then
    CsrCol := SCRCOLS ;
  DrawCursor(CsrCol,CsrRow) ;
end ;

procedure Tscreenf.CursorUp(speed: integer) ;
{
  Emulates the 3270 up arrow keyboard function. The cursor is moved up
  one cell. If the cursor crosses the top boundary it is repositioned
  on the same column at the bottom boundary.
}
begin { up arrow }
  { redraw cell that cursor inhabited }
  DispCell(CsrCol,CsrRow,true) ;
  { advance the cursor up }
  CsrRow := CsrRow - speed ;
  if CsrRow <= 0 then
    CsrRow := SCRROWS ;
  DrawCursor(CsrCol,CsrRow) ;
end ;

procedure Tscreenf.CursorRight(speed: integer) ;   
{
  Emulates the 3270 right arrow keyboard function. The cursor is moved right
  one cell. If the cursor crosses the right boundary it is repositioned
  on the same row next to the left boundary.
}
begin  { right arrow }
  { redraw cell that cursor inhabited }
  DispCell(CsrCol,CsrRow,true) ;
  { advance the cursor right } 
  CsrCol := CsrCol + speed ;
  if CsrCol > SCRCOLS then
    CsrCol := 1 ;
  DrawCursor(CsrCol,CsrRow) ;
end ;

procedure Tscreenf.CursorDown(speed: integer) ;   
{
  Emulates the 3270 down arrow keyboard function. The cursor is moved down
  one cell. If the cursor crosses the bottom boundary it is repositioned
  on the same column at the top boundary.
}
begin { down arrow }
  { redraw cell that cursor inhabited }
  DispCell(CsrCol,CsrRow,true) ;
  { advance the cursor down }  
  CsrRow := CsrRow + speed ;
  if CsrRow > SCRROWS then
    CsrRow := 1 ;
  DrawCursor(CsrCol,CsrRow) ;
end ;

procedure Tscreenf.DeleteCh ;
{
  Emulates the 3270 delete keyboard function. A character is deleted
  from an unprotected field and characters to the right of the deleted
  character are shifted left to occupy the deleted characters cell.
  Character deletion can not span rows.
}
var
  ok: boolean ;   { return code }
begin { delete key }
  ok := DeleteChar(CsrCol,CsrRow) ;
  if ok then
    begin
      { redraw line that cursor inhabits }
      DispLine(CsrRow) ;
      DrawCursor(CsrCol,CsrRow) ;
    end
  else
    LockKeyBoard('<->') ;
end ;

procedure Tscreenf.InsertOn ;
{
  Emulates the 3270 insert-on keyboard function. The insert flag is turned
  on and the status area indicates that insert is on. The reset keyboard
  function turns insert off.
}
begin
  Insert := True ;
end ;

procedure Tscreenf.CapsOn ;   
{
  Emulates the 3270 caps-lock keyboard function. The caps flag is turned
  on and the status area indicates that caps is on. The shift keyboard
  function turns caps off.
}
begin
  Caps := True ;
end ;

procedure Tscreenf.Reset ; 
{
  Emulates the 3270 reset keyboard function. The insert flag is turned
  off, error conditiones are reset, and the keyboard is un-locked.
}
begin
  UnLockKeyBoard ;
end ;

procedure Tscreenf.ResetDefaults ;    
{
  Resets to the default data entry settings.
}
begin
  Rule := False ;
  ExtStatus := False ;
  CurCellColor := Char(ccDefault) ;
  CurCellHilite := Char(chDefault) ;
  CsrShape := csrUnderLine ;
end;

procedure Tscreenf.CapsOff ;
{
  Emulates the 3270 shift keyboard function. The caps flag is turned
  off.
}
begin
  Caps := False ;
end ;

procedure Tscreenf.Nothing ;
{
  Does nothing nicely.
}
begin
end ;

procedure Tscreenf.FunctionKey(keyno: integer) ;
{
  Translates the function key number to the 3270 AID and calls data out to
  send build the data stream which is then sent to the host.
}
begin     
  case keyno of       
    0: Ds3270.DataOut(ckAidEnter) ;
    1: Ds3270.DataOut(ckAidPF1) ;
    2: Ds3270.DataOut(ckAidPF2) ;
    3: Ds3270.DataOut(ckAidPF3) ;
    4: Ds3270.DataOut(ckAidPF4) ;
    5: Ds3270.DataOut(ckAidPF5) ;
    6: Ds3270.DataOut(ckAidPF6) ;
    7: Ds3270.DataOut(ckAidPF7) ;
    8: Ds3270.DataOut(ckAidPF8) ;
    9: Ds3270.DataOut(ckAidPF9) ;
    10: Ds3270.DataOut(ckAidPF10) ;
    11: Ds3270.DataOut(ckAidPF11) ;
    12: Ds3270.DataOut(ckAidPF12) ;
    13: Ds3270.DataOut(ckAidPF13) ;
    14: Ds3270.DataOut(ckAidPF14) ;
    15: Ds3270.DataOut(ckAidPF15) ;
    16: Ds3270.DataOut(ckAidPF16) ;
    17: Ds3270.DataOut(ckAidPF17) ;
    18: Ds3270.DataOut(ckAidPF18) ;
    19: Ds3270.DataOut(ckAidPF19) ;
    20: Ds3270.DataOut(ckAidPF20) ;
    21: Ds3270.DataOut(ckAidPF21) ;
    22: Ds3270.DataOut(ckAidPF22) ;
    23: Ds3270.DataOut(ckAidPF23) ;
    24: Ds3270.DataOut(ckAidPF24) ;
  else
    ShowMessage(format('Function key %d not supported.',[keyno])) ;
  end ;
end ;

procedure Tscreenf.ActionKey(keyno: integer) ;
{
  Translates the action key number to the 3270 AID and calls data out to
  send build the data stream which is then sent to the host.
}
begin
  case keyno of
    1: Ds3270.DataOutShort(ckAidPA1) ;
    2: Ds3270.DataOutShort(ckAidPA2) ;
    3: Ds3270.DataOutShort(ckAidPA3) ;
  else
    ShowMessage(format('Action key %d not supported.',[keyno])) ;
  end ;
end ;

procedure Tscreenf.SelectPS(SymbolSet: integer) ;
begin
  ShowMessage(format('Select symbol set %d not supported yet.',[SymbolSet])) ;
end ;

procedure Tscreenf.Attention ;
{
  Translates the attention key number to the PA1 AID and calls data out to
  send build the data stream which is then sent to the host.
  ** This is a simulation of attention, until I figure out how to do it
     the correct way. Its probably some telnet command.
}
begin
  Ds3270.DataOutShort(ckAidPA1) ;
end ;

procedure Tscreenf.Sysreq ;  
{
  Translates the Sysreq and Testreq key numbers to the testreq AID and
  calls data out to send build the data stream which is then sent to the host.
}
begin
  Ds3270.DataOutShort(ckAidTest) ;
end ;

procedure Tscreenf.AddChar(ch: char; numeric: boolean ) ;
{
  Adds the specified character to the display buffer at the current
  cursor location, if that location is within an unprotected field.
  If insert is on characters are shifted right before the character
  is added.
  If the input field is numeric and the numeric flag is on for the
  supplied character, then the character is not added and the -f Num
  error indicator is turned on.
  If the current location is protected, or an attribute byte, or no space
  exists for character insertion; then the -f <-> error indicator is turned
  on.
}
var
  r,c: integer ;  { temp row and col }
  ok: boolean ;   { return code }
  attr,color,hilite,cset: byte ;
begin
  if ((Byte(ScrBuf[CsrRow,CsrCol].attrib) and caProtect) <> caProtect)
    and (ScrBuf[CsrRow,CsrCol].data <> Char(cdFieldAttr)) then
    begin  { not protected attr or on attrib byte }
      if ((Byte(ScrBuf[CsrRow,CsrCol].attrib) and caNumeric) =
        caNumeric) and (not numeric) then
        LockKeyBoard('Num')
      else
        begin
          { add keyed data to display buffer }
          if insert then
            begin
              ok := ShiftRightData(CsrCol,CsrRow,c,r) ;
              if ok then
                begin
                  { add new datas attributes }
                  GetPrevFieldAttrs(CsrCol,CsrRow,attr,color,hilite,cset) ;
                  if CurCellHilite <> Char(chDefault) then
                    ScrBuf[CsrRow,CsrCol].hilite := CurCellHilite
                  else
                    ScrBuf[CsrRow,CsrCol].hilite := Char(hilite) ;
                  if CurCellColor <> Char(ccDefault) then
                    ScrBuf[CsrRow,CsrCol].color := CurCellColor
                  else
                    ScrBuf[CsrRow,CsrCol].color := Char(color) ;
                  ScrBuf[CsrRow,CsrCol].charset := Char(cset) ;
                  ScrBuf[CsrRow,CsrCol].attrib := Char(attr) ;
                  { add the data }
                  ScrBuf[CsrRow,CsrCol].data := ch ;
                  { turn on MDT - modified data tag }
                  ScrBuf[CsrRow,CsrCol].attrib :=
                    Char(Byte(ScrBuf[CsrRow,CsrCol].attrib) or caMDT) ;
                  SetPrevFieldAttr(CsrCol,CsrRow,caMDT) ;
                  { display all shifted cells }
                  DispCells(CsrCol,CsrRow,c,r,true) ;
                  { advance and draw the cursor }
                  GetNextCell(CsrCol,CsrRow) ;
                  DrawCursor(CsrCol,CsrRow) ;
                end
              else
                LockKeyBoard('<->')  ;
            end
          else
            begin
              { add new datas attributes }
              GetPrevFieldAttrs(CsrCol,CsrRow,attr,color,hilite,cset) ;
              if CurCellHilite <> Char(chDefault) then
                ScrBuf[CsrRow,CsrCol].hilite := CurCellHilite
              else
                ScrBuf[CsrRow,CsrCol].hilite := Char(hilite) ;
              if CurCellColor <> Char(ccDefault) then
                ScrBuf[CsrRow,CsrCol].color := CurCellColor
              else
                ScrBuf[CsrRow,CsrCol].color := Char(color) ;
              ScrBuf[CsrRow,CsrCol].charset := Char(cset) ;
              ScrBuf[CsrRow,CsrCol].attrib := Char(attr) ;
              { add the data }
              ScrBuf[CsrRow,CsrCol].data := ch ;
              { turn on MDT - modified data tag }
              ScrBuf[CsrRow,CsrCol].attrib :=
                Char(Byte(ScrBuf[CsrRow,CsrCol].attrib) or caMDT) ;
              SetPrevFieldAttr(CsrCol,CsrRow,caMDT) ;
              { erase old cursor }
              DispCell(CsrCol,CsrRow,true) ;
              { advance and draw the cursor }
              GetNextCell(CsrCol,CsrRow) ;
              DrawCursor(CsrCol,CsrRow) ;
            end ;
        end ;
    end    { of not protected attr }
  else
    LockKeyBoard('<->')  ;
end;

//////////////////////////////////////////////////////////////////
// Menu Control Routines
//////////////////////////////////////////////////////////////////

{ Connect }
procedure Tscreenf.RemoteSystemClick(Sender: TObject);
begin
  ConnectHost.ShowModal() ;
  if ConnectHostName <> '' then
    begin
      if socOpen then
        Disconnect ;
      MakeConnect ;
    end ;
end;

procedure Tscreenf.Disconnect1Click(Sender: TObject);
begin
  Disconnect ;
end;

procedure Tscreenf.Exit1Click(Sender: TObject);
begin  
  if socOpen then
    Disconnect ;
  screenf.Close() ;
end;

{ Edit }
procedure Tscreenf.KeyMap1Click(Sender: TObject);
begin
  KeyMap.ShowModal() ;
end;

procedure Tscreenf.ChangeFont1Click(Sender: TObject);
begin
  FontDialog1.Font.Assign(screenf.Font) ;
  FontDialog1.Execute() ;
end;

procedure Tscreenf.Clear1Click(Sender: TObject);
begin
  ClearScr ;
end;

{ Test }
procedure Tscreenf.TestOnClick(Sender: TObject);
begin
  if not Test then
    begin
      Test := true ;
      SaveBuf ;
      ClearBuf ;
      FillBuf ;
      ShowBuf ;
    end ;
end;

procedure Tscreenf.TestOffClick(Sender: TObject);
begin
  if test then
    begin
      Test := false ;
      RestoreBuf ;
      ShowBuf ;
    end ;
end;
      
procedure Tscreenf.TestFieldsOn1Click(Sender: TObject);
begin   
  if not TestFields then
    begin
      TestFields := true ;
      SaveBuf ;
      ClearBuf ;
      MakeFields ;
      ShowBuf ;
    end ;
end;

procedure Tscreenf.TestFieldsOff1Click(Sender: TObject);
begin
  if TestFields then
    begin
      TestFields := false ;
      RestoreBuf ;
      ShowBuf ;
    end ;
end;

procedure Tscreenf.Debug1Click(Sender: TObject);
begin
  if Deb then
    begin
      Deb := false ;
      Logf.Close() ;
    end 
  else
    begin
      Deb := true ;
      Logf.Show() ;
    end ;
end;

{ Help }
procedure Tscreenf.About1Click(Sender: TObject);
begin
  AboutBox.ShowModal() ;
end;

//////////////////////////////////////////////////////////////////
// Event Handling Routines
//////////////////////////////////////////////////////////////////

procedure Tscreenf.FormCreate(Sender: TObject);
var
  TxMetric: TTextMetric ;
begin
  Deb := False ;
  EorFlag := False ;
  socOpen := False ;
  Rule := False ;
  Test := False ;
  TestFields := False ;
  ExtStatus := False ;
  InitKeyTab ;
  CurCellColor := Char(ccDefault) ;
  CurCellHilite := Char(chDefault) ;
  CsrShape := csrUnderLine ;
  Canvas.Font.Size := 9 ;
  CsrRow := 1 ;
  CsrCol := 1 ;
  GetTextMetrics(Canvas.Handle,TxMetric) ;
  FontWidthPix := TxMetric.tmMaxCharWidth ;
  FontHeightPix := TxMetric.tmHeight ;
  ClientHeight := SCRROWS * FontHeightPix + (FontHeightPix+2);
  ClientWidth := SCRCOLS * FontWidthPix ;
  ClearBuf ;
  ShowBuf ;
end;

procedure Tscreenf.FormResize(Sender: TObject);
var
  TxMetric: TTextMetric ;
begin
  ClientHeight := SCRROWS * FontHeightPix + (FontHeightPix+2);
  ClientWidth := SCRCOLS * FontWidthPix ;
end;

procedure Tscreenf.FormPaint(Sender: TObject);
begin
  ShowBuf ;
end;

procedure Tscreenf.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
{
  Handles all keyboard input. Maps the keycode/shift/alt/ctrl onto
  its emulator function using the key table. Then calls that function.
}
var
  fn: integer ;          { temp counter }
begin
  { ignore the key when in test mode }
  if not test then
    begin
      { create some debug info and determine function code }
      LastKey := key ;
      LastAlt := ' ' ;
      { if key is shift, ctrl or alt }
      if (key = $10) or (key = $11) or (key = $12) then
        fn := KeyTable[key].StdCode
      else
        begin
          if ssShift in Shift then
            begin
              LastAlt := 'S' ;
              fn := KeyTable[key].ShiftCode ;
            end
          else if ssAlt in Shift then
            begin
              LastAlt := 'A' ;
              fn := KeyTable[key].AltCode ;
            end
          else if ssCtrl in Shift then
            begin
              LastAlt := 'C' ;
              fn := KeyTable[key].CtrlCode ;
            end
          else
            fn := KeyTable[key].StdCode ;
        end ;

      if KbdLocked then
        begin
          if fn = kcReset then
            Reset ;
        end
      else
        begin
          { process the function code }
          case fn of
            kcBackTab:     BackTab ;
            kcEraseToEof:  EraseEof ;
            kcNewLine:     NewLine ;
            kcForwardTab:  ForwardTab ;
            kcClearScreen: ClearScreen ;
            kcAlterCursor: AlterCursor ;
            kcCursorHome:  CursorHome ;
            kcCursorLeft:  CursorLeft(1) ;
            kcCursorRight: CursorRight(1) ;
            kcCursorDown:  CursorDown(1) ;
            kcCursorUp:    CursorUp(1) ;
            kcInsertOn:    InsertOn ;
            kcDeleteChar:  DeleteCh ;
            kcCapsOn:      CapsOn ;
            kcReset:       Reset ;
            kcCapsOff:     CapsOff ;
            kcAlt:         Nothing ;

            kcCursorLeftFast:  CursorLeft(2) ;
            kcCursorRightFast: CursorRight(2) ;
            kcCursorDownFast:  CursorDown(2) ;
            kcCursorUpFast:    CursorUp(2) ;

            kcNumber1:     AddChar('1',True) ;
            kcNumber2:     AddChar('2',True) ;
            kcNumber3:     AddChar('3',True) ;
            kcNumber4:     AddChar('4',True) ;
            kcNumber5:     AddChar('5',True) ;
            kcNumber6:     AddChar('6',True) ;
            kcNumber7:     AddChar('7',True) ;
            kcNumber8:     AddChar('8',True) ;
            kcNumber9:     AddChar('9',True) ;
            kcNumber0:     AddChar('0',True) ;

            kcSymbolRightParen: AddChar(')',False) ;
            kcExclamationMark:  AddChar('?',False) ;
            kcSymbolAt:         AddChar('@',False) ;
            kcSymbolHash:       AddChar('#',False) ;
            kcSymbolDollar:     AddChar('$',False) ;
            kcSymbolPercent:    AddChar('%',False) ;
            kcSymbolCarret:     AddChar('^',False) ;
            kcSymbolAmpersand:  AddChar('&',False) ;
            kcSymbolStar:       AddChar('*',False) ;
            kcSymbolLeftParen:  AddChar('(',False) ;

            kcSmallLetterA:   AddChar('a',False) ;
            kcCapitalLetterA: AddChar('A',False) ;
            kcSmallLetterB:   AddChar('b',False) ;
            kcCapitalLetterB: AddChar('B',False) ;
            kcSmallLetterC:   AddChar('c',False) ;
            kcCapitalLetterC: AddChar('C',False) ;
            kcSmallLetterD:   AddChar('d',False) ;
            kcCapitalLetterD: AddChar('D',False) ;
            kcSmallLetterE:   AddChar('e',False) ;
            kcCapitalLetterE: AddChar('E',False) ;
            kcSmallLetterF:   AddChar('f',False) ;
            kcCapitalLetterF: AddChar('F',False) ;
            kcSmallLetterG:   AddChar('g',False) ;
            kcCapitalLetterG: AddChar('G',False) ;
            kcSmallLetterH:   AddChar('h',False) ;
            kcCapitalLetterH: AddChar('H',False) ;
            kcSmallLetterI:   AddChar('i',False) ;
            kcCapitalLetterI: AddChar('I',False) ;
            kcSmallLetterJ:   AddChar('j',False) ;
            kcCapitalLetterJ: AddChar('J',False) ;
            kcSmallLetterK:   AddChar('k',False) ;
            kcCapitalLetterK: AddChar('K',False) ;
            kcSmallLetterL:   AddChar('l',False) ;
            kcCapitalLetterL: AddChar('L',False) ;
            kcSmallLetterM:   AddChar('m',False) ;
            kcCapitalLetterM: AddChar('M',False) ;
            kcSmallLetterN:   AddChar('n',False) ;
            kcCapitalLetterN: AddChar('N',False) ;
            kcSmallLetterO:   AddChar('o',False) ;
            kcCapitalLetterO: AddChar('O',False) ;
            kcSmallLetterP:   AddChar('p',False) ;
            kcCapitalLetterP: AddChar('P',False) ;
            kcSmallLetterQ:   AddChar('q',False) ;
            kcCapitalLetterQ: AddChar('Q',False) ;
            kcSmallLetterR:   AddChar('r',False) ;
            kcCapitalLetterR: AddChar('R',False) ;
            kcSmallLetterS:   AddChar('s',False) ;
            kcCapitalLetterS: AddChar('S',False) ;
            kcSmallLetterT:   AddChar('t',False) ;
            kcCapitalLetterT: AddChar('T',False) ;
            kcSmallLetterU:   AddChar('u',False) ;
            kcCapitalLetterU: AddChar('U',False) ;
            kcSmallLetterV:   AddChar('v',False) ;
            kcCapitalLetterV: AddChar('V',False) ;
            kcSmallLetterW:   AddChar('w',False) ;
            kcCapitalLetterW: AddChar('W',False) ;
            kcSmallLetterX:   AddChar('x',False) ;
            kcCapitalLetterX: AddChar('X',False) ;
            kcSmallLetterY:   AddChar('y',False) ;
            kcCapitalLetterY: AddChar('Y',False) ;
            kcSmallLetterZ:   AddChar('z',False) ;
            kcCapitalLetterZ: AddChar('Z',False) ;

            kcSymbolTick:             AddChar('`',False) ;
            kcSymbolTilde:            AddChar('~',False) ;
            kcSymbolMinus:            AddChar('-',False) ;
            kcSymbolUnderScore:       AddChar('_',False) ;
            kcSymbolEqual:            AddChar('=',False) ;
            kcSymbolPlus:             AddChar('+',False) ;
            kcSymbolBackSlash:        AddChar('\',False) ;
            kcSymbolBar:              AddChar('|',False) ;
            kcSymbolSlash:            AddChar('/',False) ;
            kcSymbolLeftSquareBrace:  AddChar('[',False) ;
            kcSymbolLeftCurlyBrace:   AddChar('{',False) ;
            kcSymbolRightSquareBrace: AddChar(']',False) ;
            kcSymbolRightCurlyBrace:  AddChar('}',False) ;
            kcSymbolSemiColon:        AddChar(';',False) ;
            kcSymbolColon:            AddChar(':',False) ;
            kcSymbolSingleQuote:      AddChar('''',False) ;
            kcSymbolDoubleQuote:      AddChar('"',False) ;
            kcSymbolComma:            AddChar(',',False) ;
            kcSymbolLessThan:         AddChar('<',False) ;
            kcSymbolDot:              AddChar('.',False) ;
            kcSymbolGreaterThan:      AddChar('>',False) ;
            kcSymbolQuestionMark:     AddChar('?',False) ;
            kcSymbolSpace:            AddChar(' ',False) ;

            kcEnter: FunctionKey(0);
            kcPF1:   FunctionKey(1);
            kcPF13:  FunctionKey(13);
            kcPF2:   FunctionKey(2);
            kcPF14:  FunctionKey(14);
            kcPF3:   FunctionKey(3);
            kcPF15:  FunctionKey(15);
            kcPF4:   FunctionKey(4);
            kcPF16:  FunctionKey(16);
            kcPF5:   FunctionKey(5);
            kcPF17:  FunctionKey(17);
            kcPF6:   FunctionKey(6);
            kcPF18:  FunctionKey(18);
            kcPF7:   FunctionKey(7);
            kcPF19:  FunctionKey(19);
            kcPF8:   FunctionKey(8);
            kcPF20:  FunctionKey(20);
            kcPF9:   FunctionKey(9);
            kcPF21:  FunctionKey(21);
            kcPF10:  FunctionKey(10);
            kcPF22:  FunctionKey(22);
            kcPF11:  FunctionKey(11);
            kcPF23:  FunctionKey(23);
            kcPF12:  FunctionKey(12);
            kcPF24:  FunctionKey(24);

            kcExtStatus:
              begin
                if ExtStatus then
                  ExtStatus := false
                else
                  ExtStatus := true ;
                DrawCursor(CsrCol,CsrRow) ;
              end ;

            kcColorRed:       CurCellColor := Char(ccRed) ;
            kcColorPink:      CurCellColor := Char(ccPink) ;
            kcColorGreen:     CurCellColor := Char(ccGreen) ;
            kcColorYellow:    CurCellColor := Char(ccYellow) ;
            kcColorBlue:      CurCellColor := Char(ccBlue) ;
            kcColorTurquoise: CurCellColor := Char(ccTurquoise) ;
            kcColorWhite:     CurCellColor := Char(ccWhite) ;
            kcColorDefault:   CurCellColor := Char(ccDefault) ;

            kcHiliteReverse:   CurCellHilite := Char(chReverse) ;
            kcHiliteBlink:     CurCellHilite := Char(chBlink) ;
            kcHiliteUnderLine: CurCellHilite := Char(chUnderLine) ;
            kcHiliteDefault:   CurCellHilite := Char(chDefault) ;
            
            kcPA1: ActionKey(1) ;
            kcPA2: ActionKey(2) ;
            kcPA3: ActionKey(3) ;

            kcRule:
              begin
                if Rule then
                  Rule := false
                else
                  Rule := true ;
                DrawCursor(CsrCol,CsrRow) ;
              end ;

            kcAttn:            Attention ;
            kcSysreq:          Sysreq ;
            kcSelectPSA:       SelectPS(1) ;
            kcSelectPSB:       SelectPS(2) ;
            kcSelectPSDefault: SelectPS(0) ;
          else
            LockKeyBoard('-f') ;
          end ; { of Case fn }
      end ;  { of keyboard not locked }
    end ;  { not test }
  ShowStatus ;
  key := 0 ; { handle all keys }
end ;

procedure Tscreenf.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
{
  Handles a single mouse click on the emulator screen window. The current
  cursor location is set to the cell that the mouse pointer is within.
}
begin
  if not test then
    begin
      { redraw cell that cursor inhabited }
      DispCell(CsrCol,CsrRow,true) ;
      { determine new cursor position and draw }
      CsrCol := (x+FontWidthPix) div FontWidthPix ;
      CsrRow := (y+FontHeightPix) div FontHeightPix ;
      DrawCursor(CsrCol,CsrRow) ;
      ShowStatus ;
    end ;
end ;

end.
