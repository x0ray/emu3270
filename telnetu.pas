///////////////////////////////////////////////////////////////////////////
// Project:   Emu3270
// Program:   telnetu.pas
// Language:  Object Pascal - Delphi ver 2.0
// Support:   David Fahey
// Date:      05Mar97
// Purpose:   To establish a telnet session with a user specified
//            machine name.
// History:   05Mar97  Initial coding                              DAF
// Notes:     The telnet unit works in conjunction with the RwecThrd unit
//            to establish communications to the host system. Telnetu
//            interacts with windows and establishes the
//            connection with the remote host. It also sends user
//            input to the remote host. The RecThrd unit is started
//            by the telnetu unit to receive messages from the
//            remote host, and process any telnet commands that it
//            receives. Any application data that is received by the
//            RecThrd thread is passed on to the ds3270 unit for decoding.
//            RecThrd does not block the input socket, instead it uses the
//            ioctlsocket command FIONREAD to determine if any
//            data is available to read.
//
// End.
///////////////////////////////////////////////////////////////////////////

unit telnetu;

interface

uses
  Windows, Winsock, Messages, SysUtils,
  Classes, RecThrd ;

procedure TcpStartup ;
procedure TcpCleanup ;
procedure Log(str: string) ;
procedure Disconnect ;
procedure SendData(sdata: string) ;
procedure MakeConnect ;

implementation

uses
  Screenu, Logu, utilu ;

///////////////////////////////////////////////////////////////////////////
//  Service routines
///////////////////////////////////////////////////////////////////////////

procedure  TcpStartup ;
var
  err: integer ;
  VersionReq: word ;
  wsaData: TWSAData ;
begin
  VersionReq := $0101 ;
  err := WSAStartup(VersionReq,wsaData) ;
end ;

procedure TcpCleanup ;
var
  err: integer ;
begin
  err := WSACancelBlockingCall() ;
  err := WSACleanup() ;
end ;

procedure Log(str: string) ;
begin
   logf.Memo1.Lines.Add(str) ;
end ;

procedure DumpChar(ch: char) ;
var
  sf: string ;
  ic: integer ;
  i: integer ;
  e: char ;
begin
  {
  DumpStr: string[16]  - global var defined in screenu
  DumpNum: integer     - global var defined in screenu
  DumpBytes: integer   - global var defined in screenu
  }
  DumpNum := DumpNum + 1 ;
  DumpStr[DumpNum] := ch ;
  { format and add line to display area }
  if DumpNum = 16 then
    begin
      sf := format('%6.6x  ',[DumpBytes]) ;
      for i := 1 to 16 do
        begin
          ic := ord(DumpStr[i]) ;
          sf := sf+Format('%2.2x ',[ic]) ;
        end ;
      sf := sf+'  *' ;
      for i := 1 to 16 do
        begin
          if (ord(DumpStr[i]) >= 32) and (ord(DumpStr[i]) < 127) then
            sf := sf+DumpStr[i]
          else
            sf := sf+'.' ;
        end ;
      sf := sf+'*  *' ;
      for i := 1 to 16 do
        begin
          e := Char(eb2as(Byte(DumpStr[i]))) ;
          if (ord(e) >= 32) and (ord(e) < 127) then
            sf := sf+e
          else
            sf := sf+'.' ;
        end ;
      sf := sf+'*' ;
      Log(sf) ; { Put string in memo area }
      DumpBytes := DumpBytes + DumpNum ;
      DumpNum := 0 ;
      for i := 1 to 16 do
        DumpStr[i] := chr(0) ;
    end ;
end ;

procedure DumpFlush ;
var
  sf: string ;
  ic: integer ;
  i: integer ;
  e: char ;
begin    
  {
  DumpStr: string[16]  - global var defined in screenu
  DumpNum: integer     - global var defined in screenu
  DumpBytes: integer   - global var defined in screenu
  }
  if DumpNum > 0 then
    begin
      sf := format('%6.6x  ',[DumpBytes]) ;
      for i := 1 to 16 do
        begin
          ic := ord(DumpStr[i]) ;
          sf := sf+Format('%2.2x ',[ic]) ;
        end ;
      sf := sf+'  *' ;
      for i := 1 to 16 do
        begin
          if (ord(DumpStr[I]) >= 32) and (ord(DumpStr[i]) < 127) then
            sf := sf+DumpStr[i]
          else
            sf := sf+'.' ;
        end ;    
      sf := sf+'*  *' ;
      for i := 1 to 16 do
        begin
          e := Char(eb2as(Byte(DumpStr[i]))) ;
          if (ord(e) >= 32) and (ord(e) < 127) then
            sf := sf+e
          else
            sf := sf+'.' ;
        end ;
      sf := sf+'*' ;
      Log(sf) ;  { Put string in memo area }
    end ;  {of if numchars > 0 }
  DumpNum := 0 ;
  DumpBytes := 0 ;
  for i := 1 to 16 do
    DumpStr[i] := chr(0) ;
end ;

procedure Disconnect ;
begin
  if RecThreadRunning then
    RecThread.Terminate() ;
  if socOpen then
    begin
      closesocket(soc) ;
      socOpen := false ;
    end ;
  TcpCleanup() ;
  if deb then
    Log('TCP Ended.') ;
end;

procedure SendData(sdata: string) ;
const
  C_CR    = $0A ; { carrage return }
  C_LF    = $0D ; { line feed }
type
  TOutBuf = array[0..255] of char ;
var
  err: integer ;
  size: integer ;
  pc: PChar ;
  OutBuffer: TOutBuf ;
  i: integer ;
begin                 
  if EorFlag then
    sdata := sdata + Char(IAC) + Char(C_EOR) ;
  pc := @OutBuffer ;   
  StrPCopy(pc,sdata) ;
  size := Length(sdata) ;
  err := send(soc,OutBuffer,size,0) ;
  if err = SOCKET_ERROR then
    Log('Send error: '
      +Format('%d',[WSAGetLastError()]))
  else
    begin
      if deb then
        begin
          Log('Send: '+Format(' (%d)',[size])) ;
          for i:=0 to (size-1) do
            DumpChar(OutBuffer[i]) ;
          DumpFlush ;
        end ;
    end ;
end;

procedure MakeConnect ;
type
  TPint = ^Longint ;
var
  err: integer ;
  phost: PHostEnt ;
  ina: TInAddr ;
  lina: TInAddr ;
  pint: TPint ;
  RemoteHostName: TPath ;
  PRemoteHostName: PChar ;
  LocalHostName: TPath ;
  PLocalHostName: PChar ;
  LocalAddr: TSockAddrIn ;
  psaddr: PSockAddr ;
  RemoteAddr: TSockAddrIn ;
  pServAddr: PServEnt ;
  usPort: u_short ;
  InitCmd: string ;
  NonBlocked: u_long ;
begin
  TcpStartup() ;
  if deb then
    Log('TCP Started.') ;
  soc := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP) ;
  if soc = INVALID_SOCKET then
    begin
      Log('Error socket invalid.') ;
      socOpen := False ;
    end
  else
    begin
      if deb then
        Log('Socket opened OK.') ;
      socOpen := True ;
    end ;

  { get foreign host name and addr }
  PRemoteHostName := @RemoteHostName ;
  StrPCopy(PRemoteHostName,ConnectHostName) ;
  phost := gethostbyname(PRemoteHostName) ;
  if phost = nil then
    begin
      Log('Error, failed to find host.') ;
      Disconnect ;
    end
  else
    begin
      if deb then
        begin
          Log('Foreign host name: '
            +PChar(phost^.h_name)) ;
          Log('    Address type: '
            +format('%x',[phost^.h_addrtype])) ;
          Log('    Address length: '
            +format('%d',[phost^.h_length])) ;
        end ;
      pint := Pointer(phost^.h_addr_list^) ;
      ina.s_addr := pint^ ;
      if deb then
        Log('    Foreign host address: '
          +PChar(inet_ntoa(ina))) ;

      { get local host name and addr }
      PLocalHostName := @LocalHostName ;
      if gethostname(PLocalHostName,MAX_PATH) <> SOCKET_ERROR then
        begin
          phost := gethostbyname(PLocalHostName) ;
          if phost = nil then
            begin
              Log('Error, failed to find local host.') ;
              Disconnect ;
            end
          else
            begin
              if deb then
                begin
                  Log('Local host name: '
                    +PChar(phost^.h_name)) ;
                  Log('    Address type: '
                    +format('%x',[phost^.h_addrtype])) ;
                  Log('    Address length: '
                    +format('%d',[phost^.h_length])) ;
                end ;
              pint := Pointer(phost^.h_addr_list^) ;
              lina.s_addr := pint^ ;
              if deb then
                Log('    Local host address: '
                  +PChar(inet_ntoa(lina))) ;

              { bind socket to addr }
              LocalAddr.sin_family := AF_INET ;
              LocalAddr.sin_addr.s_addr := lina.s_addr ;
              LocalAddr.sin_port := htonl(INADDR_ANY) ;
              psaddr := Pointer(@LocalAddr) ;
              err := bind(soc,psaddr^,SizeOf(LocalAddr)) ;
              if err = SOCKET_ERROR then
                begin
                  Log('Bind error: '
                    +Format('%d',[WSAGetLastError()])) ;
                  Disconnect ;
                end
              else
                begin
                  if deb then
                    Log('Bind successful') ;

                  { get service port }
                  pServAddr := getservbyname('telnet','tcp') ;
                  if pServAddr <> nil then
                    begin
                      if deb then
                        begin
                          Log('Remote Service Info.:') ;
                          Log('    Name: '+PChar(pServAddr^.s_name)) ;
                          Log('    Port: '+Format('%d',[ntohs(pServAddr^.s_port)])) ;
                        end ;
                      usPort := pServAddr^.s_port ;

                      { connect to server }
                      RemoteAddr.sin_family := AF_INET ;
                      RemoteAddr.sin_addr.s_addr := ina.s_addr ;
                      RemoteAddr.sin_port := usPort ;
                      psaddr := Pointer(@RemoteAddr) ;
                      err := connect(soc,psaddr^,SizeOf(RemoteAddr)) ;
                      if err = SOCKET_ERROR then
                        begin
                          Log('Connect error: '
                            +Format('%d',[WSAGetLastError()])) ;
                          Disconnect ;
                        end
                      else
                        begin
                          if deb then
                            Log('Connected.') ;

                          { start thread to receive all data - will
                            also do all telnet negotiation }
                          RecThread := RecvThrd.Create(soc) ;

                          { send CR LF to get server started }
                          SendData(InitCmd) ;
                        end ;
                    end
                  else
                    begin
                      Log('Getservbyname error: '
                        +Format('%d',[WSAGetLastError()])) ;
                      Disconnect ;
                    end ;

                end ;
            end ;
        end
      else
        begin
          Log('Get local host error:'
            +Format('%d',[WSAGetLastError()])) ;
          Disconnect ;
        end ;
    end ;
end;

end.
