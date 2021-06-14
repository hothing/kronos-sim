package body Kronos2.Bus is

   function Ipt(d : T_IODeviceInterface'Class ) return T_ItpNumber
   is
   begin
      return get_interrupt(d);
   end Ipt;

   function Answer(d : T_IODeviceInterface'Class  ) return Boolean
   is
   begin
      return has_answer(d);
   end Answer;

   procedure input(d : T_IODeviceInterface'Class  ; val : in out T_Word)
   is
   begin
      recive(d, val);
   end input;

   procedure output(d : T_IODeviceInterface'Class  ; val : in T_Word)
   is
   begin
      send(d, val);
   end output;


   procedure step(d : T_IODeviceInterface'Class )
   is
   begin
      do_step(d);
   end step;

   ---------------

   procedure find_dev_slot(ic : in out T_IOController;
                          iofs: in out T_DeviceIndex; -- index of device slot
                          success : in out Boolean)
   is
   begin
      success := false;
      for i in ic.devices'Range loop
         success := ic.devices(i).dev = null;
         if success then
            iofs := i;
            exit;
         end if;
      end loop;
   end find_dev_slot;

   procedure find_dev_by_addr(ic : in out T_IOController;
                              addr: T_Address; -- start I/O-address
                              iofs: in out T_DeviceIndex; -- index of device slot
                              success : in out Boolean -- result
                             )
   is
   begin
      success := false;
      for i in ic.devices'Range loop
         if ic.devices(i).dev /= null then
            success := (ic.devices(i).addr) = (addr and ic.devices(i).mask);
            if success then
               iofs := i;
               exit;
            end if;
         end if;
      end loop;
   end find_dev_by_addr;

   procedure add_device(ic : in out T_IOController;
                        addr: T_Address; -- start I/O-address
                        mask : T_Word; -- a mask is using to recognize all addreses of device
                        dev: in P_IODeviceInterface )
   is
      ix : T_DeviceIndex := ic.devices'Last ;
      res : Boolean := false;
   begin
      find_dev_by_addr(ic, addr, ix, res);
      if not res then
         find_dev_slot(ic, ix, res);
         if res then
            ic.devices(ix).dev := dev;
            ic.devices(ix).addr := addr and mask;
            ic.devices(ix).mask := mask;
         end if;
      end if;
   end add_device;

   procedure remove_device(ic : in out T_IOController;
                           addr: T_Address;
                           dev: out P_IODeviceInterface )
   is
      ix : T_DeviceIndex := ic.devices'Last ;
      res : Boolean := false;
   begin
      find_dev_by_addr(ic, addr, ix, res);
      if res then
         dev := ic.devices(ix).dev;
         ic.devices(ix).dev := null;
         ic.devices(ix).addr := 0;
      end if;
   end remove_device;

   procedure remove_device(ic : in out T_IOController; addr: T_Address)
   is
      ix : T_DeviceIndex := ic.devices'Last ;
      res : Boolean := false;
   begin
      find_dev_by_addr(ic, addr, ix, res);
      if res then
         ic.devices(ix).dev := null;
         ic.devices(ix).addr := 0;
      end if;
   end remove_device;

   function find_device(ic : in out T_IOController; addr: T_Address) return P_IODeviceInterface
   is
      ix : T_DeviceIndex := ic.devices'Last ;
      res : Boolean := false;
      d : P_IODeviceInterface := null;
   begin
      find_dev_by_addr(ic, addr, ix, res);
      if res then
         d := ic.devices(ix).dev;
      end if;
      return d;
   end find_device;


   procedure run(ic : in out T_IOController) is
   begin
      for i in ic.devices'Range loop
         if ic.devices(i).dev /= null then
            step(ic.devices(i).dev.all);
         end if;
      end loop;
   end run;

end Kronos2.Bus;
