unit PIC;

interface

uses Classes;

Const
  Tab = #$09;

Type
  TReverseCALM = class(TObject)
    private
      FProcessor     : string;  { nom du processeur }
      FWordBits      : integer; { nombre de bits par mots }
      FWordLen       : word;    { longeur d'un mot en m�moire }
      FMemorySize    : longint; { taille m�moire }

      FRegisterCount : word;
      FMnemonicList  : TStringList; // Mn�monics
      FRegisterList  : TStringList; // Registres du processeur
      FLabelList     : TStringList; // Labels pr�d�finis
      FSymbolList    : TStringList; // Table de Symbols
    protected
      function  ID_Label(Addrs : longint) : string;
      function  ID_Symbol(Reg : word) : string;
      function  GetWord(var Buffer; Addrs : longint) : pointer; virtual; abstract;
      procedure AddLabel(Addrs : longint; Name : string);
      function  GetLabel(Addrs : longint; MustCreate : boolean) : string;
      procedure AddRegister(Reg : word; Name : string);
      procedure AddSymbol(Reg : word; Name : string);
      function  GetSymbol(Reg : word; MustCreate : boolean) : string;
    public
      constructor Create;
      procedure   SetProcessor(ProcName : string); virtual; abstract;
      function    GetMnemonic(var X) : string; virtual; abstract;
      function    GetCALM(var Buffer; Addrs : longint) : string;
      procedure   BuildHeader(Dest : TStrings);
      procedure   BuildSymbolTable(Dest : TStrings);
      procedure   BuildSourceCALM(var Buffer; BufferSize : longint; Dest : TStrings);
    published
      property Processor : string read FProcessor write SetProcessor;
      property WordBits : integer read FWordBits;
      property WordLen   : word read FWordLen;
      property MemorySize : longint read FMemorySize;
      property Mnemonics : TStringList read FMnemonicList write FMnemonicList;
      property Labels : TStringList read FLabelList write FLabelList;
      property Symbols : TStringList read FSymbolList write FSymbolList;
      property Registers : TStringList read FRegisterList write FRegisterList;
  end;

Type
  PReversePicFamily = ^TReversePicFamily;
  TReversePicFamily = class(TReverseCALM)
    private
    protected
      function  GetWord(var Buffer; Addrs : longint) : pointer; override;
      procedure AddMnemonic(Name, Operands, Code : string);
    public
      procedure SetProcessor(ProcName : string); override;
      function  GetMnemonic(var X) : string; override;
  end;

var
  ReverseCALM  : TReverseCALM;

implementation

uses Windows, SysUtils, Math, Inifiles;

Const { CALM }
  opNoOperand    = 0;      {Pas d'operand}
  opLabel        = 1;      {Etiquette pour Call, Jump, etc }
  opLiteral      = 2;      {Literal}
  opByteOriented = 3;      {Op�ration sur octet}
  opBitOriented  = 4;      {Op�ration sur bit}
  opError        = 255;

  accNo          = 0;      { Pas d'accumulator }
  accOnly        = 1;      { uniquement accumulator }
  accSource      = 2;      { Accumulator comme source }
  accDest        = 3;      { Accumulator comme dest }

Type
  TMnemonicCALM = class(TObject)
  end;

  PPicFamilyMnemonic = ^TPicFamilyMnemonic;
  TPicFamilyMnemonic = class(TMnemonicCALM)
    private
      FMnemonic       : string;
      FOpCode         : word;
      FOperationType  : word;
      FAccumulatorPos : integer;
      FOpcodeMask     : word;
      FRegisterMask   : word;
      FBitMask        : word;
      FPosBitAddress  : word;
      FLiteralMask    : word;
      ReverseOwner    : TReversePicFamily;
    protected
      function  GetBitAddress(Reg : word; BitAddress : byte) : string;
      function  GetAccumulator(Acc : word) : string;
      function  GetOperationType(S : string) : integer;
      function  GetAccumulatorPos(S : string) : integer;
    public
      constructor Create(AOwner : TReversePicFamily; Name, Operands, Code : String);
      function  GetMnemonic(W : word; var Mnemonic : string) : boolean;
  end;

Var
  IniFile      : TIniFile;

Function UnQuote(S : String) : string;
Var
  P : PChar;
begin
  S := S+#0;
  P := @S[1];
  Result := AnsiExtractQuotedStr(P, '"');
end;


procedure SetBitW(var W : word; Bit : integer);
begin
  W := W or (1 shl Bit);
end;

procedure ClearBitW(var W : word; Bit : integer);
begin
  W := W and not (1 shl Bit);
end;

function IntToBin(L : longint; digits : integer) : string;
var
  i : integer;
begin
  Result := '';
  for i := 0 to pred(digits) do
    If (L and (1 shl i)) = (1 shl i) then
      Result := '1' + Result
    else
      Result := '0' + Result;
end;

function IntToAscii(B : Byte) : string;
begin
  Case Char(B) of
    'A'..'Z' : Result := Char(B);
  else
    Result := '{}';
  end;
end;

// ========================================================================

function TReverseCALM.ID_Label(Addrs : longint) : string;
begin
  Result := 'Label'+IntToHex(Addrs, Round(LogN(16, MemorySize)+0.5));
end;

function TReverseCALM.ID_Symbol(Reg : word) : string;
begin
  Result := 'Reg'+IntToHex(Reg, 2);
end;

procedure TReverseCALM.AddLabel(Addrs : longint; Name : string);
begin
  FLabelList.Add(ID_Label(Addrs)+'='+Name);
end;

function TReverseCALM.GetLabel(Addrs : longint; MustCreate : boolean) : string;
begin
  Result := FLabelList.Values[ID_Label(Addrs)];
  if Result <> '' then exit;
  if MustCreate then begin
    Result := ID_Label(Addrs);
    AddLabel(Addrs, Result);
  end;
end;

procedure TReverseCALM.AddRegister(Reg : word; Name : string);
begin
  FRegisterList.Add(ID_Symbol(Reg)+'='+Name);
end;

procedure TReverseCALM.AddSymbol(Reg : word; Name : string);
begin
  FSymbolList.Add(ID_Symbol(Reg)+'='+Name);
end;

function TReverseCALM.GetSymbol(Reg : word; MustCreate : boolean) : string;
Var
  ID : string;
begin
  ID := ID_Symbol(Reg);
  Result := FRegisterList.Values[ID];
  If Result<>'' then exit;

  Result := FSymbolList.Values[ID];
  if Result <> '' then exit;
  If MustCreate then begin
    Result :=  ID;
    AddSymbol(Reg, Result);
  end;
end;

function TReverseCALM.GetCALM(var Buffer; Addrs : longint) : string;
begin
  if GetLabel(Addrs, False)='' then
    Result := Tab+GetMnemonic(GetWord(Buffer, Addrs)^)
  else
    Result := GetLabel(Addrs, False)+':'+Tab+GetMnemonic(GetWord(Buffer, Addrs)^);
end;

constructor TReverseCALM.Create;
begin
  inherited Create;
  FMnemonicList := TStringList.Create;
  FRegisterList := TStringList.Create;
  FLabelList    := TStringList.Create;
  FSymbolList   := TStringList.Create;
  FProcessor := '';
  FWordBits := 0;
  FWordLen  := 0;
end;

procedure TReverseCALM.BuildHeader(Dest : TStrings);
begin
  With Dest do begin
    Add(';'+Tab+'PIC2CALM (c) 2001 O. Baumgartner');
    Add(';'+Tab+'http://www.boumpower.ch');
    Add('');
    Add('.proc '+Processor);
    Add('');
  end;
end;

procedure TReverseCALM.BuildSymbolTable(Dest : TStrings);
var
  Loc : word;
  Reg : word;
  i   : word;
begin
  If FSymbolList.Count=0 then exit;

  Loc := $00;
  With FSymbolList do begin
    Sort;
    for i := 0 to Pred(Count) do begin
      Reg := StrToInt('$'+copy(Names[i], 4, 255));
      if Loc<>Reg then begin
        Loc := Reg;
        Dest.Add('.loc 16'''+IntToHex(Loc, 2));
      end;
      Dest.Add(Values[Names[i]]+':'+Tab+'.blk.16 1');
      Inc(Loc);
    end;
    Sorted := false;
  end;
  Dest.Add('');
end;

procedure TReverseCALM.BuildSourceCALM(var Buffer; BufferSize : longint; Dest : TStrings);
var
  Loc : longint;
  i   : longint;
begin
  BuildHeader(Dest);
  BuildSymbolTable(Dest);
  Loc := $000;
  Dest.Add('.loc 16'''+IntToHex(Loc, Round(LogN(16, MemorySize)+0.5)));
  for i := 0 to pred(BufferSize div 2) do
    Dest.Add(GetCALM(Buffer, i))
end;


// ===============================================================================

constructor TPicFamilyMnemonic.Create(AOwner : TReversePicFamily; Name, Operands, Code : String);
var
  bit : integer;
begin
  inherited Create;
  FMnemonic       := '';
  FOpCode         := 0;
  FOperationType  := opError;
  FAccumulatorPos := 0;
  FOpcodeMask     := 0;
  FRegisterMask   := 0;
  FBitMask        := 0;
  FPosBitAddress  := 0;
  FLiteralMask    := 0;
  ReverseOwner   := AOwner;

  if Length(Code)=0 then exit; { Erreur }
  For Bit := Length(Code) downto 1 do
    if Code[Bit]=' ' then Delete(Code, Bit, 1);  { remove blancs }

  if Length(Code)<>AOwner.WordBits then Exit; { Erreur !!! }

  FMnemonic := Name;
  FOperationType := GetOperationType(Operands);
  FAccumulatorPos := GetAccumulatorPos(Operands);
  if FOperationType=opError then exit; { Erreur !!! }
  For Bit := 0 to pred(AOwner.WordBits) do
    Case Code[AOwner.WordBits-Bit] of
      'f' : SetBitW(FRegisterMask, Bit);
      'b' : begin
              If FBitMask=0 then FPosBitAddress := bit;
              SetBitW(FBitMask, Bit);
            end;
      'k' : SetBitW(FLiteralMask, Bit);
      'x' : {Don't care};
      '0' : SetBitW(FOpCodeMask, Bit);
      '1' : begin
              SetBitW(FOpCodeMask, Bit);
              SetBitW(FOpCode, Bit);
            end;
      else FOperationType := opError;
  end
end;

function TPicFamilyMnemonic.GetBitAddress(Reg : word; BitAddress : byte) : string;
begin
  Result := IntToStr(BitAddress);
end;

function TPicFamilyMnemonic.GetAccumulator(Acc : word) : string;
begin
  Result := 'W';
end;


function TPicFamilyMnemonic.GetOperationType(S : string) : integer;
begin
  Result := opError;
  If S='' then Result := opNoOperand;
  If CompareText(S, 'Addr')=0   then Result:=opLabel;
  If CompareText(S, 'W')=0      then Result:=opLiteral;
  If CompareText(S, '#Val,W')=0 then Result:=opLiteral;
  If CompareText(S, 'Reg')=0    then Result:=opByteOriented;
  If CompareText(S, 'Reg,W')=0  then Result:=opByteOriented;
  If CompareText(S, 'W,Reg')=0  then Result:=opByteOriented;
  If CompareText(S, 'Reg:#b')=0 then Result:=opBitOriented;
end;

function TPicFamilyMnemonic.GetAccumulatorPos(S : string) : integer;
var
  i, A, C : word;
begin
  Result := accNo;
  if Length(S)= 0 then exit;
  A := 0; C :=0;
  for i := 1 to Length(S) do begin
    if S[i] in ['W'] then A := i;
    if S[i] in [',', ':'] then C := i;
  end;
  if A=0 then exit;
  if C=0 then begin
    Result := accOnly;
    exit;
  end;
  if A<C then
    Result := accSource
  else
    Result := accDest;
end;

function TPicFamilyMnemonic.GetMnemonic(W : word; var Mnemonic : string) : boolean;
var
  Literal      : word;

begin
  Result := (W and FOpcodeMask) = FOpCode;
  If Result = false then exit;

  Case FOperationType of
    opNoOperand : Mnemonic := FMnemonic;
    opLabel     : Mnemonic := FMnemonic+Tab+ReverseOwner.GetLabel(W and FLiteralMask, True);
    opLiteral   : begin
                    Literal := W and FLiteralMask;
                    Mnemonic := FMnemonic+Tab+
                      '#16'''+IntToHex(Literal, 2)+ { Hexa}
                      ','+GetAccumulator(0)+Tab+
                      '; #10'''+IntToStr(Literal)+ { D�cimal }
                      ' #2'''+IntToBin(Literal, 8)+ { Binaire }
                      ' #"'+IntToAscii(Literal)+'"'; { Ascii }
                  end;
    opByteOriented : Case FAccumulatorPos of
                       accNo     : Mnemonic := FMnemonic+Tab+ReverseOwner.GetSymbol(W and FRegisterMask, True);
                       accOnly   : Mnemonic := FMnemonic+Tab+GetAccumulator(0);
                       accSource : Mnemonic := FMnemonic+Tab+GetAccumulator(0)+
                                             ','+ReverseOwner.GetSymbol(W and FRegisterMask, True);
                       accDest   : Mnemonic := FMnemonic+Tab+ReverseOwner.GetSymbol(W and FRegisterMask, True)+
                                             ','+GetAccumulator(0);
                     end;
    opBitOriented : Mnemonic := FMnemonic + Tab+
                      ReverseOwner.GetSymbol(W and FRegisterMask, True)+
                      ':#'+GetBitAddress(W and FRegisterMask, (W and FBitMask) shr FPosBitAddress);
    opError       : Mnemonic := '^Error : '+FMnemonic+
                                ' 16'''+IntToHex(W, 4)+
                                ' 2'''+IntToBin(W, 14);
  end;
end;



// ===============================================================================


function TReversePicFamily.GetWord(var Buffer; Addrs : longint) : pointer;
Var
  X : array[0..32768] of word absolute Buffer;
begin
  Result := @X[Addrs];
end;

function TReversePicFamily.GetMnemonic(var X) : string;
var
  W            : word absolute X;
  i            : integer;
  Found        : boolean;

begin
  Found := False;
  i := Pred(FMnemonicList.Count);
  while (not Found) and (i>=0) do begin
    Found := TPicFamilyMnemonic(FMnemonicList.Objects[i]).GetMnemonic(W, Result);
    Dec(i);
  end;

  If Found then exit;

  Result := '16'''+IntToHex(W, 2*FWordLen)+Tab+
            ';2'''+IntToBin(W, FWordBits);
end;

procedure TReversePicFamily.AddMnemonic(Name, Operands, Code : String);
var
  Mnemonic : TPicFamilyMnemonic;
begin
  Mnemonic := TPicFamilyMnemonic.Create(Self, Name, Operands, Code);
  FMnemonicList.AddObject(Name+' '+Operands, Mnemonic);
  If Mnemonic.FOperationType=opError then
    MessageBox(0,
               PChar('"'+Name+'" "'+Operands+'" "'+Code+'"'),
               'Erreur dans AddMnemonic()', MB_OK);
end;

procedure TReversePicFamily.SetProcessor(ProcName : String);
var
  i        : integer;
  S        : TStringList;
  StrAddrs : String;

begin
  S := TStringList.Create;
  FProcessor := ProcName;
  With IniFile do begin
    FProcessor := ReadString(ProcName, 'Proc', 'Not defined');
    FWordBits := ReadInteger(ProcName, 'WordBits', 0);
    FWordLen  := (FWordBits+7) div 8; { longueur des mots }
    FRegisterCount := ReadInteger(ProcName, 'RegisterCount', 0);
    FMemorySize := ReadInteger(ProcName, 'MemorySize', 0);
  end;

  // lecture des labels pr�d�finis
  IniFile.ReadSectionValues(ProcName+'.Labels', S);
  i := 0;
  While i< S.Count do begin
    StrAddrs := Trim(S.Names[i]);
    if (Length(StrAddrs)>0) and (StrAddrs[1] in ['$', '0'..'9']) then
      AddLabel(StrToInt(StrAddrs),
               S.Values[StrAddrs]);
    Inc(i);
  end;
  S.Clear;

  // lecture des Registres pr�d�finis
  IniFile.ReadSectionValues(ProcName+'.Registers', S);
  i := 0;
  While i< S.Count do begin
    StrAddrs := Trim(S.Names[i]);
    if (Length(StrAddrs)>0) and (StrAddrs[1] in ['$', '0'..'9']) then
      AddRegister(StrToInt(StrAddrs),
                  S.Values[StrAddrs]);
    Inc(i);
  end;
  S.Clear;

  // lecture des Mnemonics
  IniFile.ReadSectionValues(ProcName+'.Mnemonics', S);
  If S.Count>0 then
    for I := Pred(S.Count) downto 0 do
      if CompareText(S.Names[i], 'Mnemonic')=0 then S.Delete(i);
  i := 0;

  S.Free;
  {
;    Syntaxe AddInstruction(Mnemonic, Operands, Opcode);
;
;      Operands
;        Addr    : Label pour Jump, Goto, Call, etc
;        #Val,W  : Literal field, constant data
;        Reg,W   : Register file address 0x00 to 0x7F, d=0 store in W
;        W,Reg   : idem, mais attention si on utilise d car d=1 store in W
;        Reg     : Register only
;        W       : accumulator only
;        Reg:#b  : bit-oriented operation

;      OpCode
;        f     : file register
;        b     : bit address
;        k     : literal
;        d     : destination select NE PAS UTILISER !!!,
;                coder 2x l'instruction avec les bons Operands

;    Les instructions non triviale comme ClrC, ClrZ, etc sont
;    � mettre en fin de table pour �tre d�cod�e.
  }

  AddMnemonic('Move',       '#Val,W',   '11 00xx kkkk kkkk');
  AddMnemonic('Move',       'W,Reg',    '00 0000 1fff ffff');
  AddMnemonic('Move',       'Reg,W',    '00 1000 0fff ffff');
  AddMnemonic('Test',       'Reg',      '00 1000 1fff ffff');

  AddMnemonic('Move',       'W,Reg',    '00 0000 0fff ffff'); { Option, Tris PortA, tris PortB }
//  AddMnemonic('Move',       'W,Reg',    '00 0000 0fff ffff');
//  AddMnemonic('Move',       'W,Reg',    '00 0000 0fff ffff');

  AddMnemonic('Add',        '#Val,W',   '11 1110 kkkk kkkk');
  AddMnemonic('Add',        'Reg,W',    '00 0111 0fff ffff');
  AddMnemonic('Add',        'W,Reg',    '00 0111 1fff ffff');
  AddMnemonic('Sub',        '#Val,W',   '11 1100 kkkk kkkk');
  AddMnemonic('Sub',        'Reg,W',    '00 0010 0fff ffff');
  AddMnemonic('Sub',        'W,Reg',    '00 0010 1fff ffff');
  AddMnemonic('And',        '#Val,W',   '11 1001 kkkk kkkk');
  AddMnemonic('And',        'Reg,W',    '00 0101 0fff ffff');
  AddMnemonic('And',        'W,Reg',    '00 0101 1fff ffff');
  AddMnemonic('Or',         '#Val,W',   '11 1000 kkkk kkkk');
  AddMnemonic('Or',         'Reg,W',    '00 0100 0fff ffff');
  AddMnemonic('Or',         'W,Reg',    '00 0100 1fff ffff');
  AddMnemonic('Xor',        '#Val,W',   '11 1010 kkkk kkkk');
  AddMnemonic('Xor',        'Reg,W',    '00 0110 0fff ffff');
  AddMnemonic('Xor',        'W,Reg',    '00 0110 1fff ffff');

  AddMnemonic('Swap',       'Reg,W',    '00 1110 0fff ffff');
  AddMnemonic('Swap',       'Reg',      '00 1110 1fff ffff');
  AddMnemonic('Clr',        'Reg',      '00 0001 1fff ffff');
  AddMnemonic('Clr',        'W',        '00 0001 0xxx xxxx');
  AddMnemonic('ClrWDT',     '',         '00 0000 0110 0100');
  AddMnemonic('Sleep',      '',         '00 0000 0110 0011');

  AddMnemonic('Not',        'Reg',      '00 1001 1fff ffff');
  AddMnemonic('Not',        'Reg,W',    '00 1001 0fff ffff');

  AddMnemonic('Inc',        'Reg',      '00 1010 1fff ffff');
  AddMnemonic('Inc',        'Reg,W',    '00 1010 0fff ffff');
  AddMnemonic('Dec',        'Reg',      '00 0011 1fff ffff');
  AddMnemonic('Dec',        'Reg,W',    '00 0011 0fff ffff');

  AddMnemonic('RLC',        'Reg',      '00 1101 1fff ffff');
  AddMnemonic('RLC',        'Reg,W',    '00 1101 0fff ffff');
  AddMnemonic('RRC',        'Reg',      '00 1100 1fff ffff');
  AddMnemonic('RRC',        'Reg,W',    '00 1100 0fff ffff');

  AddMnemonic('Clr',        'Reg:#b',   '01 00bb bfff ffff');
  AddMnemonic('Set',        'Reg:#b',   '01 01bb bfff ffff');

  AddMnemonic('IncSkip,EQ', 'Reg',      '00 1111 1fff ffff');
  AddMnemonic('IncSkip,EQ', 'Reg,W',    '00 1111 0fff ffff');
  AddMnemonic('DecSkip,EQ', 'Reg',      '00 1011 1fff ffff');
  AddMnemonic('DecSkip,EQ', 'Reg,W',    '00 1011 0fff ffff');

  AddMnemonic('TestSkip,BC','Reg:#b',   '01 10bb bfff ffff');
  AddMnemonic('TestSkip,BS','Reg:#b',   '01 11bb bfff ffff');


  AddMnemonic('Jump',       'Addr',     '10 1kkk kkkk kkkk');
  AddMnemonic('Call',       'Addr',     '10 0kkk kkkk kkkk');
  AddMnemonic('RetMove',    '#Val,W',   '11 01xx kkkk kkkk');
  AddMnemonic('Ret',        '',         '00 0000 0000 1000');
  AddMnemonic('RetI',       '',         '00 0000 0000 1001');
  AddMnemonic('Nop',        '',         '00 0000 0xx0 0000');

  { Non Trivial }

  AddMnemonic('ClrC',       '',         '01 0000 0000 0011');
  AddMnemonic('SetC',       '',         '01 0100 0000 0011');
  AddMnemonic('ClrD',       '',         '01 0000 1000 0011');
  AddMnemonic('SetD',       '',         '01 0100 1000 0011');
  AddMnemonic('ClrZ',       '',         '01 0001 0000 0011');
  AddMnemonic('SetZ',       '',         '01 0101 0000 0011');

  AddMnemonic('Skip,CS',    '',         '01 1100 0000 0011');
  AddMnemonic('Skip,CC',    '',         '01 1000 0000 0011');
  AddMnemonic('Skip,DS',    '',         '01 1100 1000 0011');
  AddMnemonic('Skip,DC',    '',         '01 1000 1000 0011');
  AddMnemonic('Skip,ZS',    '',         '01 1101 0000 0011');
  AddMnemonic('Skip,ZC',    '',         '01 1001 0000 0011');
end;


// =========================================================================

procedure OpenIniFile;
Const
  IniName = 'Pic2CALM.INI';
var
  FName : string;
begin
  FName := FileSearch(IniName,
              ExtractFileDir(ParamStr(0))+';'+
              GetCurrentDir);
  if FName='' then begin
    MessageBox(0, PChar('Le fichier '+IniName+' n''a pas �t� trouv�'),
     'Erreur d''ouverture',
      MB_OK+MB_ICONERROR+MB_APPLMODAL);
    Abort;
  end;
  IniFile := TIniFile.Create(ExpandFileName(Fname));
end;

Initialization
Begin
  OpenIniFile;

  ReverseCALM := TReversePicFamily.Create;
  With ReverseCALM do begin
    SetProcessor('Pic16f84');
  end;
end;

Finalization
begin
  IniFile.Free;
end;

end.
