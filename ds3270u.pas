///////////////////////////////////////////////////////////////////////////
// Project:   Emu3270
// Program:   ds3270u.pas
// Language:  Object Pascal - Delphi ver 2.0
// Support:   David Fahey
// Date:      14Apr97
// Purpose:   To process in bound and out bound 3270 data streams.
// History:   14Apr97  Initial coding                              DAF
// Notes:     None
///////////////////////////////////////////////////////////////////////////

unit ds3270u;

interface

uses Windows, SysUtils, Classes, screenu, telnetu, utilu ;

const
  { 3270 command codes }
  IC_EAU    = $0F ;   { Erase All Unprotected }
  IC_EW     = $05 ;   { Erase Write }
  IC_EWA    = $0D ;   { Erase Write Alternate }
  IC_RB     = $02 ;   { Read Buffer }
  IC_RM     = $06 ;   { Read Modified }
  IC_W      = $01 ;   { Write }
  IC_NOP    = $03 ;   { No Opperation }
  IC_SEL    = $0B ;   { Select - 3274 B and D units only }
  IC_SELRM  = $0B ;   { Select - RM }
  IC_SELRB  = $1B ;   { Select - RB }
  IC_SELRMP = $2B ;   { Select - RMP }
  IC_SELRBP = $3B ;   { Select - RBP }
  IC_SELWRT = $4B ;   { Select - WRT }
  IC_SEN    = $04 ;   { Sense }
  IC_SENID  = $E4 ;   { Sense ID }
  IC_WSF    = $11 ;   { Write Structured Field }

  { 3270 buffer control orders }
  IO_GE     = $08 ;   { Graphic Escape }
  IO_SF     = $1D ;   { Start Field }
  IO_SBA    = $11 ;   { Set Buffer Address }
  IO_IC     = $13 ;   { Insert Cursor }
  IO_PT     = $05 ;   { Program Tab }
  IO_RA     = $3C ;   { Repeat To Address }
  IO_SFE    = $29 ;   { Start Field Extended }
  IO_EUA    = $12 ;   { Erase Unprotected to Address }
  IO_MF     = $2C ;   { Modify Field }
  IO_SA     = $28 ;   { Set Attribute }

  { data stream function type }                      
  FN_NONE   = $00 ;   { no data stream function }
  FN_CMD    = $01 ;   { command data stream function }
  FN_ORDER  = $02 ;   { order data stream function }
  FN_DATA   = $03 ;   { plain data }

type
  TDs3270 = class(TObject)
    { private data }

  private
    { Private declarations }
    procedure sba2rc(sba1,sba2: byte; var row,col: integer; adjust: integer) ; 
    procedure DoWccStart(wcc: char) ;
    procedure DoWccEnd(wcc: char) ;  
    procedure WriteData(buf: string) ;

  public
    { Public declarations }    
    procedure rc2sba(row,col: integer; var sba1,sba2: byte) ;
    procedure DataIn(buf: string) ;
    procedure DataOut(key: byte) ;   
    procedure DataOutShort(key: byte) ;

  end;

var
  Ds3270: TDs3270 ;

implementation

///////////////////////////////////////////////////////////////////////////
//  Service routines
///////////////////////////////////////////////////////////////////////////

procedure TDs3270.rc2sba(row,col: integer; var sba1,sba2: byte) ;
const
  adrmode = 12 ;
var
  offset, byte1, byte2: cardinal ;

begin
  { Convert row/column to 3270 12/16 bit buffer address. }
  offset := ((row-1) * SCRCOLS) + (col-1) ;
  if (adrmode = 12) then  { addressing mode = 12 }
    begin
      byte1 := offset shr 6 ;           { extract high order bits }
      byte1 := byte1 or $000000C0 ;     { turn on 12 bit ind }

      byte2 := offset and $0000003F ;   { extract low order 6 bits }
      byte2 := byte2 or $000000C0 ;     { turn on 12 bit ind }

      sba1 := byte1 ;  { assemble 2 byte sba - convert long to byte }
      sba2 := byte2 ;
    end
  else { adrmode = 16 or 14 }
    begin
      byte1 := offset shr 8 ;            { extract high order byte }
      byte2 := offset and $00FF ;        { extract low order byte }

      sba1 := byte1 ;  { assemble 2 byte sba - convert long to byte }
      sba2 := byte2 ;
    end ;
end ;

procedure TDs3270.sba2rc(sba1,sba2: byte; var row,col: integer; adjust: integer) ;
var
  addr: word ;                { 2 bytes - unsigned }
  taddr, offset: cardinal ;   { 4 bytes - unsigned }
begin
  { Convert 12/14/16-bit address to an offset and row/column. }

  { make contiguous sba in 2 byte word }
  addr := sba1 ;
  addr := addr shl 8 ;
  addr := addr or sba2 ;

  { If 12-bit address, then we need to massage it a little }
  if (addr and $4000) = $4000 then   { 12-bit address ? }
    begin
       addr := addr and $3F3F ;   { turn off 2 hi bits in each byte }
       taddr := addr shr 8 ;      { taddr is first 6 bits }
       addr := addr and $00FF ;   { addr is second 6 bits }
       taddr := taddr shl 6 ;     { shift taddr left and .. }
       taddr := taddr or addr ;   {   merge taddr with addr into taddr }
       offset := taddr ;          { taddr is the offset into the buffer }
    end
  else
    offset := addr ;          { addr is the offset into the buffer }

  {
    adjust: Parameter is amount to subtract (usually 0) for the returned
    cursor position, but is set to one to get correct returned buffer addresses.
  }
  offset := offset - adjust ;

  { turn offset into row and column based on device num of columns }
  col := (offset mod SCRCOLS) + 1 ;
  row := (offset div SCRCOLS) + 1 ;
end ;

///////////////////////////////////////////////////////////////////////////
//  Receive Data In From Host and Decode 3270 Data Stream
//  -- called by RecThrd unit
//  -- calls screenu unit
///////////////////////////////////////////////////////////////////////////

procedure NotImplemented(msg: string) ;
begin
  Log('WARNING: Function '+msg+' not implemented.') ;
end ;

procedure TDs3270.DoWccStart(wcc: char) ;
const
  CWCCMDT  = $01 ;  { Resets MDT bits in field attributes }
begin
   if (Byte(wcc) and CWCCMDT) = CWCCMDT then
     screenf.ResetMDT ;
end ;

procedure TDs3270.DoWccEnd(wcc: char) ;
const
  CWCCRES  = $40 ;  { Reset partition characteristics to defaults }
  CWCCALM  = $04 ;  { Sound alarm }
  CWCCKBD  = $02 ;  { Reset keyboard }
begin
   if (Byte(wcc) and CWCCRES) = CWCCRES then
     screenf.ResetDefaults ;
   if (Byte(wcc) and CWCCALM) = CWCCALM then
     beep ;
   if (Byte(wcc) and CWCCKBD) = CWCCKBD then
     screenf.Reset ;
end ;

procedure TDs3270.WriteData(buf: string) ;
  { decode data stream orders and write to screen buffer }
var
  loc: integer ;
  field: string ;
  order: byte ;
  prow, pcol: integer ;   
  erow, ecol: integer ;
  i,j,p: integer ;
  a,c,h,s: byte ;     
  saa,sac,sah,sas: byte ;
  lastDSFunc: byte ;
  icflag: boolean ;
begin
  lastDSFunc := FN_CMD ;
  prow := CsrRow ;
  pcol := CsrCol ;
  field := '' ;
  loc := 3 ;
  a := caDefault ;
  c := ccDefault ;
  h := chDefault ;
  s := csDefault ;
  saa := caDefault ;
  sac := ccDefault ;
  sah := chDefault ;
  sas := csDefault ;
  icflag := false ;
  while loc <= length(buf) do
    begin
      order := Byte(buf[loc]) ;
      case order of   { 3270 buffer control orders }   
        IO_GE:    { Graphic Escape }
          begin
            { ** just skip over this for now }
            loc := loc + 2 ;
            lastDSFunc := FN_ORDER ;
          end ;
        IO_SF:    { Start Field }
          begin
            saa := Byte(buf[loc+1]) ;
            if (Byte(buf[loc+1]) and caIntens) = caIntens then
              sac := ccWhite
            else if (Byte(buf[loc+1]) and caProtect) = caProtect then
              sac := ccBlue
            else
              sac := ccDefault ;
            screenf.StartField(prow,pcol,Byte(buf[loc+1])) ;
            screenf.GetNextCell(pcol,prow) ;
            loc := loc + 2 ;
            lastDSFunc := FN_ORDER ;
          end ;
        IO_SBA:   { Set Buffer Address }
          begin
            Sba2Rc(Byte(buf[loc+1]),Byte(buf[loc+2]),prow,pcol,0) ;
            loc := loc + 3 ;   
            lastDSFunc := FN_ORDER ;
          end ;
        IO_IC:    { Insert Cursor }
          begin
            screenf.InsertCursor(prow,pcol) ;  
            icflag := true ;
            loc := loc + 1 ; 
            lastDSFunc := FN_ORDER ;
          end ;
        IO_PT:    { Program Tab }
          begin
            if (lastDSFunc = FN_ORDER) or (lastDSFunc = FN_CMD) then
              screenf.ProgramTab(prow,pcol,false)  { tab - no erase }
            else
              screenf.ProgramTab(prow,pcol,true) ; { tab and erase }
            loc := loc + 1 ;
            lastDSFunc := FN_ORDER ;
          end ;
        IO_RA:    { Repeat To Address }
          begin
            Sba2Rc(Byte(buf[loc+1]),Byte(buf[loc+2]),erow,ecol,0) ;
            if Byte(buf[loc+3]) <> IO_GE then
              begin
                { the following changes the current addr (prow,pcol) }
                screenf.RepeatToAddress(prow,pcol,erow,ecol,
                  eb2as(Byte(buf[loc+3])),saa,sac,sah,sas) ;
                loc := loc + 4 ;
              end
            else
              loc := loc + 5 ;  { ** ignore GE for now }
            lastDSFunc := FN_ORDER ;
          end ;
        IO_SFE:   { Start Field Extended }
          begin
            p := loc + 2 ;
            j := Byte(buf[loc+1]) ;
            for i := 1 to j do
              begin
                case Byte(buf[p]) of
                  $C0:  { attribute }
                    a := Byte(buf[p+1]) ;
                  $41:  { hilite }
                    h := Byte(buf[p+1]) ;
                  $42:  { color }
                    c := Byte(buf[p+1]) ;
                  $43:  { char set }
                    s := Byte(buf[p+1]) ;
                else
                  Log(Format('Invalid SFE attr type: %.2x at: %.4x',
                    [buf[p]]) ) ;
                end ;
                p := p + 2 ;
              end ;
            screenf.StartFieldExtended(prow,pcol,a,c,h,s) ;
            screenf.GetNextCell(pcol,prow) ;
            loc := loc + 2 + (j*2) ; 
            lastDSFunc := FN_ORDER ;
          end ;
        IO_EUA:   { Erase Unprotected to Address }    
          begin
            Sba2Rc(Byte(buf[loc+1]),Byte(buf[loc+2]),erow,ecol,0) ;
            { the following changes the current addr (prow,pcol) }
            screenf.EraseUnprotectedToAddress(prow,pcol,erow,ecol) ;
            loc := loc + 4 ;            
            lastDSFunc := FN_ORDER ;
          end ;
        IO_MF:    { Modify Field }  
          begin
            p := loc + 2 ;
            j := Byte(buf[loc+1]) ;
            for i := 1 to j do
              begin
                case Byte(buf[p]) of
                  $C0:  { attribute }
                    a := Byte(buf[p+1]) ;
                  $41:  { hilite }
                    h := Byte(buf[p+1]) ;
                  $42:  { color }
                    c := Byte(buf[p+1]) ;
                  $43:  { char set }
                    s := Byte(buf[p+1]) ;
                else
                  Log(Format('Invalid MF attr type: %.2x at: %.4x',
                    [buf[p],p]) ) ;
                end ;
                p := p + 2 ;
              end ;
            screenf.ModifyField(prow,pcol,a,c,h,s) ;
            loc := loc + 2 + (j*2) ;   
            lastDSFunc := FN_ORDER ;
          end ;
        IO_SA:    { Set Attribute }
          begin
            p := loc + 2 ;
            j := Byte(buf[loc+1]) ;
            for i := 1 to j do
              begin
                case Byte(buf[p]) of
                  $C0:  { attribute }
                    saa := Byte(buf[p+1]) ;
                  $41:  { hilite }
                    sah := Byte(buf[p+1]) ;
                  $42:  { color }
                    sac := Byte(buf[p+1]) ;
                  $43:  { char set }
                    sas := Byte(buf[p+1]) ;
                else
                  Log(Format('Invalid SA attr type: %.2x at: %.4x',
                    [buf[p],p]) ) ;
                end ;
                p := p + 2 ;
              end ;
            loc := loc + 2 + (j*2) ;  
            lastDSFunc := FN_ORDER ;
          end ;
      else { not an order }
        begin   { assume its some data ?}
          if ((order >= $40) and (order <= $FE)) or (order = $00) then
            begin
              screenf.DisplayChar(prow,pcol,eb2as(Byte(buf[loc])),
                saa,sac,sah,sas) ;
              screenf.GetNextCell(pcol,prow) ;
              loc := loc + 1 ;
              lastDSFunc := FN_DATA ;
            end
          else
            begin
              Log(Format('Invalid 3270 order: %.2x at: %.4x',[order,loc]) ) ;
              loc := loc + 1 ;
              lastDSFunc := FN_NONE ;
            end ;
        end ;
      end ; { of case }
    end ;  { of while }
  if not icflag then
    begin
      CsrRow := prow ;
      CsrCol := pcol ;
    end ;
end ;

procedure TDs3270.DataIn(buf: string) ;
  { decode data stream commands and write to screen buffer }
var
  cmd: byte ;
  obuf: string ;
  ba1, ba2: byte ;
begin
  cmd := Byte(buf[1]) ;
  case cmd of
    IC_EAU: { Erase All Unprotected }
      begin
        DoWccStart(buf[2]) ;
        screenf.EraseUnprotected ;
        DoWccEnd(buf[2]) ;
        screenf.ShowBuf ;
      end ;
    IC_EW:  { Erase Write }
      begin
        DoWccStart(buf[2]) ;
        screenf.ClearScr ;
        WriteData(buf) ;
        DoWccEnd(buf[2]) ;  
        screenf.ShowBuf ;
      end ;
    IC_EWA: { Erase Write Alternate }
      begin
        DoWccStart(buf[2]) ;
        screenf.ClearScr ;
        WriteData(buf) ;
        DoWccEnd(buf[2]) ; 
        screenf.ShowBuf ;
      end ;
    IC_RB:  { Read Buffer }
      begin
        screenf.ReadBuffer(obuf) ;
        rc2sba(CsrRow,CsrCol,ba1,ba2) ;
        obuf := Char(ckAidNone) + Char(ba1) + Char(ba2) + obuf ;
        SendData(obuf) ;
      end ;
    IC_RM:  { Read Modified }
      begin
        screenf.ReadModified(obuf) ;
        rc2sba(CsrRow,CsrCol,ba1,ba2) ;
        obuf := Char(ckAidNone) + Char(ba1) + Char(ba2) + obuf ;
        SendData(obuf) ;
      end ;
    IC_W:   { Write }       
      begin
        DoWccStart(buf[2]) ;
        WriteData(buf) ;
        DoWccEnd(buf[2]) ;  
        screenf.ShowBuf ;
      end ;
    IC_NOP: { No Opperation }  
      NotImplemented('NOP') ;
    IC_WSF: { Write Structured Field }  
      NotImplemented('WSF') ;
  else
    Log(Format('Invalid 3270 command: %.2x',[cmd]) ) ;
  end ;  { of case }
end ;

///////////////////////////////////////////////////////////////////////////
//  Create 3270 Data Stream and Send Data Out To Host
//  -- called by screenu unit
//  -- calls telnetu unit
///////////////////////////////////////////////////////////////////////////

procedure TDs3270.DataOut(key: byte) ;
var
  obuf: string ;
  ba1, ba2: byte ;
begin
  screenf.ReadModified(obuf) ;
  rc2sba(CsrRow,CsrCol,ba1,ba2) ;
  obuf := Char(key) + Char(ba1) + Char(ba2) + obuf ;
  SendData(obuf) ;
end ;

procedure TDs3270.DataOutShort(key: byte) ;
begin
  SendData(Char(key)) ;
end ;

end.
