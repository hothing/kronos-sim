package body Kronos2.Bus is

   ----------
   -- init --
   ----------

   procedure init (b: P_Bus; full : Boolean := True; tmr: T_Word := 3) is
   begin
      b.addr := 0;
      b.data := 0;
      b.idat.state := Bus_Ready;
      b.idat.radr := 0;


      b.idat.dma_on := False;
      b.idat.tma := 0;


      if full then
         b.idat.tmr := tmr;

         b.idat.itpn := 0;
         for ir in b.idat.itps'Range loop
            b.idat.itps(ir) := 0;
         end loop;

         for i in b.idat.ma'Range loop
            b.idat.ma(i).m := null;
            b.idat.ma(i).paddr := T_Address'Last;
         end loop;
      end if;

   end init;

   ---------------
   -- addMemory --
   ---------------

   procedure addMemory (b: P_Bus; m : P_MemoryBlock; addr: T_Address) is
      l, h  : T_Address;
      j     : T_Word;
      cm    : P_MemoryBlock;
      nok   : Boolean;
   begin
      nok := False;
      for i in reverse b.idat.ma'Range loop
         cm := b.idat.ma(i).m;
         if cm /= null then
            l := b.idat.ma(i).paddr;
            h := b.idat.ma(i).paddr + getSize(cm);
            if addr >= l and addr <= h then
               if cm /= null then
                  nok := True;
                  exit;
               end if;
            end if;
         else
            j := i; -- store last free slot
         end if;
      end loop;

      if nok then
         -- there is already existed block
         raise Program_Error with "[addMemory] Memory block is alredy exist";
      else
         if m /= null then
            b.idat.ma(j).paddr := addr;
            b.idat.ma(j).m := m;
         else
            raise Program_Error with "[addMemory] Memory block is damaged";
         end if;
      end if;

   end addMemory;

   -------------
   -- Monitor --
   -------------

   procedure Monitor (b: P_Bus) is
      timeout : Boolean;
   begin
      if not isReady(b) then
         b.idat.tma := b.idat.tma + 1;
      end if;

      timeout :=  b.idat.tma >= b.idat.tmr;

      case b.idat.state is
         when Bus_Ready =>
            null;
         when Bus_MemoryAccess =>
            null;
         when Bus_ReadFail =>
            null;
         when Bus_WriteFail =>
            null;
         when Bus_IORequest =>
            null;
         when Bus_IOAnswer =>
            null;
      end case;

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


   ------------------
   -- findMemBlock --
   ------------------

   function findMemBlock(b: P_Bus) return Boolean is
      l, h  : T_Address;
      cm    : P_MemoryBlock;
      ok    : Boolean;
   begin
      ok := False;
      for i in b.idat.ma'Range loop
         cm := b.idat.ma(i).m;
         if cm /= null then
            l := b.idat.ma(i).paddr;
            h := b.idat.ma(i).paddr + getSize(cm);
            if b.addr >= l and b.addr <= h then
               if cm /= null then
                  b.idat.cm := cm;
                  b.idat.radr := (b.addr - l);
                  ok := True;
                  exit;
               end if;
            end if;
         end if;
      end loop;

      return ok;
   end findMemBlock;


   --------------
   -- writeMem --
   --------------

   procedure writeMem (b: P_Bus; addr: T_Address; value: T_Word) is
   begin

      if isReady(b) then
         b.addr := addr;
         if findMemBlock(b) then
            writeWord(b.idat.cm, b.idat.radr, value);
         else
            b.idat.state := Bus_WriteFail;
         end if;
      end if;

   end writeMem;

   -------------
   -- readMem --
   -------------

   function readMem (b: P_Bus; addr: T_Address) return T_Word is
      value : T_Word;
   begin

      value := 0;

      if isReady(b) then
         b.addr := addr;
         if findMemBlock(b) then
            value := readWord(b.idat.cm, b.idat.radr);
         else
            b.idat.state := Bus_ReadFail;
         end if;
      end if;

      return value;
   end readMem;

   ------------------
   -- writeMemByte --
   ------------------

   procedure writeMemByte (b: P_Bus; addr: T_Address; value: T_Byte) is
   begin

      if isReady(b) then
         b.addr := addr;
         if findMemBlock(b) then
            writeByte(b.idat.cm, b.idat.radr, value);
         else
            b.idat.state := Bus_WriteFail;
         end if;
      end if;

   end writeMemByte;

   -----------------
   -- readMemByte --
   -----------------

   function readMemByte (b: P_Bus; addr: T_Address) return T_Byte is
      value : T_Byte;
   begin

      value := 0;

      if isReady(b) then
         b.addr := addr;
         if findMemBlock(b) then
            value := readByte(b.idat.cm, b.idat.radr);
         else
            b.idat.state := Bus_ReadFail;
         end if;
      end if;

      return value;

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

      if isReady(b) then
         mnd.bus := b;
         mnd.len := size;
         b.idat.dma_on := True;
         b.idat.state := Bus_MemoryAccess;
         b.addr := addr;
      end if;

   end beginDMA;

   ------------
   -- endDMA --
   ------------

   procedure endDMA (mnd : in out T_DMA_Mandat) is
   begin
      mnd.bus.idat.dma_on := False;
      mnd.bus.idat.state := Bus_Ready;
      mnd.bus.addr := 0;

      mnd.bus := null;
      mnd.len := 0;
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
