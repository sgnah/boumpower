object MDIChild: TMDIChild
  Left = 248
  Top = 164
  Width = 661
  Height = 417
  Caption = 'Nouveau'
  Color = clBtnFace
  ParentFont = True
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 653
    Height = 41
    Align = alTop
    Caption = 'Zone d'#39'information'
    TabOrder = 0
  end
  object PanelBot: TPanel
    Left = 0
    Top = 349
    Width = 653
    Height = 41
    Align = alBottom
    Caption = 'PanelBot'
    TabOrder = 1
    DesignSize = (
      653
      41)
    object EditNO: TEdit
      Left = 0
      Top = 8
      Width = 57
      Height = 21
      AutoSize = False
      Enabled = False
      TabOrder = 0
      Text = 'EditNO'
    end
    object EditOP: TEdit
      Left = 72
      Top = 8
      Width = 449
      Height = 21
      Anchors = [akLeft, akRight]
      TabOrder = 1
    end
    object BtnOK: TBitBtn
      Left = 525
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight]
      TabOrder = 2
      OnClick = BtnOKClick
      Kind = bkOK
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 41
    Width = 653
    Height = 308
    Align = alClient
    Caption = 'PanelMid'
    TabOrder = 2
    object StringGrid1: TStringGrid
      Left = 1
      Top = 1
      Width = 651
      Height = 306
      Align = alClient
      ColCount = 12
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
      TabOrder = 0
      OnClick = StringGrid1Click
    end
  end
  object XMLData: TJvSimpleXML
    IndentString = '  '
    Left = 592
    Top = 24
  end
end
