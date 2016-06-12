////////////////////////////////////////////////////////////////////////////////
// Unit Description  : sqldeveloper Description
// Unit Author       : LA.Center Corporation
// Date Created      : February, Tuesday 16, 2016
// -----------------------------------------------------------------------------
//
// History
//
//
////////////////////////////////////////////////////////////////////////////////


uses 'mainform';

//<events-code> - note: DESIGNER TAG => DO NOT REMOVE!

procedure AppException(Sender: TObject; E: Exception);
begin
    //Uncaught Exceptions
    MsgError('Error', E.Message);
end;

//sqldeveloper initialization constructor
constructor
begin
    Application.Initialize;
    Application.Icon.LoadFromResource('appicon');
    Application.Title := 'LA.SQL Developer';
    mainformCreate(nil);
    Application.Run;
end.

//Project Resources
//$res:appicon=[project-home]resources/app.ico
//$res:mainform=[project-home]mainform.pas.frm
//$res:regdb=[project-home]regdb.pas.frm
