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
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Monitor unimplemented");
      raise Program_Error with "Unimplemented procedure Monitor";
   end Monitor;

   -------------
   -- isReady --
   -------------

   function isReady (b: P_Bus) return Boolean is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "isReady unimplemented");
      raise Program_Error with "Unimplemented function isReady";
      return isReady (b => b);
   end isReady;

   -----------------
   -- hasReadFail --
   -----------------

   function hasReadFail (b: P_Bus) return Boolean is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "hasReadFail unimplemented");
      raise Program_Error with "Unimplemented function hasReadFail";
      return hasReadFail (b => b);
   end hasReadFail;

   ------------------
   -- hasWriteFail --
   ------------------

   function hasWriteFail (b: P_Bus) return Boolean is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "hasWriteFail unimplemented");
      raise Program_Error with "Unimplemented function hasWriteFail";
      return hasWriteFail (b => b);
   end hasWriteFail;

   ---------------
   -- hasAnswer --
   ---------------

   function hasAnswer (b: P_Bus) return Boolean is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "hasAnswer unimplemented");
      raise Program_Error with "Unimplemented function hasAnswer";
      return hasAnswer (b => b);
   end hasAnswer;

   ----------------
   -- hasRequest --
   ----------------

   function hasRequest (b: P_Bus; addr: T_Address) return Boolean is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "hasRequest unimplemented");
      raise Program_Error with "Unimplemented function hasRequest";
      return hasRequest (b => b, addr => addr);
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
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "requestIOAsSlave unimplemented");
      raise Program_Error with "Unimplemented procedure requestIOAsSlave";
   end requestIOAsSlave;

   -----------------------
   -- requestIOAsMaster --
   -----------------------

   procedure requestIOAsMaster (b: P_Bus) is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "requestIOAsMaster unimplemented");
      raise Program_Error with "Unimplemented procedure requestIOAsMaster";
   end requestIOAsMaster;

   ------------
   -- readIO --
   ------------

   procedure readIO (b: P_Bus) is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "readIO unimplemented");
      raise Program_Error with "Unimplemented procedure readIO";
   end readIO;

   -----------------
   -- initiateItp --
   -----------------

   function initiateItp (b: P_Bus; iptNo: T_Byte) return Boolean is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "initiateItp unimplemented");
      raise Program_Error with "Unimplemented function initiateItp";
      return initiateItp (b => b, iptNo => iptNo);
   end initiateItp;

   ------------------
   -- getRecentItp --
   ------------------

   function getRecentItp (b: P_Bus) return T_Byte is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "getRecentItp unimplemented");
      raise Program_Error with "Unimplemented function getRecentItp";
      return getRecentItp (b => b);
   end getRecentItp;

   --------------
   -- checkItp --
   --------------

   function checkItp (b: P_Bus; iptNo: T_Byte) return Boolean is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "checkItp unimplemented");
      raise Program_Error with "Unimplemented function checkItp";
      return checkItp (b => b, iptNo => iptNo);
   end checkItp;

end Kronos2.Bus;
