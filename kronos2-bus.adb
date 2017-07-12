package body Kronos2.Bus is

   ----------
   -- init --
   ----------

   procedure init (b: P_Bus) is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "init unimplemented");
      raise Program_Error with "Unimplemented procedure init";
   end init;

   ---------------
   -- addMemory --
   ---------------

   procedure addMemory (b: P_Bus; m : P_MemoryBlock; paddr: T_Address) is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "addMemory unimplemented");
      raise Program_Error with "Unimplemented procedure addMemory";
   end addMemory;

   -------------
   -- Monitor --
   -------------

   procedure Monitor (b: P_Bus) is
   begin
      if not isReady(b) then
         b.idat.tma := b.idat.tma + 1;
      end if;

      if b.idat.tma >= b.idat.tmr then
         b.idat.state := Bus_Ready;
      end if;
   end Monitor;

   -------------
   -- isReady --
   -------------

   function isReady (b: P_Bus) return Boolean is
   begin
      return b.idat.state = Bus_Ready;
   end isReady;
   pragma Inline(isReady);
   -----------------
   -- hasReadFail --
   -----------------

   function hasReadFail (b: P_Bus) return Boolean is
   begin
      return b.idat.state = Bus_ReadFail;
   end hasReadFail;
   pragma Inline(hasReadFail);
   ------------------
   -- hasWriteFail --
   ------------------

   function hasWriteFail (b: P_Bus) return Boolean is
   begin
      return b.idat.state = Bus_WriteFail;
   end hasWriteFail;
   pragma Inline(hasWriteFail);

   ---------------
   -- hasAnswer --
   ---------------

   function hasAnswer (b: P_Bus) return Boolean is
   begin
      return b.idat.state = Bus_IOAnswer;
   end hasAnswer;

   ----------------
   -- hasRequest --
   ----------------

   function hasRequest (b: P_Bus; addr: T_Address) return Boolean is
   begin
      return b.idat.state = Bus_IORequest;
   end hasRequest;

   --------------
   -- writeMem --
   --------------

   procedure writeMem (b: P_Bus; addr: T_Address; value: T_Word) is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "writeMem unimplemented");
      raise Program_Error with "Unimplemented procedure writeMem";
   end writeMem;

   -------------
   -- readMem --
   -------------

   function readMem (b: P_Bus; addr: T_Address) return T_Word is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "readMem unimplemented");
      raise Program_Error with "Unimplemented function readMem";
      return readMem (b => b, addr => addr);
   end readMem;

   ------------------
   -- writeMemByte --
   ------------------

   procedure writeMemByte (b: P_Bus; addr: T_Address; value: T_Byte) is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "writeMemByte unimplemented");
      raise Program_Error with "Unimplemented procedure writeMemByte";
   end writeMemByte;

   -----------------
   -- readMemByte --
   -----------------

   function readMemByte (b: P_Bus; addr: T_Address) return T_Byte is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "readMemByte unimplemented");
      raise Program_Error with "Unimplemented function readMemByte";
      return readMemByte (b => b, addr => addr);
   end readMemByte;

   --------------
   -- beginDMA --
   --------------

   procedure beginDMA
     (b: P_Bus;
      addr: T_Address;
      size: T_Word;
      mnd : in out T_DMA_Mandat)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "beginDMA unimplemented");
      raise Program_Error with "Unimplemented procedure beginDMA";
   end beginDMA;

   ------------
   -- endDMA --
   ------------

   procedure endDMA (b: P_Bus) is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "endDMA unimplemented");
      raise Program_Error with "Unimplemented procedure endDMA";
   end endDMA;

   ----------------------
   -- requestIOAsSlave --
   ----------------------

   procedure requestIOAsSlave (b: P_Bus) is
   begin
      if isReady(b) then
         b.idat.state := Bus_IOAnswer;
      end if;
   end requestIOAsSlave;

   -----------------------
   -- requestIOAsMaster --
   -----------------------

   procedure requestIOAsMaster (b: P_Bus) is
   begin
      if isReady(b) then
         b.idat.state := Bus_IORequest;
      end if;
   end requestIOAsMaster;

   ------------
   -- readIO --
   ------------

   procedure readIO (b: P_Bus) is
   begin
      if hasAnswer(b) then
         null; -- what ???
      else
         null; -- waht ???
      end if;
   end readIO;

   -----------------
   -- initiateItp --
   -----------------

   function initiateItp (b: P_Bus; iptNo: T_Byte) return Boolean is
      r : Boolean;
   begin
      r := False;
      b.idat.itpn := b.idat.itpn + 1;
      if b.idat.itpn < b.idat.itps'Last then
         b.idat.itps(b.idat.itpn) := iptNo;
         r := True;
      else
         b.idat.itpn := b.idat.itps'Last;
      end if;

      return r;
   end initiateItp;

   ------------------
   -- getRecentItp --
   ------------------

   function getRecentItp (b: P_Bus) return T_Byte is
      itpNo : T_Byte;
   begin
      itpNo := b.idat.itps(b.idat.itpn);

      if b.idat.itpn > b.idat.itps'First then
         b.idat.itpn := b.idat.itpn - 1;
      end if;

      return itpNo;
   end getRecentItp;

   --------------
   -- checkItp --
   --------------

   function checkItp (b: P_Bus; iptNo: T_Byte) return Boolean is
   begin
      return iptNo = b.idat.itps(b.idat.itpn);
   end checkItp;

end Kronos2.Bus;
