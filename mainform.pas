////////////////////////////////////////////////////////////////////////////////
// Unit Description  : mainform Description
// Unit Author       : LA.Center Corporation
// Date Created      : February, Tuesday 16, 2016
// -----------------------------------------------------------------------------
//
// History
//
//
////////////////////////////////////////////////////////////////////////////////

uses 'globals', 'regdb';

//constructor of mainform
function mainformCreate(Owner: TComponent): TForm;
begin
    result := TForm.CreateWithConstructorFromResource(Owner, @mainform_OnCreate, 'mainform');
end;

//OnCreate Event of mainform
procedure mainform_OnCreate(Sender: TForm);
var
    editor: TSyntaxMemo;
    s: string;
begin
    //Form Constructor

    //todo: some additional constructing code
    Sender.Caption := Application.Title;
    Sender.Width := Screen.Width - 200;
    Sender.Height := Screen.Height - 200;

    TToolbar(Sender.Find('Toolbar1')).BorderSpacing.Left := 2;
    TToolbar(Sender.Find('Toolbar1')).BorderSpacing.Right := 2;
    TToolbar(Sender.Find('Toolbar1')).BorderSpacing.Top := 2;

    //reference dbtree
    _dbtree := TTreeView(Sender.Find('DBTree'));
    TTreeView(Sender.Find('DBTree')).BorderSpacing.Left := 2;
    TTreeView(Sender.Find('DBTree')).BorderSpacing.Top := 2;
    TTreeView(Sender.Find('DBTree')).BorderSpacing.Bottom := 2;

    TPanel(Sender.Find('clientPanel')).BorderSpacing.Right := 2;
    TPanel(Sender.Find('clientPanel')).BorderSpacing.Top := 2;
    TPanel(Sender.Find('clientPanel')).BorderSpacing.Bottom := 2;

    //SyntaxMemo is a non persistent component
    //and needs to be created by code
    editor := TSyntaxMemo.Create(Sender);
    editor.Parent := TPanel(Sender.Find('topPanel'));
    editor.Align := alClient;
    editor.SyntaxStyle := stsSQL;
    editor.PopupMenu := TPopupMenu(Sender.Find('PopupMenu1'));
    editor.Name := 'Editor';
    editor.Lines.Text := '';

    Sender.ActiveControl := editor;

    //note: DESIGNER TAG => DO NOT REMOVE!
    //<events-bind>
    TAction(Sender.find('actExtract')).OnExecute := @mainform_actExtract_OnExecute;
    TTimer(Sender.find('Timer1')).OnTimer := @mainform_Timer1_OnTimer;
    TAction(Sender.find('actRemoveDatabase')).OnExecute := @mainform_actRemoveDatabase_OnExecute;
    TAction(Sender.find('actExit')).OnExecute := @mainform_actExit_OnExecute;
    TAction(Sender.find('actRunQuery')).OnExecute := @mainform_actRunQuery_OnExecute;
    TAction(Sender.find('actExecute')).OnExecute := @mainform_actExecute_OnExecute;
    TAction(Sender.find('actSelectAll')).OnExecute := @mainform_actSelectAll_OnExecute;
    TAction(Sender.find('actPaste')).OnExecute := @mainform_actPaste_OnExecute;
    TAction(Sender.find('actCopy')).OnExecute := @mainform_actCopy_OnExecute;
    TAction(Sender.find('actCut')).OnExecute := @mainform_actCut_OnExecute;
    TAction(Sender.find('actRedo')).OnExecute := @mainform_actRedo_OnExecute;
    TAction(Sender.find('actUndo')).OnExecute := @mainform_actUndo_OnExecute;
    TAction(Sender.find('actSave')).OnExecute := @mainform_actSave_OnExecute;
    TAction(Sender.find('actOpen')).OnExecute := @mainform_actOpen_OnExecute;
    TAction(Sender.find('actConnect')).OnExecute := @mainform_actConnect_OnExecute;
    TTreeView(Sender.find('DBTree')).OnChange := @mainform_DBTree_OnChange;
    TTreeView(Sender.find('DBTree')).OnExpanding := @mainform_DBTree_OnExpanding;
    TTreeView(Sender.find('DBTree')).OnCollapsing := @mainform_DBTree_OnCollapsing;
    TTreeView(Sender.find('DBTree')).OnCustomDrawItem := @mainform_DBTree_OnCustomDrawItem;
    TAction(Sender.find('actRegDatabase')).OnExecute := @mainform_actRegDatabase_OnExecute;
    TMenuItem(Sender.find('mAbout')).OnClick := @mainform_mAbout_OnClick;
    //</events-bind>

    s := GetMessage('LASQLDeveloper-Startup');
    if Trim(s) <> '' then
    begin
        if FileExists(s) then
            editor.Lines.LoadFromFile(s);
    end;

    //populate db tree
    _populateTree;

    //Set as Application.MainForm
    Sender.setAsMainForm;
end;

procedure mainform_mAbout_OnClick(Sender: TMenuItem);
begin
    MsgInfo('About', 'LA.SQL Developer 1.0'+#13+#10+
            'Copyright (C) 2016 LA.Center Corporation');
end;

procedure mainform_actRegDatabase_OnExecute(Sender: TAction);
begin
    regdbCreate(Sender.Owner).ShowModalDimmed;
end;

procedure mainform_DBTree_OnCustomDrawItem(Sender: TTreeView; Node: TTreeNode; DrawInfo: TCustomDrawInfo; var DefaultDraw: bool);
begin
    if (Node.Level = 0) and (Node.Data <> nil) then
    Sender.Canvas.Font.Style := fsBold
    else
    Sender.Canvas.Font.Style := 0;
end;

procedure mainform_DBTree_OnCollapsing(Sender: TTreeView; Node: TTreeNode; var Allow: bool);
begin
    if Node.Level = 0 then
    begin
        try
            TObject(Node.Data).Free;
            Node.Data := nil;
            Node.DeleteChildren;
            Node.HasChildren := true;
            TAction(Sender.Owner.Find('actConnect')).Caption := 'Connect';
        except end;
        Allow := true;
    end;
    if Node.Level = 1 then
    begin
        Node.ImageIndex := 19;
        Node.SelectedIndex := Node.ImageIndex;
        Node.DeleteChildren;
        Node.HasChildren := true;
    end;
    if Node.Level = 2 then
    begin
        Node.DeleteChildren;
        Node.HasChildren := true;
    end;
end;

procedure mainform_DBTree_OnExpanding(Sender: TTreeView; Node: TTreeNode; var Allow: bool);
begin
    if Node.Level = 0 then
    begin
        //connect and populate table, views, index, triggers
        Node.Selected := true;

        if Node.Data = nil then
            Allow := _connectToDB(Node);

        if Allow then
        begin
            TAction(Sender.Owner.Find('actConnect')).Caption := 'Disconnect';
            _populateDB(Node);
        end;
    end;
    if Node.Level = 1 then
    begin
        if Node.Text = 'Tables' then
        begin
            _populateTables(Node);
            Allow := (Node.Count <> 0);
            if Allow then
            begin
                Node.ImageIndex := 20;
                Node.SelectedIndex := Node.ImageIndex;
            end;
        end;
        if Node.Text = 'Procedures' then
        begin
            _populateProcs(Node);
            Allow := (Node.Count <> 0);
            if Allow then
            begin
                Node.ImageIndex := 20;
                Node.SelectedIndex := Node.ImageIndex;
            end;
        end;
        if Node.Text = 'Views' then
        begin
            _populateViews(Node);
            Allow := (Node.Count <> 0);
            if Allow then
            begin
                Node.ImageIndex := 20;
                Node.SelectedIndex := Node.ImageIndex;
            end;
        end;
        if Node.Text = 'Indices' then
        begin
            _populateIndexes(Node);
            Allow := (Node.Count <> 0);
            if Allow then
            begin
                Node.ImageIndex := 20;
                Node.SelectedIndex := Node.ImageIndex;
            end;
        end;
        if Node.Text = 'Triggers' then
        begin
            _populateTriggers(Node);
            Allow := (Node.Count <> 0);
            if Allow then
            begin
                Node.ImageIndex := 20;
                Node.SelectedIndex := Node.ImageIndex;
            end;
        end;
    end;
    if Node.Level = 2 then
    begin
        _populateColumns(Node);
        Allow := (Node.Count <> 0);
    end;
end;

procedure mainform_DBTree_OnChange(Sender: TTreeView; Node: TTreeNode);
begin
    TAction(Sender.Owner.Find('actConnect')).Enabled :=
        (Sender.Selected <> nil) and (Sender.Selected.Level = 0);

    TAction(Sender.Owner.Find('actRemoveDatabase')).Enabled :=
        TAction(Sender.Owner.Find('actConnect')).Enabled;

    if (Sender.Selected <> nil) and (Sender.Selected.Level = 0) then
    begin
        if Sender.Selected.Count = 0 then
        TAction(Sender.Owner.Find('actConnect')).Caption := 'Connect'
        else
        TAction(Sender.Owner.Find('actConnect')).Caption := 'Disconnect';
    end
        else
        TAction(Sender.Owner.Find('actConnect')).Caption := 'Disconnect';
end;

procedure mainform_actConnect_OnExecute(Sender: TAction);
begin
    if TTreeView(Sender.Owner.Find('DBTree')).Selected.Count = 0 then
    TTreeView(Sender.Owner.Find('DBTree')).Selected.Expand(false)
    else
    TTreeView(Sender.Owner.Find('DBTree')).Selected.Collapse(false);
end;

procedure mainform_actOpen_OnExecute(Sender: TAction);
var
    dlg: TOpenDialog;
begin
    dlg := TOpenDialog.Create(Sender.Owner);
    dlg.Filter := 'SQL Files (*.sql)|*.sql|All Files (*)|*';
    if dlg.ExecuteDimmed then
        TSyntaxMemo(Sender.Owner.Find('Editor')).Lines.LoadFromFile(dlg.FileName);
    dlg.free;
end;

procedure mainform_actSave_OnExecute(Sender: TAction);
var
    dlg: TSaveDialog;
begin
    dlg := TSaveDialog.Create(Sender.Owner);
    dlg.setProp('Options', 'ofOverwritePrompt,ofEnableSizing,ofViewDetail');
    dlg.Filter := 'SQL Files (*.sql)|*.sql|All Files (*)|*';
    dlg.DefaultExt := '.sql';
    if dlg.Execute then
        TSyntaxMemo(Sender.Owner.Find('Editor')).Lines.SaveToFile(dlg.FileName);
    dlg.free;
end;

procedure mainform_actUndo_OnExecute(Sender: TAction);
begin
    TSyntaxMemo(Sender.Owner.Find('Editor')).Undo;
end;

procedure mainform_actRedo_OnExecute(Sender: TAction);
begin
    TSyntaxMemo(Sender.Owner.Find('Editor')).Redo;
end;

procedure mainform_actCut_OnExecute(Sender: TAction);
begin
    TSyntaxMemo(Sender.Owner.Find('Editor')).CutToClipboard;
end;

procedure mainform_actCopy_OnExecute(Sender: TAction);
begin
    TSyntaxMemo(Sender.Owner.Find('Editor')).CopyToClipboard;
end;

procedure mainform_actPaste_OnExecute(Sender: TAction);
begin
    TSyntaxMemo(Sender.Owner.Find('Editor')).PasteFromClipboard;
end;

procedure mainform_actSelectAll_OnExecute(Sender: TAction);
begin
    TSyntaxMemo(Sender.Owner.Find('Editor')).SelectAll;
end;

procedure mainform_actExecute_OnExecute(Sender: TAction);
var
    sql: TSQLQuery;
    laSQL: TLASQL;
    editor: TSyntaxMemo;
    ds: TDataSource;
begin
    sql := TSQLQuery(Sender.Owner.Find('SQL'));
    laSQL := TLASQL(Sender.Owner.Find('LASQL'));
    ds := TDataSource(Sender.Owner.Find('DataSource1'));
    editor := TSyntaxMemo(Sender.Owner.Find('editor'));

    ds.DataSet := nil;

    if (_dbtree.Selected <> nil) and (_dbtree.Selected.Data <> nil) then
    begin
        if _dbtree.Selected.Data.ClassName = 'TLASQLConnection' then
        begin
            if TLASQLConnection(_dbtree.Selected.Data).Connected then
            begin
                try
                    laSQL.Database := TLASQLConnection(_dbtree.Selected.Data);
                    laSQL.ExecSQL(editor.Lines.Text);
                except
                    MsgError('Error', ExceptionMessage);
                end;
            end;
        end
        else
        begin
            if TSQLConnection(_dbtree.Selected.Data).Connected then
            begin
                try
                    SQL.Database := TDatabase(_dbtree.Selected.Data);
                    SQL.SQL.Text := editor.Lines.Text;
                    SQL.ExecSQL;
                except
                    MsgError('Error', ExceptionMessage);
                end;
            end;
        end;
    end;
end;

procedure mainform_actRunQuery_OnExecute(Sender: TAction);
var
    sql: TSQLQuery;
    laSQL: TLASQL;
    editor: TSyntaxMemo;
    ds: TDataSource;
begin
    sql := TSQLQuery(Sender.Owner.Find('SQL'));
    laSQL := TLASQL(Sender.Owner.Find('LASQL'));
    ds := TDataSource(Sender.Owner.Find('DataSource1'));
    editor := TSyntaxMemo(Sender.Owner.Find('editor'));

    ds.DataSet := nil;

    if (_dbtree.Selected <> nil) and (_dbtree.Selected.Data <> nil) then
    begin
        if _dbtree.Selected.Data.ClassName = 'TLASQLConnection' then
        begin
            if TLASQLConnection(_dbtree.Selected.Data).Connected then
            begin
                try
                    laSQL.Close;
                    laSQL.FieldDefs.Clear;
                    laSQL.Database := TLASQLConnection(_dbtree.Selected.Data);
                    laSQL.SQLSelect := editor.Lines.Text;
                    laSQL.Open;
                    ds.DataSet := laSQL;
                except
                    MsgError('Error', ExceptionMessage);
                end;
            end;
        end
        else
        begin
            if TSQLConnection(_dbtree.Selected.Data).Connected then
            begin
                try
                    SQL.Close;
                    SQL.Database := TDatabase(_dbtree.Selected.Data);
                    SQL.SQL.Text := editor.Lines.Text;
                    SQL.Open;
                    ds.DataSet := SQL;
                except
                    MsgError('Error', ExceptionMessage);
                end;
            end;
        end;
    end;
end;

procedure mainform_actExit_OnExecute(Sender: TAction);
begin
    TForm(Sender.Owner).Close;
end;

procedure mainform_actRemoveDatabase_OnExecute(Sender: TAction);
begin
    if (_dbtree.Selected <> nil) and (_dbtree.Selected.Level = 0) then
    begin
        if MsgWarning('Warning', 'You are about to remove a database connection, continue?') then
            _removeDB(_dbtree.Selected.Text)
    end;
end;

procedure mainform_Timer1_OnTimer(Sender: TTimer);
begin
    if TAction(Sender.Owner.Find('actExecute')).Enabled <> (_dbtree.Selected <> nil) and (_dbtree.Selected.Data <> nil) and (Trim(TSyntaxMemo(Sender.Owner.Find('Editor')).Lines.Text) <> '') then
        TAction(Sender.Owner.Find('actExecute')).Enabled := (_dbtree.Selected <> nil) and (_dbtree.Selected.Data <> nil) and (Trim(TSyntaxMemo(Sender.Owner.Find('Editor')).Lines.Text) <> '');

    if TAction(Sender.Owner.Find('actRunQuery')).Enabled <> (_dbtree.Selected <> nil) and (_dbtree.Selected.Data <> nil) and (Trim(TSyntaxMemo(Sender.Owner.Find('Editor')).Lines.Text) <> '') then
        TAction(Sender.Owner.Find('actRunQuery')).Enabled := (_dbtree.Selected <> nil) and (_dbtree.Selected.Data <> nil) and (Trim(TSyntaxMemo(Sender.Owner.Find('Editor')).Lines.Text) <> '');

    if TAction(Sender.Owner.Find('actExtract')).Enabled <> (_dbtree.Selected <> nil) and (_dbtree.Selected.Data <> nil) and (_dbtree.Selected.Level = 2) and (_dbtree.Selected.Data.ClassName = 'TLASQLConnection') then
        TAction(Sender.Owner.Find('actExtract')).Enabled := (_dbtree.Selected <> nil) and (_dbtree.Selected.Data <> nil) and (_dbtree.Selected.Level = 2) and (_dbtree.Selected.Data.ClassName = 'TLASQLConnection');

    if TAction(Sender.Owner.Find('actUndo')).Enabled <> TSyntaxMemo(Sender.Owner.Find('Editor')).CanUndo then
        TAction(Sender.Owner.Find('actUndo')).Enabled := TSyntaxMemo(Sender.Owner.Find('Editor')).CanUndo;

    if TAction(Sender.Owner.Find('actRedo')).Enabled <> TSyntaxMemo(Sender.Owner.Find('Editor')).CanRedo then
        TAction(Sender.Owner.Find('actRedo')).Enabled := TSyntaxMemo(Sender.Owner.Find('Editor')).CanRedo;

    if TAction(Sender.Owner.Find('actPaste')).Enabled <> TSyntaxMemo(Sender.Owner.Find('Editor')).CanPaste then
        TAction(Sender.Owner.Find('actPaste')).Enabled := TSyntaxMemo(Sender.Owner.Find('Editor')).CanPaste;

    if TAction(Sender.Owner.Find('actCut')).Enabled <> (TSyntaxMemo(Sender.Owner.Find('Editor')).SelText <> '') then
        TAction(Sender.Owner.Find('actCut')).Enabled := (TSyntaxMemo(Sender.Owner.Find('Editor')).SelText <> '');

    if TAction(Sender.Owner.Find('actCopy')).Enabled <> (TSyntaxMemo(Sender.Owner.Find('Editor')).SelText <> '') then
        TAction(Sender.Owner.Find('actCopy')).Enabled := (TSyntaxMemo(Sender.Owner.Find('Editor')).SelText <> '');
end;

procedure mainform_actExtract_OnExecute(Sender: TAction);
var
    editor: TSyntaxMemo;
    canExtract: bool = true;
begin
    editor := TSyntaxMemo(Sender.Owner.Find('editor'));

    if Trim(editor.Lines.Text) <> '' then
    begin
        canExtract := MsgQuestion('Please Confirm', 'The text in the editor will be replaced, continue?');
    end
        else
        canExtract := true;

    if canExtract then
        editor.Lines.Text := _extactSQL(_dbtree.Selected);
end;

//<events-code> - note: DESIGNER TAG => DO NOT REMOVE!

//mainform initialization constructor
constructor
begin
end.
