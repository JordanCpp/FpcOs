{ Copyright 2026-present Evgeny Zoshchuk (JordanCpp) | GNU GPLv3 (https://gnu.org) }

UNIT Console;

{$MODE OBJFPC}

INTERFACE

TYPE
  TVideoMemory = ARRAY[0..1999] OF UInt16;
  PVideoMemory = ^TVideoMemory;

  TConsole = OBJECT
    FPVideoMemory: PVideoMemory;
    FCursorX     : Int;
    FCursorY     : Int;
    FColor       : UInt8;
    FAttribute   : UInt8;
    PROCEDURE Init(AVideoAddr: PUInt);
    PROCEDURE Clear;
    PROCEDURE WriteChar(c: Char);
    PROCEDURE WriteString(CONST s: STRING);
    PROCEDURE WriteLine(CONST s: STRING);
  END;

IMPLEMENTATION

PROCEDURE TConsole.Init(AVideoAddr: PUInt);
BEGIN
  FPVideoMemory := PVideoMemory(AVideoAddr);
  FCursorX      := 0;
  FCursorY      := 0;
  FColor        := $07;
  FAttribute    := $07;
  Clear;
END;

PROCEDURE TConsole.Clear;
VAR
  i: UInt;
BEGIN
  FOR i := 0 TO 1999 DO
  BEGIN
    FPVideoMemory^[i] := $0720;
  END;

  FCursorX := 0;
  FCursorY := 0;
END;

PROCEDURE TConsole.WriteChar(c: Char);
VAR
  index: UInt;
BEGIN
  IF c = #10 THEN
  BEGIN
    FCursorX := 0;
    FCursorY := FCursorY + 1;
    EXIT;
  END;
  
  IF c = #13 THEN
  BEGIN
    FCursorX := 0;
    EXIT;
  END;

  IF FCursorY >= 25 THEN
  BEGIN
    Clear;
    FCursorY := 0;
  END;

  index := (FCursorY * 80) + FCursorX;

  FPVideoMemory^[index] := (FAttribute shl 8) or UInt16(Ord(c));

  INC(FCursorX);
  IF FCursorX >= 80 THEN
  BEGIN
    FCursorX := 0;
    INC(FCursorY);
  END;
END;

PROCEDURE TConsole.WriteString(CONST s: STRING);
VAR
  i: UInt;
BEGIN
  FOR i := 1 TO Length(s) DO
  BEGIN
    WriteChar(s[i]);
  END;
END;

PROCEDURE TConsole.WriteLine(CONST s: STRING);
BEGIN
  WriteString(s);
  WriteChar(#10);
  WriteChar(#13);
END;

END.