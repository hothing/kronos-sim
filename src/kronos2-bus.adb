package body Kronos2.Bus is

   function Status(d : T_IODeviceInterface'Class  ) return T_DeviceStatus
   is
   begin
      return get_status(d);
   end Status;

   procedure input(d : T_IODeviceInterface'Class ; register : T_Address; val : in out T_Word)
   is
   begin
      recive(d, register, val);
   end input;

   procedure output(d : T_IODeviceInterface'Class ; register : T_Address; val : in T_Word)
   is
   begin
      send(d, register, val);
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
            success := (ic.devices(i).addr) = (addr and not ic.devices(i).mask);
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
                        itp : T_ItpNumber; -- an interrupt used by device
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
            ic.devices(ix).addr := addr and not mask;
            ic.devices(ix).mask := mask;
            ic.devices(ix).itp := itp;
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

   procedure input(ic : in out T_IOController;
                   addr: T_Address;
                   val : in out T_Word;
                   res : in out Boolean
                  )
   is
      ix : T_DeviceIndex := ic.devices'Last ;
   begin
      res := false;
      find_dev_by_addr(ic, addr, ix, res);
      if res then
         if Status(ic.devices(ix).dev.all) /= Busy then
            input(ic.devices(ix).dev.all, addr and ic.devices(ix).mask, val);
         else
            -- FIXME: reaction on a busy status
            null;
         end if;
      else
         -- FIXME: reaction on non-exist device
         null;
      end if;
   end input;

   procedure output(ic : in out T_IOController;
                    addr: T_Address;
                    val : in T_Word;
                    res : in out Boolean
                   )
   is
      ix : T_DeviceIndex := ic.devices'Last ;
   begin
      res := false;
      find_dev_by_addr(ic, addr, ix, res);
      if res then
         if Status(ic.devices(ix).dev.all) /= Busy then
            output(ic.devices(ix).dev.all, addr and ic.devices(ix).mask, val);
         else
            -- FIXME: reaction on a busy status
            null;
         end if;
      else
         -- FIXME: reaction on non-exist device
         null;
      end if;
   end output;

   procedure run(ic : in out T_IOController) is
   begin
      for i in ic.devices'Range loop
         if ic.devices(i).dev /= null then
            step(ic.devices(i).dev.all);
         end if;
      end loop;
   end run;

   procedure start_poll(ic : in out T_IOController)
   is
   begin
      ic.dix := ic.devices'First;
   end start_poll;

--     function poll(ic : in out T_IOController) return T_DeviceStatus
--     is
--        ds : T_DeviceStatus := Ready;
--        i : T_DeviceIndex := ic.dix;
--        c, cm : Natural := 0;
--     begin
--        cm := Natural(ic.devices'Length);
--        loop
--           i := T_DeviceIndex(Natural(i + 1) mod cm);
--           if not (i'Valid) then
--              -- MUST NOT HAPPEND
--              start_poll(ic);
--              i := ic.dix;
--           end if;
--           c := c + 1;
--           exit when (ic.devices(i).dev /= null) or (c >= cm);
--        end loop;
--        if ic.devices(i).dev /= null then
--           ds := Status(ic.devices(i).dev.all);
--        end if;
--        ic.dix := i;
--        return ds;
--     end poll;


   procedure poll_ipt(ic : in out T_IOController;
                      ds : in out T_DeviceStatus;
                      itp : in out T_ItpNumber)
   is
      i : T_DeviceIndex := ic.dix;
      c, cm : Natural := 0;
      de : Boolean;
   begin
      cm := Natural(ic.devices'Length);
      loop
         de := (ic.devices(i).dev /= null);
         exit when de or (c >= cm);
         c := c + 1;
      end loop;
      if de then
         ds := Status(ic.devices(i).dev.all);
         case ds is
            when Ipt_Ext | Ipt_by_In | Ipt_by_Out =>
               itp := ic.devices(i).itp;
            when others =>
               null;
         end case;
      end if;
      ic.dix := T_DeviceIndex(Natural(i + 1) mod cm);
   end poll_ipt;

end Kronos2.Bus;
