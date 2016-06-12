////////////////////////////////////////////////////////////////////////////////
// Unit Description  : regdb Description
// Unit Author       : LA.Center Corporation
// Date Created      : February, Thursday 18, 2016
// -----------------------------------------------------------------------------
//
// History
//
//
////////////////////////////////////////////////////////////////////////////////

uses 'globals';

//constructor of regdb
function regdbCreate(Owner: TComponent): TForm;
begin
    result := TForm.CreateWithConstructorFromResource(Owner, @regdb_OnCreate, 'regdb');
end;

//OnCreate Event of regdb
procedure regdb_OnCreate(Sender: TForm);
begin
    //Form Constructor

    //todo: some additional constructing code
    if not OSX then
        Sender.PopupMode := pmAuto;

    TButtonPanel(Sender.Find('ButtonPanel1')).BorderSpacing.Around := 20;
    TButtonPanel(Sender.Find('ButtonPanel1')).OKButton.Enabled := false;
    TButtonPanel(Sender.Find('ButtonPanel1')).HelpButton.Caption := 'Test';

    //note: DESIGNER TAG => DO NOT REMOVE!
    //<events-bind>
    TEdit(Sender.find('eName')).OnChange := @regdb_eName_OnChange;
    TEdit(Sender.find('eServer')).OnChange := @regdb_eName_OnChange;
    TEdit(Sender.find('eDBName')).OnChange := @regdb_eName_OnChange;
    TEdit(Sender.find('eUser')).OnChange := @regdb_eName_OnChange;
    TEdit(Sender.find('ePass')).OnChange := @regdb_eName_OnChange;
    TComboBox(Sender.find('eType')).OnChange := @regdb_eType_OnChange;
    Sender.OnClose := @regdb_OnClose;
    Sender.OnCloseQuery := @regdb_OnCloseQuery;
    //</events-bind>
end;

procedure regdb_eType_OnChange(Sender: TComboBox);
begin
    if Sender.ItemIndex in [9,12] then
    begin
        TLabel(Sender.Owner.Find('Label3')).Enabled := false;
        TEdit(Sender.Owner.Find('eServer')).Enabled := false;
    end
        else
    begin
        TLabel(Sender.Owner.Find('Label3')).Enabled := true;
        TEdit(Sender.Owner.Find('eServer')).Enabled := true;
    end;

    if Sender.ItemIndex = 0 then
    TLabel(Sender.Owner.Find('Label3')).Caption := 'Enter the Public Key for this connection'
    else
    TLabel(Sender.Owner.Find('Label3')).Caption := 'Enter the Server Host for this connection';

    if Sender.ItemIndex = 9 then
    TLabel(Sender.Owner.Find('Label4')).Caption := 'Enter the ODBC Name'
    else if Sender.ItemIndex = 12 then
    TLabel(Sender.Owner.Find('Label4')).Caption := 'Enter the Database File Name'
    else
    TLabel(Sender.Owner.Find('Label4')).Caption := 'Enter the Database Name';

    regdb_eName_OnChange(Sender);
end;

procedure regdb_OnClose(Sender: TForm; var Action: TCloseAction);
begin
    Action := caFree;
end;

procedure regdb_OnCloseQuery(Sender: TForm; var CanClose: bool);
var
    name, type, serverhost, dbname, user, pass, params: string;
    i: int;
begin
    if Sender.ModalResult = mrOK then
    begin
        name := TEdit(Sender.Find('eName')).Text;
        type := TComboBox(Sender.Find('eType')).Text;
        serverhost := TEdit(Sender.Find('eServer')).Text;
        dbName := TEdit(Sender.Find('eDBName')).Text;
        user := TEdit(Sender.Find('eUser')).Text;
        pass := TEdit(Sender.Find('ePass')).Text;
        params := TMemo(Sender.Find('eParams')).Lines.Text;

        for i := 0 to _dbtree.Items.Count -1 do
        begin
            if _dbtree.Items.Item[i].Text = name then
            begin
                CanClose := false;
                MsgError('Error', 'Connection name is already used.');
                exit;
            end;
        end;

        if _testConnection(type, serverhost, dbname, user, pass, params) then
        _registerDB(name, type, serverhost, dbname, user, pass, params)
        else
        CanClose := false;
    end;
end;

procedure regdb_eName_OnChange(Sender: TComponent);
begin
    if not (TComboBox(Sender.Owner.Find('eType')).ItemIndex in [9,12]) then
    begin
        TButtonPanel(Sender.Owner.Find('ButtonPanel1')).OKButton.Enabled :=
            (Trim(TEdit(Sender.Owner.Find('eName')).Text) <> '') and
            (Trim(TEdit(Sender.Owner.Find('eServer')).Text) <> '') and
            (Trim(TEdit(Sender.Owner.Find('eDBName')).Text) <> '') and
            (Trim(TEdit(Sender.Owner.Find('eUser')).Text) <> '') and
            (Trim(TEdit(Sender.Owner.Find('ePass')).Text) <> '');
    end;

    if (TComboBox(Sender.Owner.Find('eType')).ItemIndex in [9]) then
    begin
        TButtonPanel(Sender.Owner.Find('ButtonPanel1')).OKButton.Enabled :=
            (Trim(TEdit(Sender.Owner.Find('eName')).Text) <> '') and
            (Trim(TEdit(Sender.Owner.Find('eDBName')).Text) <> '') and
            (Trim(TEdit(Sender.Owner.Find('eUser')).Text) <> '') and
            (Trim(TEdit(Sender.Owner.Find('ePass')).Text) <> '');
    end;

    if (TComboBox(Sender.Owner.Find('eType')).ItemIndex in [12]) then
    begin
        TButtonPanel(Sender.Owner.Find('ButtonPanel1')).OKButton.Enabled :=
            (Trim(TEdit(Sender.Owner.Find('eName')).Text) <> '') and
            (Trim(TEdit(Sender.Owner.Find('eDBName')).Text) <> '');
    end;
end;

//<events-code> - note: DESIGNER TAG => DO NOT REMOVE!

//regdb initialization constructor
constructor
begin 
end.
