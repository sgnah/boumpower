unit BootloaderDialog;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, Internal, Dialogs, JvDialogs, QTypes;

ResourceString
  rsSelectBootloader = '-- Select Bootloader --';
  rsConfigNone = '-- None --';
  rsConfigBoot = '-- Configuration from Bootloader --';
  rsConfigApp  = '-- Configuration from Application --';
  rsLoadFromFile = 'Load from file...';

type
  TBootloaderDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    OpenDialog: TJvOpenDialog;
    RadioGroup1: TRadioGroup;
    MCHPUSB: TRadioButton;
    HID: TRadioButton;
    VASCO: TRadioButton;
    FileSelectCB: TComboBox;
    RadioGroup2: TRadioGroup;
    AppSelectCB: TComboBox;
    RadioGroup3: TRadioGroup;
    ConfigSelectCB: TComboBox;
    GroupBox1: TGroupBox;
    RelocSelectCB: TComboBox;
    procedure BootloaderCheckClick(Sender: TObject);
    procedure SelectCBChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FBootloaderType : string;
    function GetConfigIndex : integer;
    function GetFileName(Index : integer) : string;
    function GetIsResourceFile(Index : integer) : boolean;
  public
    property BootloaderType : string read FBootloaderType;
    property ConfigIndex : integer read GetConfigIndex;
    property FileName[Index : integer] : string read GetFileName;
    property IsResourceFile[Index : integer] : boolean read GetIsResourceFile;
  end;

var
  BootloaderDlg: TBootloaderDlg;

implementation

{$R *.dfm}

procedure TBootloaderDlg.BootloaderCheckClick(Sender: TObject);
begin
  with FileSelectCB do begin
    Text := rsSelectBootloader;
    ItemIndex := -1;
    Items.Clear;
  end;
  with AppSelectCB do begin
    Text := '';
    ItemIndex := -1;
    Items.Clear;
    Enabled := false;
  end;
  with ConfigSelectCB do begin
    Text := '';
    ItemIndex := -1;
    Items.Clear;
    Enabled := false;
  end;

  if MCHPUSB.Checked then    FBootloaderType := 'MCHPUSB'
  else if HID.Checked then   FBootloaderType := 'HID'
  else if VASCO.Checked then FBootloaderType := 'VASCO'
  else exit;

  with FileSelectCB do begin
    InternalFAT.GetDirectoryInfo('BOOTLOADER.'+FBootloaderType, Items, true);
    Items.Add(rsLoadFromFile);
  end;

  with AppSelectCB do begin
    InternalFAT.GetDirectoryInfo('APPLICATION.'+FBootloaderType, Items, true);
    Items.Add(rsLoadFromFile);
    ItemIndex := 0;
    Enabled := true;
  end;
  with ConfigSelectCB do begin
    Items.Add(rsConfigNone);
    Items.Add(rsConfigBoot);
    Items.Add(rsConfigApp);
    InternalFAT.GetDirectoryInfo('CONFIG', Items, true);
    Items.Add(rsLoadFromFile);
    ItemIndex := 1;   // Config from bootloader by default
    Enabled := true;
  end;
end;

procedure TBootloaderDlg.SelectCBChange(Sender: TObject);
begin
  if not (Sender is TComboBox) then exit;
  with Sender as TComboBox do begin
    if (ItemIndex<>-1) and (ItemIndex = Items.Count-1) then begin
      if OpenDialog.Execute then
        with Items do begin
          if IndexOf(OpenDialog.FileName) = -1 then
            Insert(Items.Count-1, OpenDialog.FileName);
            ItemIndex := IndexOf(OpenDialog.FileName);
        end;
    end;
  end;
  OKBtn.Enabled :=  (FileSelectCB.ItemIndex >= 0);
end;

function TBootloaderDlg.GetConfigIndex : integer;
begin
  result := ConfigSelectCB.ItemIndex;
end;  


function TBootloaderDlg.GetFileName(Index : integer) : string;
begin
  result := '';
  case Index of
    0 : with RelocSelectCB do begin
          result := Text;
          if IsResourceFile[Index] then
            result := PFileInfo(Items.Objects[ItemIndex]).SR.Name;
        end;
    1 : with FileSelectCB do begin
          result := Text;
          if IsResourceFile[Index] then
            result := PFileInfo(Items.Objects[ItemIndex]).SR.Name;
        end;
    2 : with AppSelectCB do begin
          result := Text;
          if IsResourceFile[Index] then
            result := PFileInfo(Items.Objects[ItemIndex]).SR.Name;
        end;
    3 : with ConfigSelectCB do begin
          result := Text;
          if IsResourceFile[Index] then
            result := PFileInfo(Items.Objects[ItemIndex]).SR.Name;
        end;
  end;
end;

function TBootloaderDlg.GetIsResourceFile(Index : integer) : boolean;
begin
  result := false;
  case Index of
    0 : With RelocSelectCB do
          result := (ItemIndex >= 0) and (Items.Objects[ItemIndex] <> nil);
    1 : With FileSelectCB do
          result := (ItemIndex >= 0) and (Items.Objects[ItemIndex] <> nil);
    2 : With AppSelectCB do
          result := (ItemIndex >= 0) and (Items.Objects[ItemIndex] <> nil);
    3 : With ConfigSelectCB do
          result := (ItemIndex >= 0) and (Items.Objects[ItemIndex] <> nil);
  end;
end;


procedure TBootloaderDlg.FormCreate(Sender: TObject);
begin
  with RelocSelectCB do begin
    Items.Clear;
    InternalFAT.GetDirectoryInfo('RELOCATE', Items, true);
    Items.Add(rsLoadFromFile);
    ItemIndex := 0;
  end;
end;

end.
