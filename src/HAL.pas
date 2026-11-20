{ Copyright 2026-present Evgeny Zoshchuk (JordanCpp) | GNU GPLv3 (https://gnu.org) }

UNIT HAL;

{$MODE OBJFPC}

INTERFACE

USES 
  PortIO, MemoryIO, PIC, Interrupt, GDT;

TYPE
  THal = OBJECT
    GDTSettings      : TGDTSettings;
    InterruptManager : TInterruptManager;
    IDT              : TIDT;
    PROCEDURE Init;
  END;

IMPLEMENTATION

PROCEDURE THal.Init;
BEGIN
  GDTSettings.Init;
  GDTSettings.Load;
  InterruptManager.Init(@IDT);
END;

END.