unit CncFileManagerDevice;

interface

uses
  SysUtils, Classes, ComCtrls,
  JvAppStorage, JvAppIniStorage;

type
  TCncFileManagerDevice = class(TComponent)
    constructor Create(AOwner : TComponent); override;
  private
    FDeviceName : string;
    FIniStorage : TJvCustomAppMemoryFileStorage;
    FDirList    : TListItems;
    function  GetMachineSelected : integer; virtual;
    procedure SetMachineSelected(Value : integer); virtual;
  protected
  public
    procedure GetMachineCollection(Dest : TCollection); virtual;
    property  DeviceName : string read FDeviceName write FDeviceName;
    property  MachineSelected : integer read GetMachineSelected write SetMachineSelected;
    property  DirList : TListItems read FDirList;
  end;

type
  TDiskFileManagerDevice = class(TCncFileManagerDevice)
    constructor Create(AOwner : TComponent; ADisk : string);
  private
    FDisk : string;
  public
    property Disk : string read FDisk;
  end;

procedure Register;

implementation

constructor TCncFileManagerDevice.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FDeviceName := '';
  FDirList := TListItems.Create(nil);
  FIniStorage := nil;
end;

function  TCncFileManagerDevice.GetMachineSelected : integer;
begin
  result := FIniStorage.ReadInteger('MACHINE\MachineSelected', -1);
end;

procedure TCncFileManagerDevice.SetMachineSelected(Value : integer);
begin
  FIniStorage.WriteInteger('MACHINE\MachineSelected', Value);
end;

procedure TCncFileManagerDevice.GetMachineCollection(Dest : TCollection);
begin
  FIniStorage.ReadCollection('MACHINE', Dest, True, 'Cnc');
end;


constructor TDiskFileManagerDevice.Create(AOwner : TComponent; ADisk : string);
begin
  inherited Create(AOwner);
  FDisk := ADisk;
  FIniStorage := TJvAppIniFileStorage.Create(AOwner);
  FIniStorage.Path := 'ROOT';
  FIniStorage.Location := flCustom;
  FIniStorage.FileName := ADisk+'\SYSTEM\CncFileManager.ini';
  FDeviceName := FIniStorage.ReadString('DeviceName', 'Unknown device');
end;


procedure Register;
begin
  RegisterComponents('Exemples', [TCncFileManagerDevice]);
end;

end.
