with Kronos2; use Kronos2;
with Kronos2.Memory; use Kronos2.Memory;

with Interfaces; use Interfaces;
with Ada.Text_IO; use Ada.Text_IO;

-- with GNATCOLL.Traces; use GNATCOLL.Traces;

procedure Test_Memory is
   ram : P_MemoryBlock;
   vi, vo : T_Word;
   adr : T_Address;
begin
   ram := new T_MemoryBlock;
   initBlock(ram, new T_ByteMemory(0 .. 31));

   vi := 16#78563412#;
   writeByte(ram, 0, 16#12#); pragma Assert(not hasFail(ram), "MA-01");
   writeByte(ram, 1, 16#34#); pragma Assert(not hasFail(ram), "MA-02");
   writeByte(ram, 2, 16#56#); pragma Assert(not hasFail(ram), "MA-03");
   writeByte(ram, 3, 16#78#); pragma Assert(not hasFail(ram), "MA-04");

   vo := readWord(ram, 0); pragma Assert(not hasFail(ram), "MA-05");
   Put(T_Word'Image(vo)); Put(" and expected "); Put_Line(T_Word'Image(vi));
   pragma Assert(vo = vi, "MA-06");

   writeByte(ram, 28, 16#55#); pragma Assert(not hasFail(ram), "MA-07");
   writeByte(ram, 29, 16#AA#); pragma Assert(not hasFail(ram), "MA-08");
   writeByte(ram, 30, 16#55#); pragma Assert(not hasFail(ram), "MA-09");
   writeByte(ram, 31, 16#AA#); pragma Assert(not hasFail(ram), "MA-10");

   vo := readWord(ram, 28); pragma Assert(not hasFail(ram), "MA-11");
   pragma Assert(vo = 16#AA55AA55#, "MA-12");

   adr := 13;
   vi := 16#77556622#;
   writeWord(ram, adr, vi); pragma Assert(not hasFail(ram), "MA-13");
   vo := readWord(ram, adr); pragma Assert(not hasFail(ram), "MA-14");
   Put(T_Word'Image(vo)); Put(" and expected "); Put_Line(T_Word'Image(vi));
   pragma Assert(vo = vi, "MA-15");

end Test_Memory;
