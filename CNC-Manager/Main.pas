unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, Menus, StdCtrls, Buttons, ShellCtrls,
  ImgList, ExtActns, ActnList, StdActns, XPStyleActnCtrls, ActnMan,
  Lua, pLua, pLuaObject, LuaWrapper,
  JvComponentBase, JvAppStorage, JvAppIniStorage, JvAppStorageSelectList,
  JvFormPlacement,
  CncFileManagerDevice, JvgLanguageLoader, FileCtrl, JvDriveCtrls;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    Fichier: TMenuItem;
    FilePanel: TPanel;
    Splitter1: TSplitter;
    StatusBar: TStatusBar;
    PageControl1: TPageControl;
    MessagesTabSheet: TTabSheet;
    Splitter2: TSplitter;
    StatusPanel: TPanel;
    PCPanel: TPanel;
    Splitter3: TSplitter;
    CmdPanel: TPanel;
    Splitter4: TSplitter;
    CFPanel: TPanel;
    MsgMemo: TMemo;
    PCShellComboBox: TShellComboBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    PCDisplayBtn: TSpeedButton;
    PCDisplayMenu: TPopupMenu;
    PCBig: TMenuItem;
    PCSmall: TMenuItem;
    PCList: TMenuItem;
    PCDetail: TMenuItem;
    PCShellListView: TShellListView;
    CNCComboBox: TComboBoxEx;
    Pc2CncBtn: TBitBtn;
    ActionManager1: TActionManager;
    FileExit1: TFileExit;
    Quitter1: TMenuItem;
    Pc2CNC: TAction;
    AppIniFile: TJvAppIniFileStorage;
    JvFormStorage1: TJvFormStorage;
    CNCListView: TListView;
    procedure PCDisplayBtnClick(Sender: TObject);
    procedure PCBigClick(Sender: TObject);
    procedure PCSmallClick(Sender: TObject);
    procedure PCListClick(Sender: TObject);
    procedure PCDetailClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CNCComboBoxSelect(Sender: TObject);
  private
    FCncFileDevice : TCncFileManagerDevice;
  public
    procedure DisplayStatus(Msg : string);
    procedure DisplayMsg(Msg : string);
    procedure ReadSettings;
    procedure SaveSettings;
    procedure MountDiskDevice(Disk : string);
    procedure UnmountDevice;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.PCDisplayBtnClick(Sender: TObject);
var
  PopupPoint : TPoint;
  procedure UpdateMenu;
  var i : integer;
  begin
    for i := 0 to PCDisplayMenu.Items.Count-1 do begin
      PCDisplayMenu.Items[i].Checked := i=Ord(PCShellListView.ViewStyle)
    end;
  end;
begin
  PopupPoint := TSpeedButton(Sender).ClientOrigin;
  UpdateMenu;
  PCDisplayMenu.Popup(PopupPoint.X, PopupPoint.Y+20);
end;

procedure TMainForm.PCBigClick(Sender: TObject);
begin
  PCShellListView.ViewStyle := vsIcon;
end;

procedure TMainForm.PCSmallClick(Sender: TObject);
begin
  PCShellListView.ViewStyle := vsSmallIcon;
end;

procedure TMainForm.PCListClick(Sender: TObject);
begin
  PCShellListView.ViewStyle := vsList;
end;

procedure TMainForm.PCDetailClick(Sender: TObject);
begin
  PCShellListView.ViewStyle := vsReport;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ReadSettings;
  DisplayMsg(Lua.LUA_VERSION + ' - '+Lua.LUA_COPYRIGHT);
  MountDiskDevice('F:');
end;

procedure TMainForm.DisplayStatus(Msg : string);
begin
  StatusBar.SimpleText := Msg;
end;


procedure TMainForm.DisplayMsg(Msg : string);
begin
  MsgMemo.Lines.Add(Msg);
end;


procedure TMainForm.ReadSettings;
begin
end;

procedure TMainForm.SaveSettings;
begin
  AppIniFile.WriteString('DeviceName', 'CompactFlash');
  AppIniFile.WriteCollection('MACHINE', CNCComboBox.ItemsEx, 'Cnc');
  AppIniFile.WriteInteger('MACHINE\SelectedIndex', CNCComboBox.ItemIndex);
  AppIniFile.WriteString('MACHINE\SelectedName', CNCComboBox.Text);
  AppIniFile.WriteString('ShellPath', PCShellComboBox.Path);
end;


procedure TMainForm.CNCComboBoxSelect(Sender: TObject);
begin
  CNCListView.AddItem('A File', nil);
  FCncFileDevice.MachineSelected := CNCComboBox.ItemIndex;
  SaveSettings;
end;

procedure TMainForm.MountDiskDevice(Disk : string);
begin
  DisplayStatus('Mounting Disk Device '+Disk);
  FCncFileDevice := TDiskFileManagerDevice.Create(Self, Disk);

  Caption := 'CNC File Manager - ' + FCncFileDevice.DeviceName;

  FCncFileDevice.GetMachineCollection(CNCComboBox.ItemsEx);
  CNCComboBox.ItemIndex := FCncFileDevice.MachineSelected;

  DisplayMsg('Mounted : '+FCncFileDevice.DeviceName);

  // --->> CHECK for file changes !!!!
  DisplayStatus('Check for file changes...');
end;

procedure TMainForm.UnmountDevice;
begin
end;


end.
