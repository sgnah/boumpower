object Form1: TForm1
  Left = 198
  Top = 114
  Width = 706
  Height = 390
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ClientRB: TJvRadioButton
    Left = 48
    Top = 40
    Width = 47
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Client'
    TabOrder = 0
    OnClick = ClientServerClick
    HotTrackFont.Charset = DEFAULT_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'MS Sans Serif'
    HotTrackFont.Style = []
    LinkedControls = <>
  end
  object ServerRB: TJvRadioButton
    Left = 112
    Top = 40
    Width = 52
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Server'
    Checked = True
    TabOrder = 1
    TabStop = True
    OnClick = ClientServerClick
    HotTrackFont.Charset = DEFAULT_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'MS Sans Serif'
    HotTrackFont.Style = []
    LinkedControls = <>
  end
  object HostEdit: TJvEdit
    Left = 128
    Top = 72
    Width = 241
    Height = 21
    TabOrder = 2
    Text = 'HostEdit'
  end
  object HostText: TJvStaticText
    Left = 48
    Top = 72
    Width = 35
    Height = 17
    Caption = 'Server'
    HotTrackFont.Charset = DEFAULT_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'MS Sans Serif'
    HotTrackFont.Style = []
    Layout = tlTop
    TabOrder = 3
    TextMargins.X = 0
    TextMargins.Y = 0
    WordWrap = False
  end
  object PortText: TJvStaticText
    Left = 48
    Top = 136
    Width = 23
    Height = 17
    Caption = 'Port'
    HotTrackFont.Charset = DEFAULT_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'MS Sans Serif'
    HotTrackFont.Style = []
    Layout = tlTop
    TabOrder = 4
    TextMargins.X = 0
    TextMargins.Y = 0
    WordWrap = False
  end
  object PortEdit: TJvEdit
    Left = 128
    Top = 136
    Width = 121
    Height = 21
    TabOrder = 5
    Text = '4000'
  end
  object RemoteEdit: TJvEdit
    Left = 128
    Top = 104
    Width = 241
    Height = 21
    Enabled = False
    TabOrder = 6
    Text = 'Remote'
  end
  object RemoteText: TJvStaticText
    Left = 48
    Top = 104
    Width = 30
    Height = 17
    Caption = 'Client'
    HotTrackFont.Charset = DEFAULT_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'MS Sans Serif'
    HotTrackFont.Style = []
    Layout = tlTop
    TabOrder = 7
    TextMargins.X = 0
    TextMargins.Y = 0
    WordWrap = False
  end
  object ConnectBtn: TJvBitBtn
    Left = 88
    Top = 176
    Width = 185
    Height = 25
    Caption = 'Connect'
    TabOrder = 8
    OnClick = ConnectBtnClick
    HotTrackFont.Charset = DEFAULT_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'MS Sans Serif'
    HotTrackFont.Style = []
  end
  object StatusCB: TJvCheckBox
    Left = 56
    Top = 224
    Width = 65
    Height = 17
    Caption = 'StatusCB'
    Enabled = False
    TabOrder = 9
    LinkedControls = <>
    HotTrackFont.Charset = DEFAULT_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'MS Sans Serif'
    HotTrackFont.Style = []
  end
  object Memo: TJvMemo
    Left = 376
    Top = 16
    Width = 297
    Height = 321
    Enabled = False
    TabOrder = 10
  end
  object SendEdit: TJvEdit
    Left = 48
    Top = 256
    Width = 225
    Height = 21
    Enabled = False
    TabOrder = 11
  end
  object SendBtn: TJvBitBtn
    Left = 280
    Top = 256
    Width = 75
    Height = 25
    Caption = 'Send'
    Enabled = False
    TabOrder = 12
    OnClick = SendBtnClick
    HotTrackFont.Charset = DEFAULT_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'MS Sans Serif'
    HotTrackFont.Style = []
  end
  object RcvBtn: TJvBitBtn
    Left = 280
    Top = 288
    Width = 75
    Height = 25
    Caption = 'Rcv'
    Enabled = False
    TabOrder = 13
    Visible = False
    OnClick = RcvBtnClick
    HotTrackFont.Charset = DEFAULT_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'MS Sans Serif'
    HotTrackFont.Style = []
  end
  object JvAppXMLFileStorage1: TJvAppXMLFileStorage
    StorageOptions.BooleanStringTrueValues = 'TRUE, YES, Y'
    StorageOptions.BooleanStringFalseValues = 'FALSE, NO, N'
    StorageOptions.InvalidCharReplacement = '_'
    RootNodeName = 'Configuration'
    SubStorages = <>
    Left = 528
    Top = 40
  end
  object IdTCPServer1: TIdTCPServer
    Bindings = <>
    CommandHandlers = <>
    CommandHandlersEnabled = False
    DefaultPort = 0
    Greeting.NumericCode = 0
    MaxConnectionReply.NumericCode = 0
    MaxConnections = 1
    OnConnect = IdTCPServer1Connect
    OnExecute = IdTCPServer1Execute
    OnDisconnect = IdTCPServer1Disconnect
    ReplyExceptionCode = 0
    ReplyTexts = <>
    ReplyUnknownCommand.NumericCode = 0
    Left = 400
    Top = 40
  end
  object IdTCPClient1: TIdTCPClient
    OnStatus = IdTCPClient1Status
    MaxLineAction = maException
    ReadTimeout = 0
    OnDisconnected = IdTCPClient1Disconnected
    OnWork = IdTCPClient1Work
    OnConnected = IdTCPClient1Connected
    Port = 0
    Left = 432
    Top = 40
  end
end