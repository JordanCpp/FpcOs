{ Copyright 2026-present Evgeny Zoshchuk (JordanCpp) | GNU GPLv3 (https://gnu.org) }

UNIT System;

{$MODE OBJFPC}
{$H-}

INTERFACE

TYPE
  HRESULT  = LongInt;
  UInt64   = QWord;

  UInt8  = Byte;
  PUInt8 = ^UInt8;

  UInt16  = Word;
  PUInt16 = ^Word;
  Int16   = SmallInt;
  PInt16  = ^SmallInt;

  Int32   = LongInt;
  UInt32  = LongWord;
  PInt32  = ^Int32;
  PUInt32 = ^UInt32;

  {$IFDEF CPU64}
    PUInt = QWord;
    PInt  = Int64;
    UInt  = QWord;
    Int   = Int64;
  {$ELSE}
    PUInt = LongWord;
    PInt  = LongInt;
    UInt  = LongWord;
    Int   = LongInt;
  {$ENDIF}

  PShortString = ^ShortString;

  {$IFDEF CPU64}
    jmp_buf = PACKED RECORD
      rbx, rsi, rdi, rbp, rsp, rip: UInt64;
    END;
  {$ELSE}
    jmp_buf = PACKED RECORD
      ebx, esi, edi, ebp, esp, eip: UInt32;
    END;
  {$ENDIF}

  PJmp_buf = ^jmp_buf;
  TJmpBuf  = jmp_buf;
  PJmpBuf  = ^TJmpBuf;

  PExceptAddr = ^TExceptAddr;
  TExceptAddr = RECORD
    Buf      : PJmpBuf;
    Next     : PExceptAddr;
    Frametype: Int32;
  END;

  PGuid = ^TGuid;
  TGuid = PACKED RECORD
    D1: UInt32;
    D2: UInt16;
    D3: UInt16;
    D4: ARRAY[0..7] OF UInt8;
  END;

  TTypeKind = (tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat,
    tkSet, tkMethod, tkSString, tkLString, tkAString, tkWString,
    tkVariant, tkArray, tkRecord, tkInterface, tkClass, tkObject,
    tkWChar, tkBool, tkInt64, tkQWord, tkDynArray, tkInterfaceRaw,
    tkProcVar, tkUString, tkUChar, tkHelper, tkFile, tkClassRef, tkPointer);

PROCEDURE FillChar(VAR x; count: UInt; value: UInt8);

procedure fpc_initializeunits; compilerproc;
procedure fpc_shortstr_to_shortstr(out res: shortstring; const sstr: shortstring); compilerproc;

IMPLEMENTATION

PROCEDURE FillChar(VAR x; count: UInt; value: UInt8);
VAR
  p: PUInt8;
  i: UInt;
BEGIN
  IF (count <= 0) THEN
  BEGIN
    Exit;
  END;

  p := @x;
  
  FOR i := 0 TO count - 1 DO
  BEGIN
    p^ := value;
    INC(p);
  END;
END;

procedure fpc_initializeunits; compilerproc;
begin
end;

procedure fpc_shortstr_to_shortstr(out res: shortstring; const sstr: shortstring); compilerproc;
var
  pSrc, pDst: PUInt8;
  slen, maxLen: UInt8;
  i: Int;
begin
  pSrc := @sstr;
  pDst := @res;
  slen := pSrc^;
  maxLen := SizeOf(res) - 1;
  if slen > maxLen then
    slen := maxLen;
  pDst^ := slen;
  for i := 1 to slen do
  begin
    Inc(pSrc);
    Inc(pDst);
    pDst^ := pSrc^;
  end;
end;

END.