{ Copyright 2026-present Evgeny Zoshchuk (JordanCpp) | GNU GPLv3 (https://gnu.org) }

UNIT Kernel;

{$MODE OBJFPC}

INTERFACE

USES 
  HAL, Console;

TYPE
  TKernel = OBJECT
    Hardware: THal;
    Terminal: TConsole;
    PROCEDURE Init;
    PROCEDURE Run;
  END;

IMPLEMENTATION

PROCEDURE TKernel.Init;
BEGIN
  Hardware.Init;
  Terminal.Init;
END;

PROCEDURE TKernel.Run;
BEGIN
  WHILE TRUE DO
  BEGIN
    Terminal.WriteLine('Hello!');
  END;
END;

END.