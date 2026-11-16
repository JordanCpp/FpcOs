{ Copyright 2026-present Evgeny Zoshchuk (JordanCpp) | GNU GPLv3 (https://gnu.org) }

UNIT MemoryIO;

{$MODE OBJFPC}

INTERFACE

TYPE
  TMemoryIO = OBJECT
    PROCEDURE Write8(addr: POINTER; val: UInt8);
    FUNCTION Read8(addr: POINTER): UInt8;
    
    PROCEDURE Write16(addr: POINTER; val: UInt16);
    FUNCTION Read16(addr: POINTER): UInt16;
    
    PROCEDURE Write32(addr: POINTER; val: UInt32);
    FUNCTION Read32(addr: POINTER): UInt32;
  end;

IMPLEMENTATION

PROCEDURE TMemoryIO.Write8(addr: POINTER; val: UInt8);
BEGIN
  PUInt8(addr)^ := val;
END;

FUNCTION TMemoryIO.Read8(addr: POINTER): UInt8;
BEGIN
  RESULT := PUInt8(addr)^;
END;

PROCEDURE TMemoryIO.Write16(addr: POINTER; val: UInt16);
BEGIN
  PUInt16(addr)^ := val;
END;

FUNCTION TMemoryIO.Read16(addr: POINTER): UInt16;
BEGIN
  RESULT := PUInt16(addr)^;
END;

PROCEDURE TMemoryIO.Write32(addr: POINTER; val: UInt32);
BEGIN
  PUInt32(addr)^ := val;
END;

FUNCTION TMemoryIO.Read32(addr: POINTER): UInt32;
BEGIN
  RESULT := PUInt32(addr)^;
END;

END.
