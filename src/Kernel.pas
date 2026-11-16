{ Copyright 2026-present Evgeny Zoshchuk (JordanCpp) | GNU GPLv3 (https://gnu.org) }

UNIT kernel;

{$MODE OBJFPC}

INTERFACE

USES 
  PortIO, MemoryIO, PIC, Interrupt, GDT, Console;

TYPE
  TKernel = OBJECT
    GDTSettings      : TGDTSettings;
    Terminal         : TConsole;
    InterruptManager : TInterruptManager;
    IDT              : TIDT;
    PROCEDURE Init;
    PROCEDURE Run;
  END;

IMPLEMENTATION

PROCEDURE TKernel.Init;
BEGIN
  GDTSettings.Init;
  GDTSettings.Load;
  InterruptManager.Init(@IDT);
  Terminal.Init($B8000);

  Terminal.WriteLine('Hello!');
END;

PROCEDURE TKernel.Run;
BEGIN
  WHILE TRUE DO
  BEGIN
  END;
END;

END.