package body Kronos2.Memory is

   type T_WordMemory is array (T_Word range <>) of T_Word;
   type P_WordMemory is access all T_WordMemory;


   ---------------
   -- initBlock --
   ---------------
   procedure initBlock(m: in P_MemoryBlock; ba : P_ByteMemory) is
   begin
      if m = null then
         raise Program_Error with "[initBlock] Block is null: cannot be initialized";
      end if;

      if ba /= null then
         m.mode := ReadWrite;
         m.state := Success;
         m.dat  := ba;
      else
         raise Program_Error with "[initBlock] Memory is null: cannot be initialized";
      end if;

   end initBlock;

   --------------------
   -- maskAsReadOnly --
   --------------------

   procedure markAsReadOnly(m: in P_MemoryBlock) is
   begin
      pragma Assert(m /= null, "[markAsReadOnly] Memory block is null");

      if m.dat /= null then
         m.mode := ReadOnly;
         m.state := Success;
      else
         raise Program_Error with "[markAsReadOnly] Memory is null";
      end if;
   end markAsReadOnly;

   ----------------
   -- isReadOnly --
   ----------------
   function isReadOnly(m: in P_MemoryBlock) return Boolean is
   begin
      pragma Assert(m /= null, "[isReadOnly] Memory block is null");
      pragma Assert(m.dat /= null, "[isReadOnly] Memory is not accessible");
      return m.mode = ReadOnly;
   end isReadOnly;

   -------------
   -- hasFail --
   -------------
   function hasFail(m: in P_MemoryBlock) return Boolean is
   begin
      pragma Assert(m /= null, "[hasFail] Memory block is null");
      pragma Assert(m.dat /= null, "[hasFail] Memory is not accessible");
      return m.state /= Success;
   end hasFail;

   -------------
   -- getSize --
   -------------

   function getSize(m: in P_MemoryBlock) return T_Word is
   begin
      return m.dat'Last - m.dat'First;
   end getSize;


   --------------
   -- readByte --
   --------------

   function readByte (m: in P_MemoryBlock; addr : T_Word) return T_Byte is
   begin
      pragma Assert(m /= null, "[readByte] Memory block is null");
      pragma Assert(m.dat /= null, "[readByte] Memory is not accessible");

      if addr >= m.dat'First and addr <= m.dat'Last then
         m.state := Success;
         return m.dat(addr);
      else
         m.state := Fail;
         return 0;
      end if;
   end readByte;

   --------------
   -- readWord --
   --------------

   function readWord (m: in P_MemoryBlock; addr : T_Word) return T_Word is
      mw : P_WordMemory;
      for mw'Address use m.dat'Address;
      pragma Import(C, mw);
   begin
      pragma Assert(m /= null, "[readWord] Memory block is null");
      pragma Assert(m.dat /= null, "[readWord] Memory is not accessible");
      if addr >= m.dat'First and addr <= m.dat'Last then
         m.state := Success;
         return mw(addr / (T_Word'Size / T_Byte'SIze));
      else
         m.state := Fail;
         return 0;
      end if;
   end readWord;

   ---------------
   -- writeByte --
   ---------------

   procedure writeByte (m: in P_MemoryBlock; addr : T_Word; val : T_Byte) is
   begin
      pragma Assert(m /= null, "[writeByte] Memory block is null");
      pragma Assert(m.dat /= null, "[writeByte] Memory is not accessible");
      if addr >= m.dat'First
        and addr <= m.dat'Last
        and m.mode = ReadWrite
      then
         m.dat(addr) := val;
         m.state := Success;
      else
         m.state := Fail;
      end if;
   end writeByte;

   ---------------
   -- writeWord --
   ---------------

   procedure writeWord (m: in P_MemoryBlock; addr : T_Word; val : T_Word) is
      mw : P_WordMemory;
      for mw'Address use m.dat'Address;
      pragma Import(C, mw);
   begin
      pragma Assert(m /= null, "[writeWord] Memory block is null");
      pragma Assert(m.dat /= null, "[writeWord] Memory is not accessible");

      if addr >= m.dat'First
        and addr <= m.dat'Last
        and m.mode = ReadWrite
      then
         mw(addr / (T_Word'Size / T_Byte'SIze)) := val;
         m.state := Success;
      else
         m.state := Fail;
      end if;

   end writeWord;

end Kronos2.Memory;
