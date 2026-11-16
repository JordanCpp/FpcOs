{ Copyright 2026-present Evgeny Zoshchuk (JordanCpp) | GNU GPLv3 (https://gnu.org) }

UNIT Interrupt;

{$MODE OBJFPC}
{$ASMMODE INTEL}

INTERFACE

USES 
  PortIO;

TYPE
  TGateDescriptor = PACKED RECORD
    OffsetLow : UInt16;
    Selector  : UInt16;
    Reserved  : UInt8;
    TypeAttr  : UInt8;
    OffsetHigh: UInt16;
  END;

  PGateDescriptor = ^TGateDescriptor;
  TIDT = ARRAY[0..255] OF TGateDescriptor;
  PIDT = ^TIDT;

  TInterruptManager = OBJECT
    IDTAddress: PIDT;
    PROCEDURE Init(idt_ptr: PIDT);
    PROCEDURE SetGate(vector: UInt8; handler: POINTER);
    PROCEDURE LoadIDT(idt_ptr: PIDT);
  END;

  TPIDTDescriptor = PACKED RECORD
    Limit: UInt16;
    Base : UInt32;
  END;

  PROCEDURE irq0_handler; cdecl; external 'interrupts.o';
  PROCEDURE irq1_handler; cdecl; external 'interrupts.o';
  PROCEDURE common_interrupt_logic(vector: UInt32); cdecl; public name 'common_interrupt_logic';

IMPLEMENTATION

PROCEDURE TInterruptManager.Init(idt_ptr: PIDT);
BEGIN
  IDTAddress := idt_ptr;
END;

PROCEDURE TInterruptManager.SetGate(vector: UInt8; handler: POINTER);
VAR
  addr: PUInt;
BEGIN
  IF (IDTAddress = NIL) THEN
  BEGIN
    Exit;
  END;
  
  addr := PUInt(handler);

  IDTAddress^[vector].OffsetLow  := addr AND $FFFF;
  IDTAddress^[vector].Selector   := $08;
  IDTAddress^[vector].Reserved   := 0;
  IDTAddress^[vector].TypeAttr   := $8E;
  IDTAddress^[vector].OffsetHigh := (addr SHR 16) AND $FFFF;
END;

PROCEDURE TInterruptManager.LoadIDT(idt_ptr: PIDT);
VAR
  descriptor: TPIDTDescriptor;
BEGIN
  descriptor.Limit := (SizeOf(TIDT) - 1);
  descriptor.Base  := UInt32(idt_ptr);
  
  asm
    mov eax, descriptor
    lidt [eax]
  end;
END;

PROCEDURE common_interrupt_logic(vector: UInt32); cdecl;
BEGIN
END;

END.
