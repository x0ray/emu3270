///////////////////////////////////////////////////////////////////////////
// Project:   Emu3270
// Program:   emu3270.pas
// Language:  Object Pascal - Delphi ver 2.0
// Support:   David Fahey
// Date:      05Mar97
// Purpose:   To establish a telnet session with a user specified
//            machine name.
// History:   05Mar97  Initial coding                              DAF
// Notes:     The program supplies extensive debugging output when
//            the flag deb is set to true. This can be most valuable
//            when experimenting with the telnet protocol. A menu option
//            is used to toggle the deb flag.
//
//            Various references have been used:
//              Borland Delphi reference manuals.
//              Various RFC's that are relevant to telnet:
//                RFC854 ... (see telnetdoc.txt)
//              Building Internet applications with Delphi 2
//                by Davis Chapman, QUE, 1996, isbn 0-7897-0732-2
//              Delphi 2 Developers Guide.
//                by Xavier Pacheco and Steve Teixeira, Borland Press
//                1996, isbn 0-672-30914-9
//              Delphi 2 Unleashed.
//                by Charles Calvert, Borland Press and Sams Publishing,
//                1996, isbn 0-672-30858-4
//              Unix System V Network Programming.
//                by Stephen A. Rago, Addison Wesley, 1993,
//                isbn 0-201-56318-5
//              Network Programming in Windows NT.
//                Alok K Sinha, Addison Wesley, 1993, isbn 0-201-59056-5
//              3270 Information Display System, Data Stream Programmers
//                Reference, Eighth edition (June 1992), GA23-0059-07
//              IBM 3179-G/3192-G Color Graphics Display Station,
//                Descripption, Third Edition (Sept 1988), GA18-2589-2
//              IBM 3270 Personal Computer Graphics Control Program,
//                Data Stream Reference, First Edition (Mar 1985), HUR 9058  
//
// End.
///////////////////////////////////////////////////////////////////////////

program emu3270 ;

uses
  Forms,
  screenu in 'screenu.pas' {screenf},
  Keymapu in 'Keymapu.pas' {keymap},
  ds3270u in 'ds3270u.pas',
  AboutU in 'AboutU.pas' {AboutBox},
  RecThrd in 'RecThrd.pas',
  telnetu in 'telnetu.pas',
  ConnectU in 'ConnectU.pas' {ConnectHost},
  logu in 'logu.pas' {logf},
  utilu in 'utilu.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Emu 3270';
  Application.CreateForm(Tscreenf, screenf);
  Application.CreateForm(Tkeymap, keymap);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TConnectHost, ConnectHost);
  Application.CreateForm(Tlogf, logf);
  Application.Run;
end.
