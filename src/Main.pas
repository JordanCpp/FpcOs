{ Copyright 2026-present Evgeny Zoshchuk (JordanCpp) | GNU GPLv3 (https://gnu.org) }

UNIT Main;

{$MODE OBJFPC}

INTERFACE

USES 
  Kernel;

PROCEDURE kernel_main; CDECL;

IMPLEMENTATION

VAR
  App: TKernel;

PROCEDURE kernel_main; CDECL; PUBLIC NAME 'kernel_main';
BEGIN
  App.Init;
  App.Run;
END;

END.
