unit EditorWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CHILDWIN, AdvMemo, StdCtrls, AdvCodeList;

type
  TMDIEditor = class(TMDIChild)
    AdvMemo1: TAdvMemo;
    AdvCodeList1: TAdvCodeList;
  private
    { D�clarations priv�es }
  public
    { D�clarations publiques }
  end;

var
  MDIEditor: TMDIEditor;

implementation

{$R *.dfm}

end.
