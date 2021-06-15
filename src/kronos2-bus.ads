with Kronos2.Memory; use Kronos2.Memory;

package Kronos2.Bus is

   type T_DeviceStatus is (Ready, -- device is ready for communication
                           Busy, -- device is not ready and do something
                           Ipt_Ext, -- device requests an interrupt by external event
                           Ipt_by_In, -- device requests an interrupt by input access
                           Ipt_by_Out-- device requests an interrupt by output access
                          );

   type T_IODeviceInterface is abstract tagged null record;
   type P_IODeviceInterface is access all T_IODeviceInterface'Class ;

   -- NB Design of T_IODeviceInterface is not good
   -- and as consequence a design of T_IOController is laso not good

   function get_status(d : T_IODeviceInterface  ) return T_DeviceStatus is abstract;

   procedure recive(d : T_IODeviceInterface  ; register : T_Address; val : in out T_Word) is abstract;

   procedure send(d : T_IODeviceInterface  ; register : T_Address; val : in T_Word) is abstract;

   procedure do_step(d : T_IODeviceInterface ) is abstract;


   function Status(d : T_IODeviceInterface'Class  ) return T_DeviceStatus;

   procedure input(d : T_IODeviceInterface'Class ; register : T_Address; val : in out T_Word);

   procedure output(d : T_IODeviceInterface'Class ; register : T_Address; val : in T_Word);

   procedure step(d : T_IODeviceInterface'Class );


   type T_IOController is private;

   procedure add_device (ic : in out T_IOController;
                        addr: T_Address; -- start I/O-address
                        mask : T_Word; -- a mask is using to recognize all addreses of device
                        itp : T_ItpNumber; -- an interrupt used by device
                         dev: in P_IODeviceInterface );
   procedure remove_device(ic : in out T_IOController; addr: T_Address; dev: out P_IODeviceInterface );
   procedure remove_device(ic : in out T_IOController; addr: T_Address);

   function find_device(ic : in out T_IOController; addr: T_Address) return P_IODeviceInterface ;

   procedure input(ic : in out T_IOController;
                   addr: T_Address;
                   val : in out T_Word;
                   res : in out Boolean
                  );

   procedure output(ic : in out T_IOController;
                    addr: T_Address;
                    val : in T_Word;
                    res : in out Boolean
                   );

   procedure run(ic : in out T_IOController);

   procedure start_poll(ic : in out T_IOController);

   procedure poll_ipt(ic : in out T_IOController;
                      ds : in out T_DeviceStatus;
                      itp : in out T_ItpNumber);

   -- function poll(ic : in out T_IOController) return T_DeviceStatus;

private

   subtype T_DeviceIndex is T_Address range 0 .. 15;

   type T_DeviceBound is record
      dev : P_IODeviceInterface;
      addr : T_Address; -- gerealized address of device
      mask : T_Word; -- a mask is using to recognize all addreses of device
      itp : T_ItpNumber; -- an interrupt
   end record;

   type T_IODeviceArray is array (T_DeviceIndex) of T_DeviceBound ;

   type T_IOController is record
      devices: T_IODeviceArray; -- list of devices
      dix : T_DeviceIndex; -- last polled device index
   end record;

end Kronos2.Bus;
