package Kronos2.Bus is

   type T_BusState is (Bus_Ready,
                       Bus_MemoryAccess,
                       Bus_IORequest,
                       Bus_IOAnswer,
                       Bus_ReadFail,
                       Bus_WriteFail
                      );

   subtype T_ItpRange is T_Byte range 0..31;
   type T_Interrupts is array(T_ItpRange) of T_Byte;

   type T_BusInternal is private;

   type T_Bus is record
      addr  : T_Address; -- physical address
      data  : T_Word;    -- data on the bus
      idat  : T_BusInternal;
   end record;
   type P_Bus is access all T_Bus;

   type T_DMA_Mandat is private;

   -- PROC Init: it initializes the bus
   procedure Init(b: P_Bus);

   -- PROC Monitor: it is monitoring bus for fails
   procedure Monitor(b: P_Bus);

   -- FUNC isReady: it says that the bas is ready for data transfer
   function isReady(b: P_Bus) return Boolean;

   -- FUNC hasReadFail: it says that last access to read is failed
   function hasReadFail(b: P_Bus) return Boolean;

   -- FUNC hasWriteFail: it says that last access to write is failed
   function hasWriteFail(b: P_Bus) return Boolean;

   -- FUNC hasAnswer: it says that the request has been answered (data on the bus)
   function hasAnswer(b: P_Bus) return Boolean;

   -- FUNC hasRequest: it says that the device with address has been requested
   function hasRequest(b: P_Bus; addr: T_Address) return Boolean;


   procedure writeMem(b: P_Bus; addr: T_Address; value: T_Word);

   function readMem(b: P_Bus; addr: T_Address) return T_Word;

   procedure writeMemByte(b: P_Bus; addr: T_Address; value: T_Byte);

   function readMemByte(b: P_Bus; addr: T_Address) return T_Byte;

   -- PROC beginDMA: it begins Direct Memory Access(DMA) transfer
   -- counter of transfered words has set to {size}
   -- Next call of {writeMem} will write word to the memory
   -- and increase address on the bus and decrease counter
   -- For exclusive acces a mandat sheme is used
   -- The mandat is getting at begin of DMA transfer
   procedure beginDMA (b: P_Bus;
                       addr: T_Address;
                       size: T_Word;
                       mnd : in out T_DMA_Mandat);

   -- PROC endDMA: it finishes DMA transfer
   procedure endDMA(b: P_Bus);

   -- FUNC write is trying to write a word {bus.data} to a master device
   -- Before use it the adress must be assigned with {bus.addr}
   procedure requestIOAsSlave(b: P_Bus);

   -- FUNC writeAsMaster is trying to write a word {bus.data} to a slave device
   -- Before use it the adress must be assigned with {bus.addr}
   procedure requestIOAsMaster(b: P_Bus);

   -- FUNC read is trying to read a word from a device
   -- Before use it the adress must be called the procedure {requestIOxxxx}
   -- Result is data in the field {bus.data}
   procedure readIO(b: P_Bus);


   -- FUNC initiateItp asks the bus to initiate an interrupt
   -- Result: True if it is possible
   function initiateItp(b: P_Bus; iptNo: T_Byte) return Boolean;

   -- FUNC getRecentItp asks the bus initiated interrupt
   -- Result: >0 if the interrupt {iptNo} exists. It's interrupt number
   --         0 when there is not any request
   function getRecentItp(b: P_Bus) return T_Byte;

   -- FUNC checkItp asks the bus initiated interrupt
   -- Result: True if the interrupt {iptNo} exists
   --         0 when there is not any request
   function checkItp(b: P_Bus; iptNo: T_Byte) return Boolean;

private
   type T_BusInternal is record
      state : T_BusState;   -- state of the bus
      radr  : T_Address; -- address for the bank/device
      --cm    : P_MemoryBlock; -- actual bank
      itps  : T_Interrupts; -- a quene of interrupts
      itpn  : T_ItpRange;   -- amount of initiated interrupts                          --

      dma_on  : Boolean;
   end record;

   type T_DMA_Mandat is record
      bus : P_Bus;
      len : T_Word;
   end record;

end Kronos2.Bus;
