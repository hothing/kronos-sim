package Kronos2.Memory is

   MEM_BLOCK : constant := 2048; -- kronos has a minimal part of memory
   MEM_SLOTS : constant := 20480; -- amount of slots in kronos machine
   MEM_SIZE  : constant := MEM_SLOTS * MEM_BLOCK; -- kronos memory size

   type T_ByteMemory is array (T_Word range <>) of T_Byte;
   type P_ByteMemory is access T_ByteMemory;

   type T_MemoryBlock(LowAddress, HighAddress : T_Address; readonly : Boolean) is private;

   type P_MemoryBlock is access T_MemoryBlock;

   function read (m: in T_MemoryBlock; addr : T_Address) return T_Byte;
   function read (m: in T_MemoryBlock; addr : T_Address) return T_Word;
   function read (m: in T_MemoryBlock; addr : T_Address) return T_DWord;

   procedure write (m: in out T_MemoryBlock; addr : T_Address; val : T_Byte);
   procedure write (m: in out T_MemoryBlock; addr : T_Address; val : T_Word);
   procedure write (m: in out T_MemoryBlock; addr : T_Address; val : T_DWord);

   procedure write_ro (m: in out T_MemoryBlock; addr : T_Address; val : T_Byte);
   procedure write_ro (m: in out T_MemoryBlock; addr : T_Address; val : T_Word);
   procedure write_ro (m: in out T_MemoryBlock; addr : T_Address; val : T_DWord);

   procedure copy_region (m: in out T_MemoryBlock;
                         from_addr : T_Address;
                         to_addr : T_Address;
                         len : T_Word
                        );

   procedure copy_region (m_src: in out T_MemoryBlock;
                         m_tgt: in out T_MemoryBlock;
                         from_addr : T_Address;
                         to_addr : T_Address;
                         len : T_Word
                        );

   function get_size(m: in T_MemoryBlock) return T_Word;

private

   type T_MemoryBlock(LowAddress, HighAddress : T_Address;
                      readonly : Boolean)
   is record
      mem    : T_ByteMemory (LowAddress .. HighAddress);
   end record;

end Kronos2.Memory;
