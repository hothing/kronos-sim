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
      if b.idat.state /= Bus_Ready then
         b.idat.tma := b.idat.tma + 1;
      end if;

      timeout :=  b.idat.tma >= b.idat.tmr;

      case b.idat.state is
         when Bus_Ready =>
            null;
         when Bus_MemoryAccess =>
            null;
         when Bus_MemoryTransfer =>
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

   ---------------
   -- getStatus --
   ---------------

   function getStatus (b: P_Bus) return T_BusState is
   begin
      return b.idat.state;
   end getStatus;
   pragma Inline(getStatus);

   -----------------
   -- checkStatus --
   -----------------

   function checkStatus (b: P_Bus) return T_BusState is
      r : T_BusState;
   begin
      r := b.idat.state;
      b.idat.state := Bus_Ready;
      return r;
   end checkStatus;
   pragma Inline(checkStatus);


   procedure setStatus(b: P_Bus; ns : T_BusState) is
   begin
      b.idat.state := ns;
   end setStatus;
   pragma Inline(setStatus);

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


   procedure requestMem (b: P_Bus; addr: T_Address) is
      s : T_BusState;
   begin
      s := getStatus(b);
      if s = Bus_Ready or s = Bus_MemoryTransfer then
         if b.addr /= addr then
            b.addr := addr;
            if findMemBlock(b) then
               setStatus(b, Bus_MemoryAccess);
            else
               setStatus(b, Bus_ReadFail);
            end if;
         else
            setStatus(b, Bus_MemoryAccess);
         end if;
      end if;
   end requestMem;


   --------------
   -- writeMem --
   --------------

   procedure writeMem (b: P_Bus; value: T_Word) is
   begin

      if getStatus(b) = Bus_MemoryAccess then
         if not isReadOnly(b.idat.cm) then
            writeWord(b.idat.cm, b.idat.radr, value);
            setStatus(b, Bus_Ready);
         else
            setStatus(b, Bus_WriteFail);
         end if;
      end if;

   end writeMem;

   -------------
   -- readMem --
   -------------

   function readMem (b: P_Bus) return T_Word is
      value : T_Word;
   begin

      value := 0;

      if checkStatus(b) = Bus_MemoryAccess then
         value := readWord(b.idat.cm, b.idat.radr);
         setStatus(b, Bus_Ready);
      end if;

      return value;
   end readMem;

   ------------------
   -- writeMemByte --
   ------------------

   procedure writeMemByte (b: P_Bus; value: T_Byte) is
   begin

      if getStatus(b) = Bus_MemoryAccess then

         if findMemBlock(b) then
            writeByte(b.idat.cm, b.idat.radr, value);
            setStatus(b, Bus_Ready);
         else
            setStatus(b, Bus_WriteFail);
         end if;
      end if;

   end writeMemByte;

   -----------------
   -- readMemByte --
   -----------------

   function readMemByte (b: P_Bus) return T_Byte is
      value : T_Byte;
   begin

      value := 0;

      if getStatus(b) = Bus_MemoryAccess then
         if findMemBlock(b) then
            value := readByte(b.idat.cm, b.idat.radr);
            setStatus(b, Bus_Ready);
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

      if getStatus(b) = Bus_Ready then
         mnd.bus := b;
         mnd.len := size;
         b.addr := addr;
         setStatus(b, Bus_MemoryTransfer);
      end if;

   end beginDMA;

   ------------
   -- endDMA --
   ------------

   procedure endDMA (mnd : in out T_DMA_Mandat) is
   begin
      mnd.bus.addr := 0;
      mnd.bus := null;
      mnd.len := 0;

      setStatus(mnd.bus, Bus_Ready);
   end endDMA;

   procedure nextDMA (mnd : in out T_DMA_Mandat) is
   begin
      mnd.bus.addr := mnd.bus.addr + 1;
      mnd.len := mnd.len - 1;
   end nextDMA;
   pragma Inline(nextDMA);

   function checkAddrDMA(mnd : in out T_DMA_Mandat) return Boolean is
      r : Boolean := False;
   begin
      requestMem(mnd.bus, mnd.addr);
      if getStatus(mnd.bus) = Bus_MemoryTransfer then
         r := True;
      end if;
      return r;
   end checkAddrDMA;

   function checkDMARange(mnd : in out T_DMA_Mandat) return Boolean is
      r : Boolean := False;
   begin
      if mnd.len > 0 then
         requestMem(mnd.bus, mnd.addr + mnd.len - 1);
         if getStatus(mnd.bus) = Bus_MemoryTransfer then
            requestMem(mnd.bus, mnd.bus.addr);
            if getStatus(mnd.bus) = Bus_MemoryTransfer then
               r := True;
            end if;
         end if;
      end if;
      return r;
   end checkDMARange;

   -- PROC copyMem: it copy a region memory for DMA
   procedure copyMem(mnd : in out T_DMA_Mandat; m : P_ByteMemory) is
   begin
      if m /= null and mnd.len > 0 then
         if checkAddrDMA(mnd) then
            if getSize(mnd.bus.idat.cm) <= mnd.len then
               copyRegion(mnd.bus.idat.cm, mnd.bus.idat.radr, mnd.len, m);
               mnd.len := 0;
            else
               -- a situation can be when we have two coninued blocks
               declare
                  l1, l2, l0  : T_Word;
                  paddr : T_Address;
               begin
                  l1 := getSize(mnd.bus.idat.cm);
                  l2 := mnd.len - l1;
                  if l2 > 0 then
                     copyRegion(mnd.bus.idat.cm, mnd.bus.idat.radr, mnd.len, m);
                     paddr := mnd.addr;
                     l0 := mnd.len;
                     mnd.addr := paddr + l1;
                     mnd.len := l2;
                     if checkAddrDMA(mnd) then
                        if getSize(mnd.bus.idat.cm) <= mnd.len then
                           copyRegion(mnd.bus.idat.cm, mnd.bus.idat.radr, mnd.len, m);
                           mnd.len := 0;
                           mnd.addr := paddr;
                        end if;
                     end if;
                  end if;
               end;
            end if;
         end if;
      end if;
   end copyMem;


   -- PROC writeDMAWord: it copy a one value into memory for DMA
   procedure writeDMAWord(mnd : in out T_DMA_Mandat; v : T_Word) is
   begin
      requestMem(mnd.bus, mnd.bus.addr);
      if mnd.len > 0 and getStatus(mnd.bus) = Bus_MemoryTransfer then
            writeMem(mnd.bus, v);
            nextDMA(mnd);
      end if;
   end writeDMAWord;


   -- PROC writeDMAByte: it copy a one value into memory for DMA
   procedure writeDMAByte(mnd : in out T_DMA_Mandat; v : T_Byte) is
   begin
      requestMem(mnd.bus, mnd.bus.addr);
      if mnd.len > 0 and getStatus(mnd.bus) = Bus_MemoryTransfer then
            writeMemByte(mnd.bus, v);
            nextDMA(mnd);
      end if;
   end writeDMAByte;


   ----------------------
   -- requestIOAsSlave --
   ----------------------

   procedure answerIO (b: P_Bus; addr: T_Address; value : T_Word) is
   begin
      if getStatus(b) = Bus_IORequest and b.addr = addr then
         b.data := value;
         setStatus(b, Bus_IOAnswer);
      end if;
   end answerIO;

   -----------------------
   -- requestIOAsMaster --
   -----------------------

   procedure requestIO (b: P_Bus; addr: T_Address) is
   begin
      if getStatus(b) = Bus_Ready then
         b.addr := addr;
         setStatus(b, Bus_IORequest);
      end if;
   end requestIO;

   ------------
   -- readIO --
   ------------

   function readIO (b: P_Bus) return T_Word is
   begin
      if getStatus(b) = Bus_IOAnswer then
         setStatus(b, Bus_Ready);
         return b.data;
      else
         return 0;
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

   function getItp (b: P_Bus) return T_Byte is
      itpNo : T_Byte;
   begin
      itpNo := b.idat.itps(b.idat.itpn);

      if b.idat.itpn > b.idat.itps'First then
         b.idat.itpn := b.idat.itpn - 1;
      end if;

      return itpNo;
   end getItp;

   --------------
   -- checkItp --
   --------------

   function checkItp (b: P_Bus; iptNo: T_Byte) return Boolean is
   begin
      return iptNo = b.idat.itps(b.idat.itpn);
   end checkItp;

end Kronos2.Bus;
