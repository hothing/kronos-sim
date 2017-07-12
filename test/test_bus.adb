with Kronos2; use Kronos2;
with Kronos2.Memory; use Kronos2.Memory;
with Kronos2.Bus; use Kronos2.Bus;

with Interfaces; use Interfaces;
with Ada.Text_IO; use Ada.Text_IO;

-- with GNATCOLL.Traces; use GNATCOLL.Traces;

procedure Test_Bus is
   qbus : P_Bus;
   ram : P_MemoryBlock;
   vi, vo : T_Word;
   adr : T_Address;
begin

   qbus := new T_Bus;

   init(qbus);

   ram := new T_MemoryBlock;
   initBlock(ram, new T_ByteMemory(0 .. MEM_SIZE));

   addMemory(qbus, ram, 0);

   ram := new T_MemoryBlock;
   initBlock(ram, new T_ByteMemory(0 .. MEM_SIZE));

   addMemory(qbus, ram, MEM_SIZE + 4);

   adr := 14;
   vi := 16#77556622#;
   requestMem(qbus, adr); pragma Assert(getStatus(qbus) = Bus_MemoryAccess, "BA-00");
   writeMem(qbus, vi); pragma Assert(getStatus(qbus) = Bus_Ready, "BA-01");
   requestMem(qbus, adr); pragma Assert(getStatus(qbus) = Bus_MemoryAccess, "BA-02");
   vo := readMem(qbus); pragma Assert(getStatus(qbus) = Bus_Ready, "BA-03");
   Put(" Value is "); Put(T_Word'Image(vo)); Put(" and expected "); Put_Line(T_Word'Image(vi));
   pragma Assert(vo = vi, "BA-04");

   adr := MEM_SIZE + 14;
   vi := 16#77556622#;
   requestMem(qbus, adr); pragma Assert(getStatus(qbus) = Bus_MemoryAccess, "BA-05");
   writeMem(qbus, vi); pragma Assert(getStatus(qbus) = Bus_Ready, "BA-06");
   requestMem(qbus, adr); pragma Assert(getStatus(qbus) = Bus_MemoryAccess, "BA-07");
   vo := readMem(qbus); pragma Assert(getStatus(qbus) = Bus_Ready, "BA-08");
   Put(" Value is "); Put(T_Word'Image(vo)); Put(" and expected "); Put_Line(T_Word'Image(vi));
   pragma Assert(vo = vi, "BA-09");

   adr := MEM_SIZE + 2;
   vi := 16#77556622#;
   requestMem(qbus, adr); pragma Assert(getStatus(qbus) = Bus_ReadFail, "BA-10");

end Test_Bus;
