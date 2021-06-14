package body Kronos2.Bus is

   procedure add_device(ic : in out T_IOController;
                        addr: T_Address; -- start I/O-address
                        mask : T_Word; -- a mask is using to recognize all addreses of device
                        dev: in P_IODeviceInterface )
   is
      d : P_IODeviceInterface;
   begin
      if ic.dcnt < ic.devices'Last then
         if dev /= null then
            d := find_device(ic, addr);
            if d = null then
               ic.devices(ic.dcnt).dev := dev;
               ic.devices(ic.dcnt).addr := addr;
               ic.dcnt := ic.dcnt + 1;
            end if;
         end if;
      end if;
   end add_device;

   procedure remove_device(ic : in out T_IOController; addr: T_Address; dev: out P_IODeviceInterface )
   is
   begin
      if ic.dcnt >= ic.devices'First then
         null;
      end if;
   end remove_device;

   procedure remove_device(ic : in out T_IOController; addr: T_Address)
   is
   begin
      if ic.dcnt >= ic.devices'First then
         null;
      end if;
   end remove_device;

   function find_device(ic : in out T_IOController; addr: T_Address) return P_IODeviceInterface
   is
      d : P_IODeviceInterface := null;
   begin
      for i in ic.devices'First .. ic.dcnt loop
         if ic.devices(ic.dcnt).addr = addr then
            d := ic.devices(ic.dcnt).dev ;
         end if;
      end loop;
      return d;
   end find_device;


   procedure run(ic : in out T_IOController) is
   begin
      for i in ic.devices'Range loop
         if ic.devices(i).dev /= null then
            run(ic.devices(i).dev.all);
         end if;
      end loop;
   end run;

end Kronos2.Bus;
