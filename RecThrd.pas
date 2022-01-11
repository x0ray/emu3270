///////////////////////////////////////////////////////////////////////////  
// Project:   Emu3270
// Program:   RecThrd.pas
// Language:  Object Pascal - Delphi ver 2.0
// Support:   David Fahey
// Date:      05Mar97
// Purpose:   To receive data from a socket and negotiate the telnet
//            protocol with the remote host.
// History:   05Mar97  Initial coding                              DAF
// Notes:     None
///////////////////////////////////////////////////////////////////////////

unit RecThrd;

interface

uses
  Windows, Winsock, Messages, SysUtils,
  Classes ;

const
  IO_BUF_SIZE = 2000 ;

  { telnet commands }
  C_NULL  = $00 ; { null = nop }
  C_SEND  = $01 ; { send }
  C_BELL  = $07 ; { ring bell }
  C_BS    = $08 ; { back space }
  C_HT    = $09 ; { horizontal tab }
  C_CR    = $0A ; { carrage return }
  C_VT    = $0B ; { vertical tab }
  C_FF    = $0C ; { form feed }
  C_LF    = $0D ; { line feed }
  C_SO    = $0E ; { shift out }
  C_SI    = $0F ; { shift in }
  C_DC1   = $11 ; { device control 1 }
  C_DC2   = $12 ; { device control 2 }
  C_DC3   = $13 ; { device control 3 }
  C_DC4   = $14 ; { device control 4 }
  C_ESC   = $1B ; { escape }

  C_EOR   = $EF ; { end of record }
  C_SE    = $F0 ; { end of sub negotiation parameters }
  C_NOP   = $F1 ; { no operation }
  C_DATMK = $F2 ; { data mark, data stream portion of synch, with TCP urgent }
  C_BRK   = $F3 ; { NVT character BRK }
  C_IP    = $F4 ; { interrupt process }
  C_AO    = $F5 ; { abort output }
  C_AYT   = $F6 ; { are you there }
  C_EC    = $F7 ; { erase character }
  C_EL    = $F8 ; { erase line }
  C_GA    = $F9 ; { go ahead signal }
  C_SB    = $FA ; { indicates following is sub negotiation of func }

  C_WILL  = $FB ; { indicate desire to begin func, or confirm performing func }
  C_WONT  = $FC ; { indicate refusal to perform func, or continue performing }
  C_DO    = $FD ; { request other party perform func, or confirm expectation }
  C_DONT  = $FE ; { demand other party stop func, or confirm other stopped func }

  IAC     = $FF ; { telnet escape character }

  { telnet options/functions }
  TOPT_BIN    = { Binary Transmission }                $00 ;
  TOPT_ECHO   = { Echo }                               $01 ;
  TOPT_RECN   = { Reconnection }                       $02 ;
  TOPT_SUPP   = { Suppress Go Ahead }                  $03 ;
  TOPT_APRX   = { Approx Message Size Negotiation }    $04 ;
  TOPT_STAT   = { Status }                             $05 ;
  TOPT_TIM    = { Timing Mark }                        $06 ;
  TOPT_REM    = { Remote Controlled Trans and Echo }   $07 ;
  TOPT_OLW    = { Output Line Width }                  $08 ;
  TOPT_OPS    = { Output Page Size }                   $09 ;
  TOPT_OCRD   = { Output Carriage-Return Disposition } $0A ;
  TOPT_OHT    = { Output Horizontal Tabstops }         $0B ;
  TOPT_OHTD   = { Output Horizontal Tab Disposition }  $0C ;
  TOPT_OFD    = { Output Formfeed Disposition }        $0D ;
  TOPT_OVT    = { Output Vertical Tabstops }           $0E ;
  TOPT_OVTD   = { Output Vertical Tab Disposition }    $0F ;
  TOPT_OLD    = { Output Linefeed Disposition }        $10 ;
  TOPT_EXT    = { Extended ASCII }                     $11 ;
  TOPT_LOGO   = { Logout }                             $12 ;
  TOPT_BYTE   = { Byte Macro }                         $13 ;
  TOPT_DATA   = { Data Entry Terminal }                $14 ;
  TOPT_SUP    = { SUPDUP }                             $15 ;
  TOPT_SUPO   = { SUPDUP Output }                      $16 ;
  TOPT_SNDL   = { Send Location }                      $17 ;
  TOPT_TERM   = { Terminal Type }                      $18 ;
  TOPT_EOR    = { End of Record }                      $19 ;
  TOPT_TACACS = { TACACS User Identification }         $1A ;
  TOPT_OM     = { Output Marking }                     $1B ;
  TOPT_TLN    = { Terminal Location Number }           $1C ;
  TOPT_3270   = { Telnet 3270 Regime }                 $1D ;
  TOPT_X3     = { X.3 PAD }                            $1E ;
  TOPT_NAWS   = { Negotiate About Window Size }        $1F ;
  TOPT_TS     = { Terminal Speed }                     $20 ;
  TOPT_RFC    = { Remote Flow Control }                $21 ;
  TOPT_LINE   = { Linemode }                           $22 ;
  TOPT_XDL    = { X Display Location }                 $23 ;
  TOPT_ENV1   = { Telnet Environment Option }          $24 ;
  TOPT_AUTH   = { Telnet Authentication Option }       $25 ;
  TOPT_ENV2   = { Telnet Environment Option }          $27 ;
  TOPT_EXTOP  = { Extended-Options-List }              $FF ;


type
  RecvThrd = class(TThread)
  private
    IOSocket: TSocket ;
    { Private declarations }
  protected   
    procedure Log(str: string) ;
    procedure DumpChar(ch: char) ; 
    procedure DumpFlush ;
    procedure DispChar(ch: byte) ;
    procedure LogDisp ;
    procedure Display ;
    procedure Execute; override;
  public
    constructor Create(ios: TSocket) ;
  end;

  TBuf = array[0..IO_BUF_SIZE] of char ;

threadvar
  s: string[16] ;
  numchars: integer ;
  bytecnt: integer ;

implementation

uses
  Screenu ,Telnetu, Logu, utilu, ds3270u ;

///////////////////////////////////////////////////////////////////////////
//  Service routines
///////////////////////////////////////////////////////////////////////////

function TCmd(ch: byte): string ;
begin
  case ch of
    IAC:     TCmd := 'IAC' ; 
    C_EOR:   TCmd := 'EOR' ;
    C_WILL:  TCmd := 'WILL' ;
    C_WONT:  TCmd := 'WONT' ;
    C_DO:    TCmd := 'DO' ;
    C_DONT:  TCmd := 'DONT' ;
    C_NOP:   TCmd := 'NOP' ;
    C_EL:    TCmd := 'EL' ;
    C_EC:    TCmd := 'EC' ;
    C_LF:    TCmd := 'LF' ;
    C_CR:    TCmd := 'CR' ;
    C_SB:    TCmd := 'SB' ;
    C_SE:    TCmd := 'SE' ;
    C_DATMK: TCmd := 'DATMK' ;  
    C_BRK:   TCmd := 'BRK' ;  
    C_IP:    TCmd := 'IP' ;   
    C_AO:    TCmd := 'AO' ;
  else
    TCmd := 'CmdUnknown' ;
  end ;
end ;

function TFunc(ch: byte): string ;
begin
  case ch of
    TOPT_BIN:    TFunc := 'Binary Transmission' ;
    TOPT_ECHO:   TFunc := 'Echo' ;
    TOPT_RECN:   TFunc := 'Reconnection' ;
    TOPT_SUPP:   TFunc := 'Suppress Go Ahead' ;
    TOPT_APRX:   TFunc := 'Approx Message Size Negotiation' ;
    TOPT_STAT:   TFunc := 'Status' ;
    TOPT_TIM:    TFunc := 'Timing Mark' ;
    TOPT_REM:    TFunc := 'Remote Controlled Trans and Echo' ;
    TOPT_OLW:    TFunc := 'Output Line Width' ;
    TOPT_OPS:    TFunc := 'Output Page Size' ;
    TOPT_OCRD:   TFunc := 'Output Carriage-Return Disposition' ;
    TOPT_OHT:    TFunc := 'Output Horizontal Tabstops' ;
    TOPT_OHTD:   TFunc := 'Output Horizontal Tab Disposition' ;
    TOPT_OFD:    TFunc := 'Output Formfeed Disposition' ;
    TOPT_OVT:    TFunc := 'Output Vertical Tabstops' ;
    TOPT_OVTD:   TFunc := 'Output Vertical Tab Disposition' ;
    TOPT_OLD:    TFunc := 'Output Linefeed Disposition' ;
    TOPT_EXT:    TFunc := 'Extended ASCII' ;
    TOPT_LOGO:   TFunc := 'Logout' ;
    TOPT_BYTE:   TFunc := 'Byte Macro' ;
    TOPT_DATA:   TFunc := 'Data Entry Terminal' ;
    TOPT_SUP:    TFunc := 'SUPDUP' ;
    TOPT_SUPO:   TFunc := 'SUPDUP Output' ;
    TOPT_SNDL:   TFunc := 'Send Location' ;
    TOPT_TERM:   TFunc := 'Terminal Type' ;
    TOPT_EOR:    TFunc := 'End of Record' ;
    TOPT_TACACS: TFunc := 'TACACS User Identification' ;
    TOPT_OM:     TFunc := 'Output Marking' ;
    TOPT_TLN:    TFunc := 'Terminal Location Number' ;
    TOPT_3270:   TFunc := 'Telnet 3270 Regime' ;
    TOPT_X3:     TFunc := 'X.3 PAD' ;
    TOPT_NAWS:   TFunc := 'Negotiate About Window Size' ;
    TOPT_TS:     TFunc := 'Terminal Speed' ;
    TOPT_RFC:    TFunc := 'Remote Flow Control' ;
    TOPT_LINE:   TFunc := 'Linemode' ;
    TOPT_XDL:    TFunc := 'X Display Location' ;
    TOPT_ENV1:   TFunc := 'Telnet Environment Option' ;
    TOPT_AUTH:   TFunc := 'Telnet Authentication Option' ;
    TOPT_ENV2:   TFunc := 'Telnet Environment Option' ;
    TOPT_EXTOP:  TFunc := 'Extended-Options-List' ;
  else
    TFunc := 'FuncUnknown' ;
  end ;
end ;


///////////////////////////////////////////////////////////////////////////
//  Main thread object routines
///////////////////////////////////////////////////////////////////////////

procedure RecvThrd.LogDisp ;  { routine runs as part of the main thread }
begin
  Logf.Memo1.Lines.Add(LogLine) ;
end;

procedure RecvThrd.Log(str: string) ;
begin
  LogLine := str ;
  Synchronize(LogDisp) ;
end;

procedure RecvThrd.DumpChar(ch: char) ;
var
  sf: string ;
  ic: integer ;
  i: integer ;
  e: char ;
begin
  numchars := numchars + 1 ;
  s[numchars] := ch ;
  { format and add line to display area }
  if numchars = 16 then
    begin
      sf := format('%6.6x  ',[bytecnt]) ;
      for i := 1 to 16 do
        begin
          ic := ord(s[i]) ;
          sf := sf+Format('%2.2x ',[ic]) ;
        end ;
      sf := sf+'  *' ;
      for i := 1 to 16 do
        begin
          if (ord(s[i]) >= 32) and (ord(s[i]) < 127) then
            sf := sf+s[i]
          else
            sf := sf+'.' ;
        end ;
      sf := sf+'*  *' ;
      for i := 1 to 16 do
        begin
          e := Char(eb2as(Byte(s[i]))) ;
          if (ord(e) >= 32) and (ord(e) < 127) then
            sf := sf+e
          else
            sf := sf+'.' ;
        end ;
      sf := sf+'*' ;
      Log(sf) ; { Put string in memo area }
      bytecnt := bytecnt + numchars ;
      numchars := 0 ;
      for i := 1 to 16 do
        s[i] := chr(0) ;
    end ;
end ;

procedure RecvThrd.DumpFlush ;
var
  sf: string ;
  ic: integer ;
  i: integer ;
  e: char ;
begin
  if numchars > 0 then
    begin
      sf := format('%6.6x  ',[bytecnt]) ;
      for i := 1 to 16 do
        begin
          ic := ord(s[i]) ;
          sf := sf+Format('%2.2x ',[ic]) ;
        end ;
      sf := sf+'  *' ;
      for i := 1 to 16 do
        begin
          if (ord(S[I]) >= 32) and (ord(s[i]) < 127) then
            sf := sf+s[i]
          else
            sf := sf+'.' ;
        end ;    
      sf := sf+'*  *' ;
      for i := 1 to 16 do
        begin
          e := Char(eb2as(Byte(s[i]))) ;
          if (ord(e) >= 32) and (ord(e) < 127) then
            sf := sf+e
          else
            sf := sf+'.' ;
        end ;
      sf := sf+'*' ;
      Log(sf) ;  { Put string in memo area }
    end ;  {of if numchars > 0 }
  numchars := 0 ;
  bytecnt := 0 ;
  for i := 1 to 16 do
    s[i] := chr(0) ;
end ;

constructor RecvThrd.Create(ios: TSocket) ;
var
  i: integer ;
begin
  FreeOnTerminate := True ;
  IOSocket := ios ;
  numchars := 0 ;
  for i := 1 to 16 do
    s[i] := chr(0) ;
  inherited Create(False) ;  { dont run thread yet }
end ;

procedure RecvThrd.DispChar(ch: byte) ;
begin
  OutChar := ch ;
  Synchronize(Display) ;
end ;

procedure RecvThrd.Display ; { routine runs as part of the main thread }
var
  dummy: integer ;
begin
  case OutChar of
    C_LF:               { line feed }
      begin
        Logf.Memo1.Lines.Add(OutLine) ;
        OutLine := '' ;
      end ;
    C_BS:               { back space }
      begin
        SetLength(OutLine,Length(OutLine)-1) ;
      end ;
    C_BELL: beep() ;       { ring bell }
    C_CR:   Dummy := 0  ;  { carrage return - do nothing }
    C_NULL: Dummy := 0  ;  { null - do nothing }
    C_HT:   Dummy := 0  ;  { horizontal tab - do nothing }
    C_VT:   Dummy := 0  ;  { vertical tab - do nothing }
    C_DC1:  Dummy := 0  ;  { device control - do nothing }
    C_DC2:  Dummy := 0  ;  { device control - do nothing }
    C_DC3:  Dummy := 0  ;  { device control - do nothing }
    C_DC4:  Dummy := 0  ;  { device control - do nothing }
    C_ESC:  Dummy := 0  ;  { escape - do nothing }
  else
    OutLine := OutLine + Char(OutChar) ;
  end ;
  { Logf.LastLine.Caption := OutLine ;  }
end;

procedure RecvThrd.Execute ;
{
     wait for in_buffer data
     recv in_buffer
     while datalen > 0
       if datatype = telnet
         select telnet command
           do: out_buffer = telnet_response
               increment out_buffer
               increment out_datalen
               increment in_buffer
               decremet datalen
           dont: ...
           will: ...
           wont: ...

       else datatype = application
         format and display
         increment in_buffer
         decremet datalen

       if datalen = 0
         if out_datalen > 0
           send out_buffer
         wait for in_buffer data
         recv in_buffer
     end_while
}
type
  PTelCmd = ^TTelCmd ;
  TTelCmd = packed record
    c_iac: Byte ;
    c_cmd: Byte ;
    c_func: Byte ;
  end ;
  PTelTermCmd = ^TTelTermCmd ;
  TTelTermCmd = packed record
    c_iac:  Byte ;
    c_sb:   Byte ;
    c_term: Byte ;
    c_is:   Byte ;
    c_type: array[1..10] of char ;
    c_iace: Byte ;
    c_se:   Byte ;
  end ;

var
  InDataLen: integer ;
  OutDataLen: integer ;
  err: integer ;
  size: integer ;
  pc: PChar ;
  i: integer ;
  pInTcmd: PTelCmd ;
  pOutTcmd: PTelCmd ;   
  pOutTermTcmd: PTelTermCmd ;
  outstr: string ;
  InBuffer: TBuf ;
  OutBuffer: TBuf ;
  AmmountWaiting: u_long ;
  WaitMilliSecs: integer ;
begin   
  outstr := '' ;
  RecThreadRunning := true ;
  if deb then
    begin
      Log('Receive thread started.') ;
      WaitMilliSecs := 250 ;  { so display is not overloaded }
    end
  else 
    WaitMilliSecs := 250 ;
  
  { wait for some data on the socket }
  AmmountWaiting := 0 ;
  while AmmountWaiting = 0 do
    begin
      err := ioctlsocket(IOSocket,FIONREAD,AmmountWaiting) ;
      if err = SOCKET_ERROR then
        Log('IOctlsocket error: '
          +Format('%d',[WSAGetLastError()]))
      else
        if deb then Log('Input queue length: '
          +Format('%d',[AmmountWaiting])) ;  
      if AmmountWaiting = 0 then
        Sleep(WaitMilliSecs) ;
      if Terminated then
        break ;
    end ;

  size := SizeOf(InBuffer) ;
  pc := @InBuffer ;
  err := recv(IOSocket,InBuffer,size,0) ;
  if err = SOCKET_ERROR then
    Log('Recv error: '+Format('%d',[WSAGetLastError()]))
  else
    begin  { recv OK }
      InDataLen := err ;
      if deb then
        begin
          Log('Recv: '+Format(' (%d)',[InDataLen])) ;
          for i:=0 to (InDataLen-1) do
            DumpChar(InBuffer[i]) ;
          DumpFlush ;
        end ;

      { check for telnet commands and reply to them }
      OutDataLen := 0 ;
      pInTcmd := Pointer(@InBuffer) ;
      pOutTcmd := Pointer(@OutBuffer) ;
      while InDataLen > 0 do
        begin
          if (pInTcmd^.c_iac = IAC) and (pInTcmd^.c_cmd <> $FF) then
            begin  { Telnet command(s) }   
              if pInTcmd^.c_cmd = C_EOR then   { IAC EOR }
                begin
                  if deb then
                    Log('In: IAC '+TCmd(pInTcmd^.c_cmd)) ;
                  pInTcmd := Pointer(PChar(pInTcmd) + 2) ;
                  InDataLen := InDataLen - 2 ;   
                  if length(outstr) > 0 then  { got some 3270 data stream ? }
                    begin    
                      Log('DS Out: '+Format('%d',[length(outstr)])) ;
                      { end of record indicator - process data early }
                      Ds3270.DataIn(outstr) ;
                      outstr := '' ;
                    end ;  
                end
              else if pInTcmd^.c_cmd = C_DO then   { IAC DO xx }
                begin
                  if deb then
                    Log('In: IAC '+TCmd(pInTcmd^.c_cmd)
                      +' '+TFunc(pInTcmd^.c_func)) ;
                  pOutTcmd^.c_iac := IAC ;
                  if (pInTcmd^.c_func = TOPT_TERM) or
                     (pInTcmd^.c_func = TOPT_BIN) or
                     (pInTcmd^.c_func = TOPT_EOR) then
                    begin
                      if (pInTcmd^.c_func = TOPT_EOR) then
                        EorFlag := True ;
                      pOutTcmd^.c_cmd := C_WILL ;
                    end
                  else
                    pOutTcmd^.c_cmd := C_WONT ;
                  pOutTcmd^.c_func := pInTcmd^.c_func ;
                  if deb then
                    Log('Out: IAC '+TCmd(pOutTcmd^.c_cmd)
                      +' '+TFunc(pOutTcmd^.c_func)) ;
                  pOutTcmd := Pointer(PChar(pOutTcmd) + 3) ;
                  OutDataLen := OutDataLen  + 3 ;
                  pInTcmd := Pointer(PChar(pInTcmd) + 3) ;
                  InDataLen := InDataLen - 3 ;
                end
              else if pInTcmd^.c_cmd = C_DONT then   { IAC DONT xx }
                begin
                  if deb then
                    Log('In: IAC '+TCmd(pInTcmd^.c_cmd)
                      +' '+TFunc(pInTcmd^.c_func)) ; 
                  if (pInTcmd^.c_func = TOPT_EOR) then
                    EorFlag := False ;
                  pOutTcmd^.c_iac := IAC ;
                  pOutTcmd^.c_cmd := C_WONT ;
                  pOutTcmd^.c_func := pInTcmd^.c_func ;
                  if deb then
                    Log('Out: IAC '+TCmd(pOutTcmd^.c_cmd)
                      +' '+TFunc(pOutTcmd^.c_func)) ;
                  pOutTcmd := Pointer(PChar(pOutTcmd) + 3) ;
                  OutDataLen := OutDataLen  + 3 ;
                  pInTcmd := Pointer(PChar(pInTcmd) + 3) ;
                  InDataLen := InDataLen - 3 ;
                end
              else if pInTcmd^.c_cmd = C_WILL then   { IAC WILL xx }
                begin
                  if deb then
                    Log('In: IAC '+TCmd(pInTcmd^.c_cmd)
                      +' '+TFunc(pInTcmd^.c_func)) ;
                  pOutTcmd^.c_iac := IAC ;
                  if (pInTcmd^.c_func = TOPT_TERM) or
                     (pInTcmd^.c_func = TOPT_BIN) or
                     (pInTcmd^.c_func = TOPT_EOR) then
                    pOutTcmd^.c_cmd := C_DO
                  else
                    pOutTcmd^.c_cmd := C_DONT ;
                  pOutTcmd^.c_func := pInTcmd^.c_func ;
                  if deb then
                    Log('Out: IAC '+TCmd(pOutTcmd^.c_cmd)
                      +' '+TFunc(pOutTcmd^.c_func)) ;
                  pOutTcmd := Pointer(PChar(pOutTcmd) + 3) ;
                  OutDataLen := OutDataLen  + 3 ;
                  pInTcmd := Pointer(PChar(pInTcmd) + 3) ;
                  InDataLen := InDataLen - 3 ;
                end
              else if pInTcmd^.c_cmd = C_WONT then   { IAC WONT xx }
                begin
                  if deb then
                    Log('In: IAC '+TCmd(pInTcmd^.c_cmd)
                      +' '+TFunc(pInTcmd^.c_func)) ;
                  pInTcmd := Pointer(PChar(pInTcmd) + 3) ;
                  InDataLen := InDataLen - 3 ;
                end
              else if pInTcmd^.c_cmd = C_SB then   { IAC SB xx ... }
                begin
                  if (pInTcmd^.c_func = TOPT_TERM) then
                    begin                          { IAC SB TERM-TYPE SEND }
                      if deb then
                        Log('In: IAC '+TCmd(pInTcmd^.c_cmd)
                          +' '+TFunc(pInTcmd^.c_func)+' SEND') ;
                      pOutTermTcmd := Pointer(pOutTcmd) ;

                      pOutTermTcmd^.c_iac := IAC ;
                      pOutTermTcmd^.c_sb := C_SB ;
                      pOutTermTcmd^.c_term := TOPT_TERM ;
                      pOutTermTcmd^.c_is := C_NULL ;
                      pOutTermTcmd^.c_type := 'IBM-3278-3' ;
                      pOutTermTcmd^.c_iace := IAC ;
                      pOutTermTcmd^.c_se := C_SE ;

                      pOutTcmd := Pointer(PChar(pOutTcmd) + 16) ;
                      OutDataLen := OutDataLen  + 16 ;
                      pInTcmd := Pointer(PChar(pInTcmd) + 4) ;
                      InDataLen := InDataLen - 4 ;
                      if deb then
                        begin
                          Log('Out: IAC '+TCmd(pOutTermTcmd^.c_sb)
                            +' '+TFunc(pOutTermTcmd^.c_term)+' IS '
                            +pOutTermTcmd^.c_type) ;
                          Log('Out: IAC '+TCmd(pOutTermTcmd^.c_se) ) ;
                        end ;
                    end
                  else
                    begin
                      if deb then
                        Log('In: IAC '+TCmd(pInTcmd^.c_cmd)
                          +' '+TFunc(pInTcmd^.c_func)) ;
                      pInTcmd := Pointer(PChar(pInTcmd) + 3) ;
                      InDataLen := InDataLen - 3 ;
                    end ;
                end
              else if pInTcmd^.c_cmd = C_SE then   { IAC SE }
                begin
                  if deb then
                    Log('In: IAC '+TCmd(pInTcmd^.c_cmd)) ;
                  pInTcmd := Pointer(PChar(pInTcmd) + 2) ;
                  InDataLen := InDataLen - 2 ;
                end
              else if pInTcmd^.c_cmd = C_NOP then   { IAC NOP }
                begin
                  if deb then
                    Log('In: IAC '+TCmd(pInTcmd^.c_cmd)) ;
                  pInTcmd := Pointer(PChar(pInTcmd) + 2) ;
                  InDataLen := InDataLen - 2 ;
                end
              else if pInTcmd^.c_cmd = C_EL then   { IAC EL }
                begin
                  if deb then
                    Log('In: IAC '+TCmd(pInTcmd^.c_cmd)) ;
                  pInTcmd := Pointer(PChar(pInTcmd) + 2) ;
                  InDataLen := InDataLen - 2 ;
                end
              else if pInTcmd^.c_cmd = C_EC then   { IAC EC }
                begin
                  if deb then
                    Log('In: IAC '+TCmd(pInTcmd^.c_cmd)) ;
                  pInTcmd := Pointer(PChar(pInTcmd) + 2) ;
                  InDataLen := InDataLen - 2 ;
                end ;
            end

          else
            begin  { Application data }
              while InDataLen > 0 do
                begin
                  if (pInTcmd^.c_iac = IAC) and (pInTcmd^.c_cmd = $FF) then
                    begin   { telnet escaped FF character - just keep 1 }
                      outstr := outstr + Char($FF) ;
                      InDataLen := InDataLen - 2 ;
                      pInTcmd := Pointer(PChar(pInTcmd) + 2) ;
                    end
                  else if (pInTcmd^.c_iac = IAC) then
                    break   { imbedded telnet sequence }
                  else
                    begin   { 3270 data stream char - stash it }
                      outstr := outstr + Char(pInTcmd^.c_iac) ;
                      InDataLen := InDataLen - 1 ;
                      pInTcmd := Pointer(PChar(pInTcmd) + 1) ;
                    end ;
                end ;
            end ;

          if InDataLen = 0 then
            begin
              err := ioctlsocket(IOSocket,FIONREAD,AmmountWaiting) ;
              if err = SOCKET_ERROR then
                Log('IOctlsocket error: '
                  +Format('%d',[WSAGetLastError()]))
              else
                if deb and (AmmountWaiting > 0) then
                  Log('Input queue length: '+Format('%d',[AmmountWaiting])) ;

              if OutDataLen > 0 then
                begin  { send some telnet command responses }
                  pOutTcmd^.c_iac := $00 ; { mark end of out buffer }
                  { send output buffer }
                  err := send(IOSocket,OutBuffer,OutDataLen,0) ;
                  if err = SOCKET_ERROR then
                    Log('Send IAC error: '+Format('%d',[WSAGetLastError()])) ;

                  if deb then
                    begin
                      Log('Send: '+Format(' (%d)',[OutDataLen])) ;
                      for i:=0 to (OutDataLen-1) do
                        DumpChar(OutBuffer[i]) ;
                      DumpFlush ;
                    end ;

                  pOutTcmd := Pointer(@OutBuffer) ;
                  OutDataLen := 0 ;
                end ;

              { wait for some data on the socket }
              AmmountWaiting := 0 ;
              while AmmountWaiting = 0 do
                begin
                  err := ioctlsocket(IOSocket,FIONREAD,AmmountWaiting) ;
                  if err = SOCKET_ERROR then
                    Log('IOctlsocket error: '
                      +Format('%d',[WSAGetLastError()]))
                  else
                    if deb and (AmmountWaiting > 0) then
                      Log('Input queue length: '+Format('%d',[AmmountWaiting])) ;
                  if AmmountWaiting = 0 then
                    Sleep(WaitMilliSecs) ;
                  if Terminated then
                    break ;
                end ;

              { get response message from server }
              if not Terminated then
                begin
                  size := SizeOf(InBuffer) ;
                  err := recv(IOSocket,InBuffer,size,0) ;
                  if err = SOCKET_ERROR then
                    Log('Recv IAC error: '
                      +Format('%d',[WSAGetLastError()])) ;
                  pInTcmd := Pointer(@InBuffer) ;
                  InDataLen := err ;

                  if deb then
                    begin
                      Log('Recv: '+Format(' (%d)',[err])) ;
                      for i:=0 to (err-1) do
                        DumpChar(InBuffer[i]) ;
                      DumpFlush ;
                    end ;
                end ;
            end ;   { of send some telnet command responses }

          if Terminated then
            break ;
        end ;  { of while datalen > 0 }

    end ;  { of recv OK }
  RecThreadRunning := false ;
end;

end.
