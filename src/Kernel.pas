{ Copyright 2026-present Evgeny Zoshchuk (JordanCpp) | GNU GPLv3 (https://gnu.org) }

UNIT Kernel;

{$MODE OBJFPC}

INTERFACE

USES 
  HAL, Pmm, Console;

TYPE
  TKernel = OBJECT
    Hardware: THal;
    Terminal: TConsole;
    Memory  : TPmm;
    PROCEDURE Init;
    PROCEDURE Run;
  END;

IMPLEMENTATION

PROCEDURE TKernel.Init;
VAR
  page1, page2: UInt32;
BEGIN
  Hardware.Init;
  Terminal.Init;
  Memory.Init($100000, $200000);

  Terminal.WriteLine('Testing PMM...');
  
  page1 := Memory.AllocPage;
  Terminal.WriteLine('Allocated page 1 at: $' + IntToStr(page1));
  
  page2 := Memory.AllocPage;
  Terminal.WriteLine('Allocated page 2 at: $' + IntToStr(page2));
  
  Memory.FreePage(page1);
  Terminal.WriteLine('Freed page 1.');
  
  page1 := Memory.AllocPage;
  Terminal.WriteLine('Allocated page 1 again at: $' + IntToStr(page1));
  
  Terminal.WriteLine('PMM test complete.');
END;

PROCEDURE TKernel.Run;
BEGIN
  WHILE TRUE DO
  BEGIN
    //Terminal.WriteLine('Hello!');
  END;
END;

END.