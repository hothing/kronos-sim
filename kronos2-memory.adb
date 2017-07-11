package body Kronos2.Memory is

   --------------
   -- readByte --
   --------------

   function readByte (m: in P_MemoryBlock; addr : T_Word) return T_Byte is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "readByte unimplemented");
      raise Program_Error with "Unimplemented function readByte";
      return readByte (m => m, addr => addr);
   end readByte;

   --------------
   -- readWord --
   --------------

   function readWord (m: in P_MemoryBlock; addr : T_Word) return T_Word is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "readWord unimplemented");
      raise Program_Error with "Unimplemented function readWord";
      return readWord (m => m, addr => addr);
   end readWord;

   ---------------
   -- writeByte --
   ---------------

   procedure writeByte (m: in P_MemoryBlock; addr : T_Word; val : T_Byte) is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "writeByte unimplemented");
      raise Program_Error with "Unimplemented procedure writeByte";
   end writeByte;

   ---------------
   -- writeWord --
   ---------------

   procedure writeWord (m: in P_MemoryBlock; addr : T_Word; val : T_Word) is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "writeWord unimplemented");
      raise Program_Error with "Unimplemented procedure writeWord";
   end writeWord;

end Kronos2.Memory;
