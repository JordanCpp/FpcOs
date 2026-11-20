{ Copyright 2026-present Evgeny Zoshchuk (JordanCpp) | GNU GPLv3 (https://gnu.org) }

UNIT GDT;

{$MODE OBJFPC}
{$ASMMODE INTEL}

INTERFACE

TYPE
  TDescriptor = PACKED RECORD
    LimitLow   : UInt16;
    BaseLow    : UInt16;
    BaseMiddle : UInt8;
    Access     : UInt8;
    FlagsLimit : UInt8;
    BaseHigh   : UInt8;
  END;

  TGDTDescriptor = PACKED RECORD
    Size     : UInt16;
    Address  : UInt32;
  END;

  TSelector = UInt16;

CONST
  GDT_KERNEL_CODE: TSelector = $0008; // Segment 0, Index 1, RPL 0
  GDT_KERNEL_DATA: TSelector = $0010; // Segment 0, Index 2, RPL 0
  GDT_USER_CODE:   TSelector = $001B; // Segment 0, Index 3, RPL 3
  GDT_USER_DATA:   TSelector = $0023; // Segment 0, Index 4, RPL 3

  ACCESS_PRESENT     = $80;
  ACCESS_RING0       = $00;
  ACCESS_RING3       = $60; // Privilege level 3
  ACCESS_CODE        = $0A; // Executable, Read
  ACCESS_DATA        = $02; // Writable
  ACCESS_EXECUTABLE  = $08;

  FLAGS_GRANULARITY  = $80; // 4KB pages
  FLAGS_SIZE_32BIT   = $40; // 32-bit mode
  FLAGS_DESCRIPTOR   = $10; // Code/Data segment

TYPE
  TGDTPtr = ^TGDTDescriptor;

  TGDTSettings = OBJECT
    Entries: ARRAY[0..4] OF TDescriptor;
    Pointer: TGDTDescriptor;
    
    PROCEDURE Init;
    PROCEDURE Load; ASSEMBLER; NOSTACKFRAME;
  END;

IMPLEMENTATION

PROCEDURE TGDTSettings.Init;
BEGIN
  { 0. Null Descriptor }
  FILLCHAR(Entries[0], SizeOf(TDescriptor), 0);

  { 1. Kernel Code Segment }
  Entries[1].LimitLow   := $FFFF;
  Entries[1].BaseLow    := 0;
  Entries[1].BaseMiddle := 0;
  Entries[1].Access     := ACCESS_PRESENT OR ACCESS_RING0 OR ACCESS_CODE;
  Entries[1].FlagsLimit := FLAGS_GRANULARITY OR FLAGS_SIZE_32BIT OR FLAGS_DESCRIPTOR OR $0F;
  Entries[1].BaseHigh   := 0;

  { 2. Kernel Data Segment }
  Entries[2].LimitLow   := $FFFF;
  Entries[2].BaseLow    := 0;
  Entries[2].BaseMiddle := 0;
  Entries[2].Access     := ACCESS_PRESENT OR ACCESS_RING0 OR ACCESS_DATA;
  Entries[2].FlagsLimit := FLAGS_GRANULARITY OR FLAGS_SIZE_32BIT OR FLAGS_DESCRIPTOR OR $0F;
  Entries[2].BaseHigh   := 0;

  { 3. User Code Segment (Ring 3) }
  Entries[3].LimitLow   := $FFFF;
  Entries[3].BaseLow    := 0;
  Entries[3].BaseMiddle := 0;
  Entries[3].Access     := ACCESS_PRESENT OR ACCESS_RING3 OR ACCESS_CODE;
  Entries[3].FlagsLimit := FLAGS_GRANULARITY OR FLAGS_SIZE_32BIT OR FLAGS_DESCRIPTOR OR $0F;
  Entries[3].BaseHigh   := 0;

  { 4. User Data Segment (Ring 3) }
  Entries[4].LimitLow   := $FFFF;
  Entries[4].BaseLow    := 0;
  Entries[4].BaseMiddle := 0;
  Entries[4].Access     := ACCESS_PRESENT OR ACCESS_RING3 OR ACCESS_DATA;
  Entries[4].FlagsLimit := FLAGS_GRANULARITY OR FLAGS_SIZE_32BIT OR FLAGS_DESCRIPTOR OR $0F;
  Entries[4].BaseHigh   := 0;

  Pointer.Size    := SizeOf(TDescriptor) * 5 - 1;
  Pointer.Address := UInt32(@Entries[0]);
END;

PROCEDURE TGDTSettings.Load;
ASM
  mov eax, Pointer
  lgdt [eax]
END;

END.
