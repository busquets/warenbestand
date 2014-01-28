unit datenbank;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LR_Desgn, Forms, Controls, Graphics, Dialogs,
  DBGrids, StdCtrls, DbCtrls, ExtCtrls, Buttons, Arrow, Menus, ActnList, sqldb,
  sqlite3conn, db, LR_Class, LR_DBSet, LR_View, LR_DSet, LR_E_HTM, lr_e_pdf,
  LCLType, Grids, ComCtrls, process, HTTPSend, Synacode, synautil, LConvEncoding;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    BitBtn8: TBitBtn;
    Datasource1: TDatasource;
    Datasource2: TDatasource;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    DBEdit4: TDBEdit;
    DBEdit5: TDBEdit;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    frDBDataSet1: TfrDBDataSet;
    frReport1: TfrReport;
    frTNPDFExport1: TfrTNPDFExport;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ListView1: TListView;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Process1: TProcess;
    SaveDialog1: TSaveDialog;
    SQLite3Connection1: TSQLite3Connection;
    SQLite3Connection2: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLQuery2: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    SQLTransaction2: TSQLTransaction;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure DBEdit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DBEdit2KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure SQLQuery1AfterDelete(DataSet: TDataSet);
    procedure SQLQuery1AfterEdit(DataSet: TDataSet);
    procedure SQLQuery1AfterInsert(DataSet: TDataSet);
  private
    { private declarations }
  public
    { public declarations }
  end;

  function soneparsearch(suche: string; exakt:String; const ResultData: TStrings): Boolean;
  procedure parsen(const htmlstrings: TStrings; const extract: TStrings);

var
  Form1: TForm1;
  configfile: String;
  pfade: TStringList;
  cookies: TStrings;

implementation

{$R *.lfm}

{ TForm1 }


function soneparsearch(suche: string; exakt:String; const ResultData: TStrings): Boolean;
var http : THTTPSend; Params:String;
    erfolg:Boolean;
begin
      http := THTTPSend.Create;
      Params :=
      'exactSearch=' + EncodeURLElement(exakt) + '&' +
      'showDisableNetto=' + EncodeURLElement('off') + '&' +
      'action=' + EncodeURLElement('actionSearch') + '&' +
      'catalogId=' + EncodeURLElement('0') + '&' +
      'searchString=' + EncodeURLElement(suche)+ '&' +
      'showCartInsert=' + EncodeURLElement('false') + '&' +
      'selectedCart=' + EncodeURLElement('4');
      WriteStrToStream(http.Document, Params);
      http.MimeType := 'application/x-www-form-urlencoded';
      http.Cookies.AddStrings(cookies);
      try
        erfolg := http.HTTPMethod('POST','http://www.sonepar.de/shop/search/resultNew.do');
        if erfolg then begin
           //ResultData := TStringList.Create;
           ResultData.LoadFromStream(http.Document);
        end;
      finally
          http.Free;
      end;
      Result:=erfolg;
end;

procedure parsen(const htmlstrings: TStrings; const extract: TStrings);
var zeile,trclass,spalte,spaltennr,inhaltzeile,zeichen:Integer;
    utf8zeile,inhalt,inhaltvorher:String;
    leer,leer2,htmltag,htmltag2,tab:Boolean;
    parsed: TStrings;
begin
  //parsen
  parsed := TStringList.Create;
  trclass:=0;spalte:=0;inhaltzeile:=0;
   for zeile:=0 to htmlstrings.Count-1 do begin
      utf8zeile:=ISO_8859_15ToUTF8(htmlstrings[zeile]);
      if Pos('<tr class="data',utf8zeile) > 0 then begin
         trclass:=1;
         //Artikel anfang
          parsed.Append('Artikelanfang');
         spaltennr:=0;
      end;
      if trclass>0 then begin
      //Daten
             if Pos('</tr',utf8zeile) > 0 then trclass:=trclass-1;
             if Pos('<tr',utf8zeile) > 0 then trclass:=trclass+1;
             if Pos('<td',utf8zeile) > 0 then begin
                if spalte=0 then begin
                   spalte:=spalte+1;
                   //Spalte anfang
                   spaltennr:=spaltennr+1;
                   inhaltzeile:=0;
                end;
                spalte:=spalte+1;
             end;
             if spalte>1 then begin
                if spaltennr=2 then begin
                   //artikelnummer
                  parsed.Append('artikelnummer');
                  zeichen:=Pos('>',utf8zeile)+1;
                  if (zeichen=0) or (zeichen>(Length(utf8zeile)-2))  then zeichen:=Pos(' ',utf8zeile)+1;
                  parsed.Append(Copy(utf8zeile,zeichen,Length(utf8zeile)-zeichen-1))
                  // parsed.Append('/artikelnummer')
                end
                else if spaltennr=3 then begin
                   //Artikelbezeichnung
                   if inhaltzeile=0 then if Pos('<tr',utf8zeile) > 0 then inhaltzeile:=2;
                   if Pos('</tr',utf8zeile) > 0 then inhaltzeile:=1;
                   if inhaltzeile=2 then begin
                      parsed.Append('artikel');
                      parsed.Append(utf8zeile);
                      //parsed.Append('/artikel');
                   end;
                end
                else if spaltennr=4 then begin
                   //Preis
                  parsed.Append('preis');
                  parsed.Append(utf8zeile);
                  //parsed.Append('/preis');
                end;
                if Pos('</td',utf8zeile) > 0 then spalte:=spalte-1;
             end;
             if spalte=1 then begin
                 spalte:=0;
             end;
             if trclass<2 then begin
                //'Artikel ende'
                trclass:=0;
                spalte:=0;
             end;
      end;
   end;
   //parsen ende
   //tags löschen:
   inhaltvorher:='';
 for zeile:=0 to parsed.Count-1 do begin
    inhalt:='';
    leer:=true;leer2:=false;htmltag:=false;tab:=false;htmltag2:=false;
    for zeichen:=1 to (Length(parsed[zeile])) do begin
       if parsed[zeile][zeichen]='<' then htmltag:=true
       else if parsed[zeile][zeichen]='>' then htmltag:=false
       else if parsed[zeile][zeichen]=#9 then tab:=true
       else if parsed[zeile][zeichen]=' ' then begin
          //leerzeichen
          if leer then leer2:=true;
          leer:=true;
       end;
       if parsed[zeile][zeichen]<>' ' then begin
          leer:=false;
          leer2:=false;
       end;
       if parsed[zeile][zeichen]<>#9 then tab:=false;
       if htmltag then htmltag2:=true;
       if (leer2=false) and (tab=false) and (htmltag2=false) then inhalt:=inhalt+parsed[zeile][zeichen];
       if htmltag=false then htmltag2:=false;
    end;
    //if (inhalt<>' ') and (inhalt<>'') then begin
    if inhalt='Artikelanfang' then extract.Append(inhalt)
    else if (inhaltvorher='artikelnummer') or (inhaltvorher='artikel') or (inhaltvorher='preis') then
      if (inhalt<>'artikelnummer') and (inhalt<>'artikel') and (inhalt<>'preis') and (inhalt<>' ') and (inhalt<>'') then begin
             //leerzeichen am ende
             while inhalt[Length(inhalt)]=' ' do Delete(inhalt, Length(inhalt), 1);
             extract.Append(inhaltvorher);
             extract.Append(inhalt);
      end;
      inhaltvorher:=inhalt;
    //end;
 end;
 parsed.Free;
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
if BitBtn3.Enabled then
if MessageDlg('Bestätigung', 'Soll die Datenbank gespeichert werden?', mtConfirmation, [mbYes, mbNo],0) = mrYes
  then begin
     BitBtn3.Enabled:=false;
     If SQLQuery1.Active then begin
        Datasource1.Edit;
        try
           DBEdit5.Text:=FloatToStr(SQLQuery1.FieldByName('Einzelpreis').AsFloat * SQLQuery1.FieldByName('Menge').AsInteger);
        except ShowMessage('Kein gültiger Preis');
        end;
        SQLQuery1.ApplyUpdates;
        SQLTransaction1.Commit;
     end;
  end;
  SQLQuery1.Close;
  SQLTransaction1.Active := False;
  SQLite3Connection1.Connected := false;
  If (OpenDialog1.Execute) then SQLite3Connection1.DatabaseName:=OpenDialog1.FileName;
  try
     SQLite3Connection1.Connected := true;
     SQLTransaction1.Active := true;
     SQLQuery1.Open;
     pfade[0]:=SQLite3Connection1.DatabaseName;
     Caption:=SQLite3Connection1.DatabaseName;
  except ShowMessage('Die Datenbank '+ SQLite3Connection1.DatabaseName + ' konnte nicht geladen werden');
  end;
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  if BitBtn3.Enabled then
  if MessageDlg('Bestätigung', 'Sollen die letzten Änderungen gespeichert werden?', mtConfirmation, [mbYes, mbNo],0) = mrYes
    then begin
       BitBtn3.Enabled:=false;
       If SQLQuery1.Active then begin
          SQLQuery1.ApplyUpdates;
          SQLTransaction1.Commit;
       end;
    end;
    SQLQuery1.Close;
    SQLTransaction1.Active := False;
    SQLite3Connection1.Connected := false;
  If (SaveDialog1.Execute) then begin
     if SaveDialog1.FileName=SQLite3Connection1.DatabaseName then ShowMessage('Die Backup Datei muss eine neue Datei sein')
     else begin
        try
          CopyFile(SQLite3Connection1.DatabaseName,SaveDialog1.FileName,false);
        except ShowMessage('Datei ' + SaveDialog1.FileName + ' kann nicht angelegt werden');
        end;
     end;
  end;
  SQLite3Connection1.DatabaseName:=pfade[0];
  try
     SQLite3Connection1.Connected := true;
     SQLTransaction1.Active := true;
     SQLQuery1.Open;
  except ShowMessage('Die Datenbank ' + SQLite3Connection1.DatabaseName + ' konnte nicht geladen werden');
  end;
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
begin
  frReport1.LoadFromFile ('/usr/share/warenbestand/report.lrf');
  frReport1.PrepareReport;
  //frReport1.ExportTo(TfrTNPDFExportFilter, 'Report.pdf');
  //Process1.Execute;
  frReport1.ShowReport;
end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.MenuItem8Click(Sender: TObject);
begin
   If (OpenDialog1.Execute) then begin
      SQLite3Connection2.Connected := false;
      SQLTransaction2.Active := false;
      SQLQuery2.Close;
      pfade[1]:=OpenDialog1.FileName;
      SQLite3Connection2.DatabaseName:=pfade[1];
      try
        SQLite3Connection2.Connected := true;
        SQLTransaction2.Active := true;
        SQLQuery2.Open;
      except ShowMessage('Die Datenbank ' + SQLite3Connection2.DatabaseName + ' konnte nicht geladen werden');
      end;
   end;
end;

procedure TForm1.MenuItem9Click(Sender: TObject);
begin
frReport1.LoadFromFile ('/usr/share/warenbestand/report.lrf');
frReport1.PrepareReport;
frReport1.ExportTo(TfrTNPDFExportFilter, 'Report.pdf');
Process1.Execute;

end;

procedure TForm1.SQLQuery1AfterDelete(DataSet: TDataSet);
begin
   BitBtn3.Enabled:=true;
end;

procedure TForm1.SQLQuery1AfterEdit(DataSet: TDataSet);
begin
  BitBtn3.Enabled:=true;
end;

procedure TForm1.SQLQuery1AfterInsert(DataSet: TDataSet);
begin
   BitBtn3.Enabled:=true;
    try
      DBEdit5.Text:=FloatToStr(SQLQuery1.FieldByName('Einzelpreis').AsFloat * SQLQuery1.FieldByName('Menge').AsInteger);
    except ShowMessage('Kein gültiger Preis');
    end;
end;


procedure TForm1.DBEdit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    If SQLQuery2.Active then begin
       SQLQuery2.Active:=false;
       SQLQuery2.SQL.Clear;
       SQLQuery2.SQL.Append('SELECT * FROM Waren');
       SQLQuery2.SQL.Append('WHERE Artikel LIKE "%' + DBEdit1.Text + '%"');
       SQLQuery2.SQL.Append('ORDER BY Artikel');
       SQLQuery2.Active:=true;
    end;
end;



procedure TForm1.DBEdit2KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   If SQLQuery2.Active then begin
      //SQLQuery2.Locate('Artikelnummer',DBEdit2.Text,[loPartialKey,loCaseInsensitive]);
     //ORDER BY Artikelnummer
      SQLQuery2.Active:=false;
      SQLQuery2.SQL.Clear;
      SQLQuery2.SQL.Append('SELECT * FROM Waren');
      SQLQuery2.SQL.Append('WHERE Artikelnummer LIKE "' + DBEdit2.Text + '%"');
      SQLQuery2.SQL.Append('ORDER BY Artikelnummer;');
      SQLQuery2.Active:=true;
  end;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
 If SQLQuery1.Active then begin
    Datasource1.Edit;
    try
      DBEdit5.Text:=FloatToStr(SQLQuery1.FieldByName('Einzelpreis').AsFloat * SQLQuery1.FieldByName('Menge').AsInteger);
    except ShowMessage('Kein gültiger Preis');
    end;
  //  If SQLQuery1.RecNo>=SQLQuery1.RecordCount
    if SQLQuery1.EOF then begin
       SQLQuery1.Append;
       SQLQuery1.Post;
    end
   else begin
      SQLQuery1.Next;
      if SQLQuery1.EOF then begin
         SQLQuery1.Append;
         SQLQuery1.Post;
      end;
   end;
 end;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
 If SQLQuery2.Active then If SQLQuery1.Active then begin
  //if SQLQuery1.CanModify=false then SQLQuery1.Append;
  Datasource1.Edit;
  SQLQuery1.FieldByName('Artikelnummer').Text:=SQLQuery2.FieldByName('Artikelnummer').Text;
  SQLQuery1.FieldByName('Artikel').Text:=SQLQuery2.FieldByName('Artikel').Text;
  SQLQuery1.FieldByName('Einzelpreis').Text:=SQLQuery2.FieldByName('Einzelpreis').Text;
 end;
end;

procedure TForm1.BitBtn3Click(Sender: TObject);
var aktueller_Datensatz:longInt;
begin
  BitBtn3.Enabled:=false;
   If SQLQuery1.Active then begin
    Datasource1.Edit;
    try
      DBEdit5.Text:=FloatToStr(SQLQuery1.FieldByName('Einzelpreis').AsFloat * SQLQuery1.FieldByName('Menge').AsInteger);
    except ShowMessage('Kein gültiger Preis');
    end;
  aktueller_Datensatz:=SQLQuery1.RecNo;
  SQLQuery1.ApplyUpdates;
  SQLTransaction1.Commit;
  SQLTransaction1.Active := true;
  SQLQuery1.Open;
  if aktueller_Datensatz = 0 then SQLQuery1.Last
  else SQLQuery1.RecNo:=aktueller_Datensatz;
  end;
  BitBtn3.Enabled:=false;
end;

procedure TForm1.BitBtn4Click(Sender: TObject);
begin
If SQLQuery1.Active then if SQLQuery1.IsEmpty=false then SQLQuery1.Delete;
end;

procedure TForm1.BitBtn5Click(Sender: TObject);
begin
If SQLQuery1.Active then begin
    if ListView1.Selected<>nil then begin
       Datasource1.Edit;
       SQLQuery1.FieldByName('Artikelnummer').Text:=ListView1.Selected.Caption;
       SQLQuery1.FieldByName('Artikel').Text:=ListView1.Selected.SubItems[0];
       try
          SQLQuery1.FieldByName('Einzelpreis').Text:=ListView1.Selected.SubItems[1];
       except ShowMessage('Kein gültiger Preis');
       end;
    end;
end;
end;

procedure TForm1.BitBtn6Click(Sender: TObject);
begin
   If SQLQuery1.Active then begin
    Datasource1.Edit;
    try
      DBEdit5.Text:=FloatToStr(SQLQuery1.FieldByName('Einzelpreis').AsFloat * SQLQuery1.FieldByName('Menge').AsInteger);
    except ShowMessage('Kein gültiger Preis');
    end;
    SQLQuery1.Prior;
 end;
end;

procedure TForm1.BitBtn7Click(Sender: TObject);
begin
   If SQLQuery1.Active then begin
    Datasource1.Edit;
    try
      DBEdit5.Text:=FloatToStr(SQLQuery1.FieldByName('Einzelpreis').AsFloat * SQLQuery1.FieldByName('Menge').AsInteger);
    except ShowMessage('Kein gültiger Preis');
    end;
    SQLQuery1.Append;
    //Datasource1.Edit;
    SQLQuery1.Post;
   // SQLQuery1.ApplyUpdates;
 end;
end;

procedure TForm1.BitBtn8Click(Sender: TObject);
var i,zeilennr,artikelnummer:Integer; html,geparst:TStrings; suchstring,xmltag:String;
    exakt:String;
begin
 //nach Artikelnummer oder Artikel suchen
 if DBEdit2.Text='' then begin
    exakt:='off';
    suchstring:=DBEdit1.Text;
 end
 else begin
    exakt:='on';
    suchstring:=DBEdit2.Text;
 end;

xmltag:='';
html := TStringList.Create;
geparst := TStringList.Create;
ListView1.Clear;
zeilennr:=0;
if soneparsearch(suchstring, exakt, html) then begin
  ListView1.Items.Add;
  ListView1.Items.Item[ListView1.Items.Count-1].SubItems.Append('leer');
  ListView1.Items.Item[ListView1.Items.Count-1].SubItems.Append('leer');
  parsen(html, geparst);
  for i:=0 to geparst.Count-1 do begin
     if xmltag='Artikelanfang' then begin
        if  ListView1.Items.Item[ListView1.Items.Count-1].SubItems[0]<>'leer' then begin
          ListView1.Items.Add;
          ListView1.Items.Item[ListView1.Items.Count-1].SubItems.Append('leer');
          ListView1.Items.Item[ListView1.Items.Count-1].SubItems.Append('leer');
        end;
     end
     else if xmltag='artikelnummer' then begin
        ListView1.Items.Item[ListView1.Items.Count-1].Caption:=geparst[i];
     end
     else if xmltag='artikel' then begin
        if  ListView1.Items.Item[ListView1.Items.Count-1].SubItems[0]='leer' then
           ListView1.Items.Item[ListView1.Items.Count-1].SubItems[0]:=geparst[i];
     end
     else if xmltag='preis' then begin
           if geparst[i]<>'&nbsp;' then
              ListView1.Items.Item[ListView1.Items.Count-1].SubItems[1]:=geparst[i];
           //else  ListView1.Items.Item[ListView1.Items.Count-1].SubItems[1]:='leer';
     end;
     xmltag:=geparst[i];
  end;

  geparst.Free;
end;

html.Free;

ListView1.Selected:=ListView1.Items.Item[0];
end;


procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
if BitBtn3.Enabled then
if MessageDlg('Bestätigung', 'Soll die Datenbank gespeichert werden?', mtConfirmation, [mbYes, mbNo],0) = mrYes
  then begin
    If SQLQuery1.Active then begin
    Datasource1.Edit;
    try
      DBEdit5.Text:=FloatToStr(SQLQuery1.FieldByName('Einzelpreis').AsFloat * SQLQuery1.FieldByName('Menge').AsInteger);
    except ShowMessage('Kein gültiger Preis');
    end;
  SQLQuery1.ApplyUpdates;
  SQLTransaction1.Commit;

  end;

  end;
  SQLQuery1.Close;
  SQLTransaction1.Active := False;
  SQLite3Connection1.Connected := false;
  SQLQuery2.Close;
  SQLTransaction2.Active := False;
  SQLite3Connection2.Connected := false;
  if pfade[0]<>pfade[1] then pfade.SaveToFile(configfile);

  //sonepar logout
  MenuItem12Click(nil);
end;


procedure TForm1.FormCreate(Sender: TObject);
var dir:String;
begin
   dir:=GetAppConfigDir(False);
   if not DirectoryExists(dir) then CreateDir(dir);
   configfile:=dir+'pfade.conf';
   pfade := TStringList.Create;
   if not FileExists(configfile) then begin
   //first start
      pfade.Append('');pfade.Append('');pfade.Append('');pfade.Append('');
      ShowMessage('Bitte wählen Sie aus, wo der neue Warenbestand gespeichert werden soll.');
      MenuItem2Click(nil);
   end
   else begin
      pfade.LoadFromFile(configfile);
      SQLite3Connection1.DatabaseName:=pfade[0];
      SQLite3Connection2.DatabaseName:=pfade[1];
      Caption:=SQLite3Connection1.DatabaseName;
      if SQLite3Connection1.DatabaseName<>'' then begin
         try
           SQLite3Connection1.Connected := true;
           SQLTransaction1.Active := true;
           SQLQuery1.Open;
         except ShowMessage('Die Datenbank ' + SQLite3Connection1.DatabaseName + ' konnte nicht geladen werden');
         end;
      end;
      if SQLite3Connection2.DatabaseName<>'' then begin
         try
           SQLite3Connection2.Connected := true;
           SQLTransaction2.Active := true;
           SQLQuery2.Open;
         except ShowMessage('Die Datenbank ' + SQLite3Connection2.DatabaseName + ' konnte nicht geladen werden');
         end;
      end;
   end;
   cookies := TStringList.Create;
end;

procedure TForm1.MenuItem11Click(Sender: TObject);
var http:THTTPSend;
    Params:String;
    erfolg:Boolean;
    passwort,utf8zeile:String;
    html:TStrings;
    i:Integer;
begin
  if pfade[2]='' then begin
     InputQuery('Zugangsdaten für Sonepar', 'Kundennummer:', passwort);
     pfade[2]:=passwort;
     passwort:='';
     pfade.Append('');
     InputQuery('Zugangsdaten für Sonepar', 'Benutzername:', passwort);
     pfade[3]:=passwort;
     passwort:='';
     pfade.Append('');
     InputQuery('Zugangsdaten für Sonepar', 'Passwort:', passwort);
     pfade[4]:=passwort;
     pfade.Append('');
     pfade[5]:=passwort;
     passwort:='';
  end;

 //login
 //initial Cookies
  cookies.Clear;
  http := THTTPSend.Create;
  try
    erfolg := http.HTTPMethod('POST','http://www.sonepar.de/');
    if erfolg then cookies.AddStrings(http.Cookies);
  finally
    http.Free;
  end;

//Login Cookies
  http := THTTPSend.Create;
  Params := 'Kundennummer=' + EncodeURLElement(pfade[2]) + '&' +
             'usernames=' + EncodeURLElement(pfade[3])+ '&' +
             'password=' + EncodeURLElement(pfade[4]) + '&' +
             'rememberAccount=' + EncodeURLElement(pfade[5]);
  WriteStrToStream(http.Document, Params);
  http.MimeType := 'application/x-www-form-urlencoded';
  http.Cookies.AddStrings(cookies);
  try
    erfolg := http.HTTPMethod('GET','http://www.sonepar.de/shop/shop.jsp?Company=1&Organization=7&region=0&usernames='+pfade[3]+'&Kundennummer='+pfade[2]);
    if erfolg then cookies.AddStrings(http.Cookies);
  finally
    http.Free;
  end;

  //login testen
  html := TStringList.Create;
  if soneparsearch('', 'on', html) then begin
     for i:=0 to html.Count-1 do begin
        utf8zeile:=ISO_8859_15ToUTF8(html[i]);
        if Pos('Internal Server Error',utf8zeile) > 0 then Break;
     end;
     if i=html.Count-1 then BitBtn8.Enabled:=true;
     html.Free;
  end;
  if BitBtn8.Enabled=false then begin
     pfade[2]:='';
     ShowMessage('Login fehlgeschlagen');
  end;
end;

procedure TForm1.MenuItem12Click(Sender: TObject);
  var http : THTTPSend;
      erfolg:Boolean;
begin
  If cookies.Count>1 then begin
     http := THTTPSend.Create;
     http.Cookies.AddStrings(cookies);
     try
       erfolg := http.HTTPMethod('GET','http://www.sonepar.de/shop/logoff/logoff.do');
       BitBtn8.Enabled:=false;
     finally
       http.Free;
     end;
     cookies.Clear;
  end;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
if BitBtn3.Enabled then
if MessageDlg('Bestätigung', 'Soll die Datenbank gespeichert werden?', mtConfirmation, [mbYes, mbNo],0) = mrYes
  then begin
     BitBtn3.Enabled:=false;
     If SQLQuery1.Active then begin
        Datasource1.Edit;
        try
           DBEdit5.Text:=FloatToStr(SQLQuery1.FieldByName('Einzelpreis').AsFloat * SQLQuery1.FieldByName('Menge').AsInteger);
        except ShowMessage('Kein gültiger Preis');
        end;
        SQLQuery1.ApplyUpdates;
        SQLTransaction1.Commit;
     end;
  end;
  SQLQuery1.Close;
  SQLTransaction1.Active := False;
  SQLite3Connection1.Connected := false;
If (SaveDialog1.Execute) then
   if CopyFile('/usr/share/warenbestand/leer.sqlite',SaveDialog1.FileName,true) then
       SQLite3Connection1.DatabaseName:=SaveDialog1.FileName;
   try
      SQLite3Connection1.Connected := true;
      SQLTransaction1.Active := true;
      SQLQuery1.Open;
      pfade[0]:=SQLite3Connection1.DatabaseName;
      Caption:=SQLite3Connection1.DatabaseName;
   except ShowMessage('Die neue Datenbank ' + SQLite3Connection1.DatabaseName + ' konnte nicht geladen werden');
   end;
end;

end.

