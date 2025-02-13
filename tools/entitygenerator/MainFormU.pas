unit MainFormU;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI,
  FireDAC.Phys.IBBase,
  FireDAC.Phys.FB,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  FireDAC.Phys.ODBCBase,
  FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.FBDef,
  Vcl.ComCtrls,
  Vcl.Grids,
  Vcl.ValEdit,
  FireDAC.Phys.MySQLDef,
  FireDAC.Phys.MySQL,
  FireDAC.Phys.PGDef,
  FireDAC.Phys.PG,
  FireDAC.Phys.IBDef,
  FireDAC.Phys.IB,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLite, Vcl.DBGrids, FireDAC.Phys.SQLiteWrapper.Stat, Vcl.Buttons;

type
  TSelectionType = (stAll, stNone, stInverse);

  TMainForm = class(TForm)
    FDConnection1: TFDConnection;
    Panel1: TPanel;
    Panel2: TPanel;
    qry: TFDQuery;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    Splitter1: TSplitter;
    mmConnectionParams: TMemo;
    Label2: TLabel;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    cboConnectionDefs: TComboBox;
    Panel3: TPanel;
    Panel4: TPanel;
    btnGenEntities: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    btnGetTables: TButton;
    mmOutput: TMemo;
    Panel5: TPanel;
    btnSaveCode: TButton;
    FileSaveDialog1: TFileSaveDialog;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    FDPhysPgDriverLink1: TFDPhysPgDriverLink;
    FDPhysFBDriverLink2: TFDPhysFBDriverLink;
    FDPhysIBDriverLink1: TFDPhysIBDriverLink;
    FDPhysMySQLDriverLink2: TFDPhysMySQLDriverLink;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    dsTablesMapping: TFDMemTable;
    dsTablesMappingTABLE_NAME: TStringField;
    dsTablesMappingCLASS_NAME: TStringField;
    DBGrid1: TDBGrid;
    dsrcTablesMapping: TDataSource;
    Panel6: TPanel;
    GroupBox1: TGroupBox;
    lstSchema: TListBox;
    lstCatalog: TListBox;
    btnRefreshCatalog: TButton;
    Label1: TLabel;
    chGenerateMapping: TCheckBox;
    dsTablesMappingGENERATE: TBooleanField;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    RadioGroup1: TRadioGroup;
    rgFieldNameFormatting: TRadioGroup;
    Panel7: TPanel;
    btnUZ: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    procedure btnGenEntitiesClick(Sender: TObject);
    procedure btnGetTablesClick(Sender: TObject);
    procedure btnSaveCodeClick(Sender: TObject);
    procedure cboConnectionDefsChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lstCatalogDblClick(Sender: TObject);
    procedure btnRefreshCatalogClick(Sender: TObject);
    procedure mmConnectionParamsChange(Sender: TObject);
    procedure lstSchemaDblClick(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnSlice1Click(Sender: TObject);
    procedure btnUZClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    fCatalog: string;
    fSchema: string;
    fIntfBuff, fImplBuff, fInitializationBuff: TStringStream;
    FHistoryFileName: string;
    lTypesName: TArray<string>;
    fBookmark: TArray<Byte>;
    function SelectTables(const FromLetter: AnsiChar; const ToLetter: AnsiChar): Integer;
    procedure EmitHeaderComments;
    function GetClassName(const aTableName: string): string;
    function GetUniqueFieldNames(const Fields: TFields; const FormatAsPascalCase: Boolean): TArray<String>;
    procedure EmitUnit;
    procedure EmitUnitEnd;
    procedure EmitProperty(const FieldName: String; const FieldDataType: TFieldType);
    procedure EmitField(const DatabaseFieldName: String; const UniqueFieldName: String; const FieldDataType: TFieldType; const IsPK: Boolean);
    procedure EmitClass(const aTableName, aClassName, aNameCase: string);
    procedure EmitClassEnd;
    function GetDelphiType(FT: TFieldType): string;
    function GetFieldName(const Value: string): string;
    procedure DoSelection(const SelectionType: TSelectionType);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

const
  LOG_TAG = 'generator';

implementation

uses
  System.IOUtils,
  System.TypInfo,
  System.DateUtils,
  LoggerPro.GlobalLogger,
  System.Generics.Collections,
  MVCFramework.Commons, UtilsU;

{$R *.dfm}

const
  INDENT = '  ';

procedure TMainForm.btnGenEntitiesClick(Sender: TObject);
var
  I: Integer;
  lTableName: string;
  lClassName: string;
  F: Integer;
  lFieldNamesToInitialize: TArray<string>;
  lKeyFields: TStringList;
  lUniqueFieldNames: TArray<String>;
begin
  Log.Info('Starting entities generation', LOG_TAG);
  fIntfBuff.Clear;
  fImplBuff.Clear;
  fInitializationBuff.Clear;
  lKeyFields := TStringList.Create;
  try
    EmitHeaderComments;
    EmitUnit;
    dsTablesMapping.First;
    while not dsTablesMapping.Eof do
    begin
      if not dsTablesMappingGENERATE.Value then
      begin
        Log.Info('Skipping table %s', [dsTablesMappingTABLE_NAME.AsString], LOG_TAG);
        dsTablesMapping.Next;
        Continue;
      end;
      lTableName := dsTablesMappingTABLE_NAME.AsString;
      Log.Info('Generating entity %s for table %s', [dsTablesMappingCLASS_NAME.AsString,
        dsTablesMappingTABLE_NAME.AsString], LOG_TAG);
      lClassName := dsTablesMappingCLASS_NAME.AsString;
      EmitClass(lTableName, lClassName, RadioGroup1.Items[RadioGroup1.ItemIndex]);
      lKeyFields.Clear;
      qry.Close;
      qry.SQL.Text := 'select * from ' + lTableName + ' where 1=0';
      qry.Open;
      try
        FDConnection1.GetKeyFieldNames(fCatalog, fSchema, lTableName, '', lKeyFields);
      except
      end;
      lFieldNamesToInitialize := [];
      lTypesName := [];
      fIntfBuff.WriteString(INDENT + 'private' + sLineBreak);
      lUniqueFieldNames := GetUniqueFieldNames(qry.Fields, rgFieldNameFormatting.ItemIndex = 1);
      for F := 0 to qry.Fields.Count - 1 do
      begin
        EmitField(qry.Fields[F].FieldName, lUniqueFieldNames[F], qry.Fields[F].DataType, lKeyFields.IndexOf(qry.Fields[F].FieldName) > -1);

        if GetDelphiType(qry.Fields[F].DataType) = 'TStream' then
        begin
          lFieldNamesToInitialize := lFieldNamesToInitialize + [GetFieldName(lUniqueFieldNames[F])];
          lTypesName := lTypesName + ['TMemoryStream'];
        end;

      end;

      fIntfBuff.WriteString(INDENT + 'public' + sLineBreak);
      fIntfBuff.WriteString(INDENT + '  constructor Create; override;' + sLineBreak);

      fImplBuff.WriteString('constructor ' + lClassName + '.Create;' + sLineBreak);
      fImplBuff.WriteString('begin' + sLineBreak);
      fImplBuff.WriteString('  inherited Create;' + sLineBreak);
      for F := low(lFieldNamesToInitialize) to high(lFieldNamesToInitialize) do
      begin
        fImplBuff.WriteString('  ' + lFieldNamesToInitialize[F] + ' := ' + lTypesName[F] + '.Create;' +
          sLineBreak);
      end;
      fImplBuff.WriteString('end;' + sLineBreak + sLineBreak);

      fIntfBuff.WriteString(INDENT + '  destructor Destroy; override;' + sLineBreak);
      fImplBuff.WriteString('destructor ' + lClassName + '.Destroy;' + sLineBreak);
      fImplBuff.WriteString('begin' + sLineBreak);
      for F := low(lFieldNamesToInitialize) to high(lFieldNamesToInitialize) do
      begin
        fImplBuff.WriteString('  ' + lFieldNamesToInitialize[F] + '.Free;' + sLineBreak);
      end;
      fImplBuff.WriteString('  inherited;' + sLineBreak);
      fImplBuff.WriteString('end;' + sLineBreak + sLineBreak);

      for F := 0 to qry.Fields.Count - 1 do
      begin
        EmitProperty(lUniqueFieldNames[F], qry.Fields[F].DataType);
      end;

      EmitClassEnd;
      dsTablesMapping.Next;
    end;
    EmitUnitEnd;
    mmOutput.Lines.Text := fIntfBuff.DataString + fImplBuff.DataString +
      fInitializationBuff.DataString;

  finally
    lKeyFields.Free;
  end;
  // mmOutput.Lines.SaveToFile(
  // mmConnectionParams.Lines.SaveToFile(FHistoryFileName);
  ShowMessage('Generation Completed');
end;

procedure TMainForm.btnGetTablesClick(Sender: TObject);
var
  lTables: TStringList;
  lTable: string;
  lClassName: string;
begin
  FDConnection1.Connected := True;
  lTables := TStringList.Create;
  try
    fCatalog := '';
    if lstCatalog.ItemIndex > -1 then
    begin
      fCatalog := lstCatalog.Items[lstCatalog.ItemIndex];
    end;
    fSchema := '';
    if lstSchema.ItemIndex > -1 then
    begin
      fSchema := lstSchema.Items[lstSchema.ItemIndex];
    end;
    FDConnection1.GetTableNames(fCatalog, fSchema, '', lTables);


    // FDConnection1.GetTableNames('', 'public', '', lTables);
    // FDConnection1.GetTableNames('', '', '', lTables);
    // if lTables.Count = 0 then
    // FDConnection1.GetTableNames('', 'dbo', '', lTables);

    dsTablesMapping.EmptyDataSet;
    for lTable in lTables do
    begin
      lClassName := GetClassName(lTable);
      dsTablesMapping.AppendRecord([True, lTable, lClassName]);
    end;
    dsTablesMapping.First;
  finally
    lTables.Free;
  end;
  TabSheet1.Caption:= 'Tables (' + dsTablesMapping.RecordCount.ToString + ')';
end;

procedure TMainForm.btnRefreshCatalogClick(Sender: TObject);
begin
  FDConnection1.Params.Clear;
  FDConnection1.Params.Text := mmConnectionParams.Text;
  FDConnection1.Open;
  lstCatalog.Items.Clear;
  FDConnection1.GetCatalogNames('', lstCatalog.Items);
  PageControl1.ActivePageIndex := 0;
end;

procedure TMainForm.btnSaveCodeClick(Sender: TObject);
begin
  FileSaveDialog1.FileName := 'EntitiesU.pas';
  if FileSaveDialog1.Execute then
  begin
    mmOutput.Lines.SaveToFile(FileSaveDialog1.FileName);
  end;
end;

procedure TMainForm.btnSlice1Click(Sender: TObject);
begin
  ShowMessage('Select ' + SelectTables('R','T').ToString + ' new tables');
end;

procedure TMainForm.btnUZClick(Sender: TObject);
begin
  ShowMessage('Select ' + SelectTables('U','Z').ToString + ' new tables');
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  ShowMessage('Select ' + SelectTables('L','Q').ToString + ' new tables');
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  ShowMessage('Select ' + SelectTables('E','K').ToString + ' new tables');
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  ShowMessage('Select ' + SelectTables('C','D').ToString + ' new tables');
end;

procedure TMainForm.Button5Click(Sender: TObject);
begin
  ShowMessage('Select ' + SelectTables('A','B').ToString + ' new tables');
end;

procedure TMainForm.cboConnectionDefsChange(Sender: TObject);
begin
  FDConnection1.Close;
  FDManager.GetConnectionDefParams(cboConnectionDefs.Text, mmConnectionParams.Lines);
  lstCatalog.Items.Clear;
  lstSchema.Items.Clear;
  FDConnection1.Params.Clear;
  FDConnection1.Params.Text := mmConnectionParams.Text;
end;

procedure TMainForm.DBGrid1CellClick(Column: TColumn);
begin
  if Column.FieldName = 'GENERATE' then
  begin
    if not(dsTablesMapping.State = dsEdit) then
    begin
      dsTablesMapping.Edit;
    end;
    dsTablesMappingGENERATE.Value := not dsTablesMappingGENERATE.Value;
    dsTablesMapping.Post;
  end;
end;

procedure TMainForm.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
const
  IsChecked: array [Boolean] of Integer = (DFCS_BUTTONCHECK, DFCS_BUTTONCHECK or DFCS_CHECKED);
var
  DrawState: Integer;
  DrawRect: TRect;
begin
  if (Column.Field.FieldName = 'GENERATE') then
  begin
    DrawRect := Rect;
    InflateRect(DrawRect, -1, -1);
    DrawState := IsChecked[Column.Field.AsBoolean];
    DBGrid1.Canvas.FillRect(Rect);
    DrawFrameControl(DBGrid1.Canvas.Handle, DrawRect,
      DFC_BUTTON, DrawState);
  end
  else
  begin
    DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
  end;
end;

procedure TMainForm.DoSelection(const SelectionType: TSelectionType);
begin
  dsTablesMapping.DisableControls;
  try
    fBookmark := dsTablesMapping.GetBookmark;
    dsTablesMapping.First;
    while not dsTablesMapping.Eof do
    begin
      dsTablesMapping.Edit;
      case SelectionType of
        stAll:
          dsTablesMappingGENERATE.Value := True;
        stNone:
          dsTablesMappingGENERATE.Value := False;
        stInverse:
          dsTablesMappingGENERATE.Value := not dsTablesMappingGENERATE.Value;
      end;
      dsTablesMapping.Post;
      dsTablesMapping.Next;
    end;
    dsTablesMapping.Bookmark := fBookmark;
  finally
    dsTablesMapping.EnableControls;
  end;
end;

procedure TMainForm.EmitClass(const aTableName, aClassName, aNameCase: string);
begin
  fIntfBuff.WriteString(INDENT + '[MVCNameCase(nc' + aNameCase + ')]' + sLineBreak);
  fIntfBuff.WriteString(INDENT + Format('[MVCTable(''%s'')]', [aTableName]) + sLineBreak);
  if trim(aClassName) = '' then
    raise Exception.Create('Invalid class name');
  fIntfBuff.WriteString(INDENT + aClassName + ' = class(TMVCActiveRecord)' + sLineBreak);
  if chGenerateMapping.Checked then
    fInitializationBuff.WriteString
      (Format('ActiveRecordMappingRegistry.AddEntity(''%s'', %s);',
      [aTableName.ToLower, aClassName]) + sLineBreak);
end;

procedure TMainForm.EmitClassEnd;
begin
  fIntfBuff.WriteString(INDENT + 'end;' + sLineBreak + sLineBreak);
end;

procedure TMainForm.EmitField(const DatabaseFieldName: String; const UniqueFieldName: String; const FieldDataType: TFieldType; const IsPK: Boolean);
var
  lAttrib, lField: string;
begin
  if IsPK then
  begin
    lAttrib := Format('[MVCTableField(''%s'', [foPrimaryKey, foAutoGenerated])]', [DatabaseFieldName]);
  end
  else
  begin
    lAttrib := Format('[MVCTableField(''%s'')]', [DatabaseFieldName]);
  end;
  lField := GetFieldName(UniqueFieldName) + ': ' + GetDelphiType(FieldDataType) + ';' + sLineBreak;

  if GetDelphiType(FieldDataType).ToUpper.Contains('UNSUPPORTED TYPE') then
  begin
    lAttrib := '//' + lAttrib;
    lField := '//' + lField;
  end
  else
  begin
    lField := '  ' + lField;
    lAttrib := '  ' + lAttrib;
  end;
  fIntfBuff.WriteString(INDENT + lAttrib + sLineBreak + INDENT + lField);
end;

procedure TMainForm.EmitHeaderComments;
begin
  fIntfBuff.WriteString
    ('// *************************************************************************** }' +
    sLineBreak);
  fIntfBuff.WriteString('//' + sLineBreak);
  fIntfBuff.WriteString('// Delphi MVC Framework' + sLineBreak);
  fIntfBuff.WriteString('//' + sLineBreak);
  fIntfBuff.WriteString('// Copyright (c) 2010-' + YearOf(Date).ToString +
    ' Daniele Teti and the DMVCFramework Team' + sLineBreak);
  fIntfBuff.WriteString('//' + sLineBreak);
  fIntfBuff.WriteString('// https://github.com/danieleteti/delphimvcframework' + sLineBreak);
  fIntfBuff.WriteString('//' + sLineBreak);
  fIntfBuff.WriteString
    ('// ***************************************************************************' + sLineBreak);
  fIntfBuff.WriteString('//' + sLineBreak);
  fIntfBuff.WriteString('// Licensed under the Apache License, Version 2.0 (the "License");' +
    sLineBreak);
  fIntfBuff.WriteString('// you may not use this file except in compliance with the License.' +
    sLineBreak);
  fIntfBuff.WriteString('// You may obtain a copy of the License at' + sLineBreak);
  fIntfBuff.WriteString('//' + sLineBreak);
  fIntfBuff.WriteString('// http://www.apache.org/licenses/LICENSE-2.0' + sLineBreak);
  fIntfBuff.WriteString('//' + sLineBreak);
  fIntfBuff.WriteString('// Unless required by applicable law or agreed to in writing, software' +
    sLineBreak);
  fIntfBuff.WriteString('// distributed under the License is distributed on an "AS IS" BASIS,' +
    sLineBreak);
  fIntfBuff.WriteString
    ('// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.' + sLineBreak);
  fIntfBuff.WriteString('// See the License for the specific language governing permissions and' +
    sLineBreak);
  fIntfBuff.WriteString('// limitations under the License.' + sLineBreak);
  fIntfBuff.WriteString('//' + sLineBreak);
  fIntfBuff.WriteString
    ('// ***************************************************************************' + sLineBreak);
  fIntfBuff.WriteString(sLineBreak);
end;

procedure TMainForm.EmitProperty(const FieldName: String; const FieldDataType: TFieldType);
var
  lProp: string;
begin
  // if GetFieldName(F.FieldName).Substring(1).ToLower <> F.FieldName then
  // begin
  // lProp := Format('[MVCNameAs(''%s'')]', [F.FieldName]) + sLineBreak + INDENT + INDENT;
  // end;
  lProp := lProp + 'property ' + GetFieldName(FieldName).Substring(1) { remove f } + ': ' +
    GetDelphiType(FieldDataType) + ' read ' + GetFieldName(FieldName) + ' write ' +
    GetFieldName(FieldName) + ';' +
    sLineBreak;

  if GetDelphiType(FieldDataType).ToUpper.Contains('UNSUPPORTED TYPE') then
  begin
    lProp := '  //' + lProp
  end
  else
  begin
    lProp := '  ' + lProp;
  end;
  fIntfBuff.WriteString(INDENT + lProp)
end;

procedure TMainForm.EmitUnit;
begin
  fIntfBuff.WriteString('unit EntitiesU;' + sLineBreak);
  fIntfBuff.WriteString('' + sLineBreak);
  fIntfBuff.WriteString('interface' + sLineBreak);
  fIntfBuff.WriteString('' + sLineBreak);
  fIntfBuff.WriteString('uses' + sLineBreak);
  fIntfBuff.WriteString('  MVCFramework.Serializer.Commons,' + sLineBreak);
  fIntfBuff.WriteString('  MVCFramework.ActiveRecord,' + sLineBreak);
  fIntfBuff.WriteString('  System.Classes;' + sLineBreak);
  fIntfBuff.WriteString('' + sLineBreak);
  fIntfBuff.WriteString('type' + sLineBreak);
  fIntfBuff.WriteString('' + sLineBreak);

  fImplBuff.WriteString('implementation' + sLineBreak + sLineBreak);

  fInitializationBuff.WriteString('initialization' + sLineBreak + sLineBreak);
end;

procedure TMainForm.EmitUnitEnd;
begin
  fInitializationBuff.WriteString(sLineBreak + 'end.');
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  fIntfBuff.Free;
  fImplBuff.Free;
  fInitializationBuff.Free;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  fIntfBuff := TStringStream.Create;
  fImplBuff := TStringStream.Create;
  fInitializationBuff := TStringStream.Create;
  FHistoryFileName := TPath.Combine(TPath.GetDocumentsPath,
    TPath.GetFileNameWithoutExtension(ParamStr(0)) +
    '.history');
  try
    if TFile.Exists(FHistoryFileName) then
    begin
      mmConnectionParams.Lines.LoadFromFile(FHistoryFileName)
    end;
  except

  end;

  FDManager.LoadConnectionDefFile;
  FDManager.GetConnectionNames(cboConnectionDefs.Items);
end;

function TMainForm.GetClassName(const aTableName: string): string;
var
  lTableName: string;
  lNextLetter: Integer;
  lNextLetterChar: string;
begin
  lTableName := aTableName.ToLower.DeQuotedString('"').Replace(' ', '_', [rfReplaceAll]);
  Result := 'T' + lTableName.Substring(0, 1).ToUpper + lTableName.Substring(1).ToLower;

  while Result.IndexOf('_') > -1 do
  begin
    lNextLetter := Result.IndexOf('_') + 1;
    lNextLetterChar := UpperCase(Result.Chars[lNextLetter]);
    Result := Result.Remove(Result.IndexOf('_') + 1, 1);
    Result := Result.Insert(Result.IndexOf('_') + 1, lNextLetterChar);
    Result := Result.Remove(Result.IndexOf('_'), 1);
  end;
end;

function TMainForm.GetDelphiType(FT: TFieldType): string;
begin
  case FT of
    ftString, ftMemo, ftFmtMemo, ftWideMemo:
      Result := 'String';
    ftSmallint, ftInteger, ftWord, ftLongWord, ftShortint:
      Result := 'Integer';
    ftByte:
      Result := 'Byte';
    ftLargeint:
      Result := 'Int64';
    ftBoolean:
      Result := 'Boolean';
    ftFloat, TFieldType.ftSingle, TFieldType.ftExtended:
      Result := 'Double';
    ftCurrency, ftBCD, ftFMTBcd:
      Result := 'Currency';
    ftDate:
      Result := 'TDate';
    ftTime:
      Result := 'TTime';
    ftDateTime:
      Result := 'TDateTime';
    ftTimeStamp:
      Result := 'TDateTime {timestamp}';
    ftAutoInc:
      Result := 'Integer {autoincrement}';
    ftBlob, { ftMemo, } ftGraphic, { ftFmtMemo, ftWideMemo, } ftStream:
      Result := 'TStream';
    ftFixedChar:
      Result := 'String {fixedchar}';
    ftWideString:
      Result := 'String';
    ftGuid:
      Result := 'TGuid';
    ftDBaseOle:
      Result := 'String {ftDBaseOle}';
  else
    Result := '<UNSUPPORTED TYPE: ' + GetEnumName(TypeInfo(TFieldType), Ord(FT)) + '>';
  end;
end;

function TMainForm.GetFieldName(const Value: string): string;
var
  Pieces: TArray<string>;
  Piece: string;
begin
  if Value.Length <= 2 then
  begin
    Exit('f' + Value.ToUpper);
  end;

//  Result := '';
//  Pieces := Value.ToLower.Split(['_'], TStringSplitOptions.ExcludeEmpty);
//  for Piece in Pieces do
//  begin
//    if Piece = 'id' then
//      Result := Result + 'ID'
//    else
//      Result := Result + UpperCase(Piece.Chars[0]) + Piece.Substring(1);
//  end;
  Result := 'f' + Value; //CamelCase(Value, True);
end;

function TMainForm.GetUniqueFieldNames(const Fields: TFields; const FormatAsPascalCase: Boolean): TArray<String>;
var
  I: Integer;
  lList: TStringList;
  lF: string;
  lFTemp: string;
  lCount: Integer;
begin
  SetLength(Result, Fields.Count);
  lList := TStringList.Create;
  try
    lList.Sorted := True;
    for I := 0 to Fields.Count - 1 do
    begin
      lCount := 0;
      if FormatAsPascalCase then
      begin
        lF := CamelCase(Fields[I].FieldName, True);
      end
      else
      begin
        lF := Fields[I].FieldName;
      end;
      if lList.IndexOf(lF) > -1 then
      begin
        lF := Fields[I].FieldName;
      end;
      lFTemp := lF;

      if IsReservedKeyword(lFTemp) then
      begin
        lFTemp := '_' + lFTemp;
      end;

      while (lList.IndexOf(lFTemp) > -1) do
      begin
        Inc(lCount);
        lFTemp := lF + '__' + IntToStr(lCount);
      end;
      lF := lFTemp;
      lList.Add(lF);
      Result[I] := lF;
    end;
  finally
    lList.Free;
  end;
end;

procedure TMainForm.lstCatalogDblClick(Sender: TObject);
begin
  lstSchema.Items.Clear;
  FDConnection1.GetSchemaNames(lstCatalog.Items[lstCatalog.ItemIndex], '', lstSchema.Items);
end;

procedure TMainForm.lstSchemaDblClick(Sender: TObject);
begin
  btnGetTablesClick(Self);
end;

procedure TMainForm.mmConnectionParamsChange(Sender: TObject);
begin
  FDConnection1.Close;
  lstSchema.Clear;
  lstCatalog.Clear;
end;

function TMainForm.SelectTables(const FromLetter, ToLetter: AnsiChar): Integer;
var
  lFirstChar: AnsiChar;
  lLetters: set of AnsiChar;
  I: Integer;
  lSelectedTables: Integer;
begin
  lLetters := [];
  for I := Ord(FromLetter) to Ord(ToLetter) do
  begin
    lLetters := lLetters + [Chr(I)];
  end;

  lSelectedTables := 0;
  dsTablesMapping.First;
  while not dsTablesMapping.Eof do
  begin
    lFirstChar := AnsiChar(dsTablesMappingTABLE_NAME.AsString.ToUpper.Chars[0]);
    if lFirstChar in lLetters then
    begin
      dsTablesMapping.Edit;
      dsTablesMappingGENERATE.Value := True;
      dsTablesMapping.Post;
      Inc(lSelectedTables);
    end;
    dsTablesMapping.Next;
  end;
  dsTablesMapping.First;
  Result := lSelectedTables;
end;

procedure TMainForm.SpeedButton1Click(Sender: TObject);
begin
  DoSelection(stAll);
end;

procedure TMainForm.SpeedButton2Click(Sender: TObject);
begin
  DoSelection(stNone);
end;

procedure TMainForm.SpeedButton3Click(Sender: TObject);
begin
  DoSelection(stInverse);
end;

end.
