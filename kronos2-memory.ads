package Kronos2.Memory is

   MEM_BLOCK : constant := 2048; -- kronos has a minimal part of memory
   MEM_SLOTS : constant := 20480; -- amount of slots in kronos machine
   MEM_SIZE  : constant := MEM_SLOTS * MEM_BLOCK; -- kronos memory size

   subtype T_BlockIndex is T_HalfWord range 0 .. (MEM_SLOTS - 1);

   type T_MemAccess is (ReadWrite, ReadOnly);
   type T_MemResult is (Success, Fail);

   type T_ByteMemory is array (T_Word range <>) of T_Byte;
   type P_ByteMemory is access T_ByteMemory;

   type T_MemoryBlock is private;

   type P_MemoryBlock is access T_MemoryBlock;

   procedure initBlock(m: in P_MemoryBlock; ba : P_ByteMemory);

   procedure markAsReadOnly(m: in P_MemoryBlock);
   function isReadOnly(m: in P_MemoryBlock) return Boolean;


   function readByte (m: in P_MemoryBlock; addr : T_Word) return T_Byte;
   function readWord (m: in P_MemoryBlock; addr : T_Word) return T_Word;

   procedure writeByte (m: in P_MemoryBlock; addr : T_Word; val : T_Byte);
   procedure writeWord (m: in P_MemoryBlock; addr : T_Word; val : T_Word);

   function hasFail(m: in P_MemoryBlock) return Boolean;

private

   type T_MemoryBlock is record
      mode   : T_MemAccess;
      state  : T_MemResult;
      dat    : P_ByteMemory;
   end record;

end Kronos2.Memory;
