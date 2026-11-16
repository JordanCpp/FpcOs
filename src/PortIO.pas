{ Copyright 2026-present Evgeny Zoshchuk (JordanCpp) | GNU GPLv3 (https://gnu.org) }

UNIT PortIO;

{$MODE OBJFPC}
{$ASMMODE INTEL}

INTERFACE

TYPE
  TPortIO = OBJECT
    PROCEDURE Write8(port: UInt16; value: UInt8); ASSEMBLER; NOSTACKFRAME;
    FUNCTION Read8(port: UInt16): UInt8; ASSEMBLER; NOSTACKFRAME;
    
    PROCEDURE Write16(port: UInt16; value: UInt16); ASSEMBLER; NOSTACKFRAME;
    FUNCTION Read16(port: UInt16): UInt16; ASSEMBLER; NOSTACKFRAME;
    
    PROCEDURE Write32(port: UInt16; value: UInt32); ASSEMBLER; NOSTACKFRAME;
    FUNCTION Read32(port: UInt16): UInt32; ASSEMBLER; NOSTACKFRAME;
  end;

IMPLEMENTATION

PROCEDURE TPortIO.Write8(port: UInt16; value: UInt8); ASSEMBLER; NOSTACKFRAME;
ASM
  mov dx, port
  mov al, value
  out dx, al
END;

FUNCTION TPortIO.Read8(port: UInt16): UInt8; ASSEMBLER; NOSTACKFRAME;
ASM
  mov dx, port
  in al, dx
END;

PROCEDURE TPortIO.Write16(port: UInt16; value: UInt16); ASSEMBLER; NOSTACKFRAME;
ASM
  mov dx, port
  mov ax, value
  out dx, ax
END;

FUNCTION TPortIO.Read16(port: UInt16): UInt16; ASSEMBLER; NOSTACKFRAME;
ASM
  mov dx, port
  in ax, dx
END;

PROCEDURE TPortIO.Write32(port: UInt16; value: UInt32); ASSEMBLER; NOSTACKFRAME;
ASM
  mov dx, port
  mov eax, value
  out dx, eax
END;

FUNCTION TPortIO.Read32(port: UInt16): UInt32; ASSEMBLER; NOSTACKFRAME;
ASM
  mov dx, port
  in eax, dx
END;

END.
