package body Kronos2.Memory is

   function read_unsafe (m: in T_MemoryBlock; addr : T_Address) return T_Byte
   is
      v : T_Byte;
      for v'Address use m.mem(addr)'Address;
   begin
      return v;
   end read_unsafe;
   pragma Inline_Always(read_unsafe);

   function read_unsafe (m: in T_MemoryBlock; addr : T_Address) return T_Word
   is
      v : T_Word;
      for v'Address use m.mem(addr)'Address;
   begin
      return v;
   end read_unsafe;
   pragma Inline_Always(read_unsafe);

   function read_unsafe (m: in T_MemoryBlock; addr : T_Address) return T_DWord
   is
      v : T_DWord;
      for v'Address use m.mem(addr)'Address;
   begin
      return v;
   end read_unsafe;
   pragma Inline_Always(read_unsafe);

   function read (m: in T_MemoryBlock; addr : T_Address) return T_Byte
   is
   begin
      if addr in m.mem'Range then
         return read_unsafe(m, addr);
      else
         return 0;
      end if;
   end read;

   function read (m: in T_MemoryBlock; addr : T_Address) return T_Word
   is
   begin
      if (addr >= m.mem'First)
        and (addr < (m.mem'Last - T_Word'Size / T_Byte'Size))
      then
         return read_unsafe(m, addr);
      else
         return 0;
      end if;
   end read;

   function read (m: in T_MemoryBlock; addr : T_Address) return T_DWord
   is
   begin
      if (addr >= m.mem'First)
        and (addr < (m.mem'Last - T_DWord'Size / T_Byte'Size))
      then
         return read_unsafe(m, addr);
      else
         return 0;
      end if;
   end read;


   procedure write_unsafe (m: in out T_MemoryBlock; addr : T_Address; val : T_Byte)
   is
      v : T_Byte;
      for v'Address use m.mem(addr)'Address;
   begin
      v := val;
   end write_unsafe;
   pragma Inline_Always(write_unsafe);

   procedure write_unsafe (m: in out T_MemoryBlock; addr : T_Address; val : T_Word)
   is
      v : T_Word;
      for v'Address use m.mem(addr)'Address;
   begin
      v := val;
   end write_unsafe;
   pragma Inline_Always(write_unsafe);

   procedure write_unsafe (m: in out T_MemoryBlock; addr : T_Address; val : T_DWord)
   is
      v : T_DWord;
      for v'Address use m.mem(addr)'Address;
   begin
      v := val;
   end write_unsafe;
   pragma Inline_Always(write_unsafe);


   procedure write_ro (m: in out T_MemoryBlock; addr : T_Address; val : T_Byte)
   is
   begin
      if (addr >= m.mem'First)
        and (addr < (m.mem'Last - T_Word'Size / T_Byte'Size))
      then
         write_unsafe(m, addr, val);
      end if;
   end write_ro;
   pragma Inline(write_ro);

   procedure write_ro (m: in out T_MemoryBlock; addr : T_Address; val : T_Word)
   is
   begin
      if (addr >= m.mem'First)
        and (addr < (m.mem'Last - T_Word'Size / T_Byte'Size))
      then
         write_unsafe(m, addr, val);
      end if;
   end write_ro;
   pragma Inline(write_ro);

   procedure write_ro (m: in out T_MemoryBlock; addr : T_Address; val : T_DWord)
   is
   begin
      if (addr >= m.mem'First)
        and (addr < (m.mem'Last - T_DWord'Size / T_Byte'Size))
      then
         write_unsafe(m, addr, val);
      end if;
   end write_ro;
   pragma Inline(write_ro);


   procedure write (m: in out T_MemoryBlock; addr : T_Address; val : T_Byte)
   is
   begin
      if not m.readonly then
         write_ro(m, addr, val);
      end if;
   end write;

   procedure write (m: in out T_MemoryBlock; addr : T_Address; val : T_Word)
   is
   begin
      if not m.readonly then
         write_ro(m, addr, val);
      end if;
   end write;

   procedure write (m: in out T_MemoryBlock; addr : T_Address; val : T_DWord)
   is
   begin
      if not m.readonly then
         write_ro(m, addr, val);
      end if;
   end write;


   procedure copy_region (m: in out T_MemoryBlock;
                         from_addr : T_Address;
                         to_addr : T_Address;
                         len : T_Word
                         )
   is
   begin
      pragma Compile_Time_Warning(True, "copy_region is not implmented");
      null;
   end copy_region;


   procedure copy_region (m_src: in out T_MemoryBlock;
                         m_tgt: in out T_MemoryBlock;
                         from_addr : T_Address;
                         to_addr : T_Address;
                         len : T_Word
                         )
   is
   begin
      pragma Compile_Time_Warning(True, "copy_region is not implmented");
      null;
   end copy_region;

   function get_size(m: in T_MemoryBlock) return T_Word
   is
   begin
      return m.HighAddress - m.LowAddress + 1;
   end get_size;
   pragma Inline(get_size);


end Kronos2.Memory ;
