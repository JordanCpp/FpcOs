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
PROCEDURE fpc_shortstr_concat(VAR dests: ShortString; CONST s1, s2: ShortString); compilerproc;

FUNCTION fpc_div_qword(n, z: UInt64): UInt64; compilerproc;
FUNCTION fpc_mod_qword(n, z: UInt64): UInt64; compilerproc;
FUNCTION fpc_div_int64(n, z: Int64): Int64; compilerproc;
FUNCTION fpc_mod_int64(n, z: Int64): Int64; compilerproc;

FUNCTION IntToStr(Value: Int32): ShortString; OVERLOAD;
FUNCTION IntToStr(Value: UInt32): ShortString; OVERLOAD;
FUNCTION IntToStr(Value: Int64): ShortString; OVERLOAD;
FUNCTION IntToStr(Value: UInt64): ShortString; OVERLOAD;

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

PROCEDURE fpc_shortstr_to_shortstr(OUT res: ShortString; CONST sstr: ShortString); compilerproc;
VAR
  pSrc, pDst: PUInt8;
  slen, maxLen: UInt8;
  i: Int;
BEGIN
  pSrc := @sstr;
  pDst := @res;
  slen := pSrc^;
  maxLen := SizeOf(res) - 1;

  IF (slen > maxLen) THEN
  BEGIN
    slen := maxLen;
  END;

  pDst^ := slen;

  FOR i := 1 TO slen DO
  BEGIN
    INC(pSrc);
    INC(pDst);
    pDst^ := pSrc^;
  END;
END;

PROCEDURE fpc_shortstr_concat(VAR dests: ShortString; CONST s1, s2: ShortString); compilerproc;
VAR
  len1, len2, totalLen: UInt8;
  pDst, pSrc: PUInt8;
  i: Int32;
BEGIN
  len1 := Ord(s1[0]);
  len2 := Ord(s2[0]);

  IF (Int32(len1) + Int32(len2)) > 255 THEN
    totalLen := 255
  ELSE
    totalLen := len1 + len2;

  pDst := @dests;
  pDst^ := totalLen;
  INC(pDst);

  pSrc := @s1;
  INC(pSrc);
  FOR i := 1 TO len1 DO
  BEGIN
    pDst^ := pSrc^;
    INC(pDst);
    INC(pSrc);
  END;

  IF totalLen > len1 THEN
  BEGIN
    pSrc := @s2;
    INC(pSrc);
    FOR i := 1 TO (totalLen - len1) DO
    BEGIN
      pDst^ := pSrc^;
      INC(pDst);
      INC(pSrc);
    END;
  END;
END;

FUNCTION fpc_div_qword(n, z: UInt64): UInt64; compilerproc;
VAR
  q, r: UInt64;
  i: Int32;
BEGIN
  IF n = 0 THEN
  BEGIN
    Result := 0;
    Exit;
  END;

  q := 0;
  r := 0;
  FOR i := 63 DOWNTO 0 DO
  BEGIN
    r := (r SHL 1) OR ((z SHR i) AND 1);
    IF r >= n THEN
    BEGIN
      r := r - n;
      q := q OR (UInt64(1) SHL i);
    END;
  END;
  Result := q;
END;

FUNCTION fpc_mod_qword(n, z: UInt64): UInt64; compilerproc;
VAR
  r: UInt64;
  i: Int32;
BEGIN
  IF n = 0 THEN
  BEGIN
    Result := 0;
    Exit;
  END;

  r := 0;
  FOR i := 63 DOWNTO 0 DO
  BEGIN
    r := (r SHL 1) OR ((z SHR i) AND 1);
    IF r >= n THEN
      r := r - n;
  END;
  Result := r;
END;

FUNCTION fpc_div_int64(n, z: Int64): Int64; compilerproc;
VAR
  neg: Boolean;
  un, uz, ures: UInt64;
BEGIN
  neg := (n < 0) XOR (z < 0);
  IF n < 0 THEN un := UInt64(-n) ELSE un := UInt64(n);
  IF z < 0 THEN uz := UInt64(-z) ELSE uz := UInt64(z);
  ures := uz DIV un;
  IF neg THEN
    Result := -Int64(ures)
  ELSE
    Result := Int64(ures);
END;

FUNCTION fpc_mod_int64(n, z: Int64): Int64; compilerproc;
VAR
  un, uz, ures: UInt64;
BEGIN
  IF n < 0 THEN un := UInt64(-n) ELSE un := UInt64(n);
  IF z < 0 THEN uz := UInt64(-z) ELSE uz := UInt64(z);
  ures := uz MOD un;
  IF n < 0 THEN
    Result := -Int64(ures)
  ELSE
    Result := Int64(ures);
END;

FUNCTION IntToStr(Value: UInt32): ShortString; OVERLOAD;
VAR
  Buf: ARRAY[0..15] OF Char;
  i, Len: Int32;
BEGIN
  IF Value = 0 THEN
  BEGIN
    Result := '0';
    Exit;
  END;

  i := 0;
  WHILE Value > 0 DO
  BEGIN
    Buf[i] := Char((Value MOD 10) + Ord('0'));
    Value := Value DIV 10;
    INC(i);
  END;

  Len := i;
  Result[0] := Char(Len);
  FOR i := 1 TO Len DO
    Result[i] := Buf[Len - i];
END;

FUNCTION IntToStr(Value: Int32): ShortString; OVERLOAD;
VAR
  S: ShortString;
  UVal: UInt32;
  i, Len: Int32;
BEGIN
  IF Value >= 0 THEN
    Result := IntToStr(UInt32(Value))
  ELSE
  BEGIN
    UVal := UInt32(-(Value + 1)) + 1;
    S := IntToStr(UVal);
    Len := Ord(S[0]);
    Result[0] := Char(Len + 1);
    Result[1] := '-';
    FOR i := 1 TO Len DO
      Result[i + 1] := S[i];
  END;
END;

FUNCTION IntToStr(Value: UInt64): ShortString; OVERLOAD;
VAR
  Buf: ARRAY[0..23] OF Char;
  i, Len: Int32;
BEGIN
  IF Value = 0 THEN
  BEGIN
    Result := '0';
    Exit;
  END;

  i := 0;
  WHILE Value > 0 DO
  BEGIN
    Buf[i] := Char((Value MOD 10) + Ord('0'));
    Value := Value DIV 10;
    INC(i);
  END;

  Len := i;
  Result[0] := Char(Len);
  FOR i := 1 TO Len DO
    Result[i] := Buf[Len - i];
END;

FUNCTION IntToStr(Value: Int64): ShortString; OVERLOAD;
VAR
  S: ShortString;
  UVal: UInt64;
  i, Len: Int32;
BEGIN
  IF Value >= 0 THEN
    Result := IntToStr(UInt64(Value))
  ELSE
  BEGIN
    UVal := UInt64(-(Value + 1)) + 1;
    S := IntToStr(UVal);
    Len := Ord(S[0]);
    Result[0] := Char(Len + 1);
    Result[1] := '-';
    FOR i := 1 TO Len DO
      Result[i + 1] := S[i];
  END;
END;

END.