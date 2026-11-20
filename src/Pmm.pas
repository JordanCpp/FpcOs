{ Copyright 2026-present Evgeny Zoshchuk (JordanCpp) | GNU GPLv3 (https://gnu.org) }

UNIT Pmm;

{$MODE OBJFPC}

INTERFACE

TYPE
  TPageFrame = RECORD
    Address: UInt32;
  END;
  PPageFrame = ^TPageFrame;

  TPmm = OBJECT
  PRIVATE
    c_PageSize: UInt32;
    c_TotalPages: UInt32;
    c_BitMapAddress: UInt32;
    FPBitMap: PUInt8;
    FFirstFreeAddress: UInt32;

  PUBLIC
    PROCEDURE Init(startAddr, endAddr: UInt32);
    FUNCTION AllocPage: UInt32;
    PROCEDURE FreePage(pageAddr: UInt32);
    FUNCTION GetPageStatus(pageAddr: UInt32): UInt8;
  END;

IMPLEMENTATION

PROCEDURE SetBit(var Bytes: ARRAY OF UInt8; bitIndex: UInt32);
VAR
  byteIndex: UInt32;
  bitMask: UInt8;
BEGIN
  byteIndex := bitIndex DIV 8;
  bitMask := UInt8(1) SHL (bitIndex MOD 8);
  Bytes[byteIndex] := Bytes[byteIndex] OR bitMask;
END;

PROCEDURE ClearBit(var Bytes: ARRAY OF UInt8; bitIndex: UInt32);
VAR
  byteIndex: UInt32;
  bitMask: UInt8;
BEGIN
  byteIndex := bitIndex DIV 8;
  bitMask := UInt8(1) SHL (bitIndex MOD 8);
  Bytes[byteIndex] := Bytes[byteIndex] AND (NOT bitMask);
END;

FUNCTION IsBitSet(var Bytes: ARRAY OF UInt8; bitIndex: UInt32): Boolean;
VAR
  byteIndex: UInt32;
  bitMask: UInt8;
BEGIN
  byteIndex := bitIndex DIV 8;
  bitMask := UInt8(1) SHL (bitIndex MOD 8);
  RESULT := (Bytes[byteIndex] AND bitMask) <> 0;
END;

PROCEDURE TPmm.Init(startAddr, endAddr: UInt32);
VAR
  i: UInt32;
  bitmapSizeInBytes: UInt32;
  kernelEndAddress: UInt32;
BEGIN
  c_PageSize := 4096;
  c_TotalPages := (endAddr - startAddr) DIV c_PageSize;

  c_BitMapAddress := startAddr;

  bitmapSizeInBytes := (c_TotalPages + 7) DIV 8;
  FFirstFreeAddress := c_BitMapAddress + bitmapSizeInBytes; // 0x100000 + 128

  FPBitMap := PUInt8(c_BitMapAddress);

  FOR i := 0 TO bitmapSizeInBytes - 1 DO
  BEGIN
    FPBitMap[i] := 0;
  END;

  kernelEndAddress := FFirstFreeAddress + 64 * 1024;

  i := 0;
  WHILE (startAddr + i * c_PageSize) < kernelEndAddress DO
  BEGIN
    SetBit(FPBitMap^, i);
    INC(i);
  END;

END;

FUNCTION TPmm.AllocPage: UInt32;
VAR
  pageIndex: UInt32;
BEGIN
  pageIndex := 0;
  WHILE (pageIndex < c_TotalPages) AND IsBitSet(FPBitMap^, pageIndex) DO
  BEGIN
    INC(pageIndex);
  END;

  IF pageIndex >= c_TotalPages THEN
  BEGIN
    RESULT := 0;
    EXIT;
  END;

  SetBit(FPBitMap^, pageIndex);

  RESULT := c_BitMapAddress + (pageIndex * c_PageSize);
END;

PROCEDURE TPmm.FreePage(pageAddr: UInt32);
VAR
  pageIndex: UInt32;
BEGIN
  IF (pageAddr < c_BitMapAddress) OR (pageAddr >= c_BitMapAddress + c_TotalPages * c_PageSize) OR ((pageAddr MOD c_PageSize) <> 0) THEN
  BEGIN
    EXIT;
  END;

  pageIndex := (pageAddr - c_BitMapAddress) DIV c_PageSize;

  ClearBit(FPBitMap^, pageIndex);
END;

FUNCTION TPmm.GetPageStatus(pageAddr: UInt32): UInt8;
VAR
  pageIndex: UInt32;
BEGIN
  IF (pageAddr < c_BitMapAddress) OR (pageAddr >= c_BitMapAddress + c_TotalPages * c_PageSize) OR ((pageAddr MOD c_PageSize) <> 0) THEN
  BEGIN
    RESULT := 255;
    EXIT;
  END;

  pageIndex := (pageAddr - c_BitMapAddress) DIV c_PageSize;
  IF IsBitSet(FPBitMap^, pageIndex) THEN
    RESULT := 1
  ELSE
    RESULT := 0;
END;

END.

