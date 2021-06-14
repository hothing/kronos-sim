with Kronos2.Memory; use Kronos2.Memory;

package Kronos2.Bus is

   type T_BusState is (Bus_Ready,
                       Bus_IORequest,
                       Bus_IOAnswer,
                       Bus_ReadFail,
                       Bus_WriteFail
                      );

   type T_IODeviceInterface is abstract tagged null record;
   type P_IODeviceInterface is access all T_IODeviceInterface'Class ;

   -- NB Design of T_IODeviceInterface is not good
   -- and as consequence a design of T_IOController is laso not good

   function get_interrupt(d : T_IODeviceInterface ) return T_ItpNumber is abstract;

   function has_answer(d : T_IODeviceInterface  ) return Boolean is abstract;

   procedure recive(d : T_IODeviceInterface  ; val : in out T_Word) is abstract;

   procedure send(d : T_IODeviceInterface  ; val : in T_Word) is abstract;

   procedure do_step(d : T_IODeviceInterface ) is abstract;

   function Ipt(d : T_IODeviceInterface'Class ) return T_ItpNumber;

   function Answer(d : T_IODeviceInterface'Class  ) return Boolean;

   procedure input(d : T_IODeviceInterface'Class  ; val : in out T_Word);

   procedure output(d : T_IODeviceInterface'Class  ; val : in T_Word);

   procedure step(d : T_IODeviceInterface'Class );

   type T_IOController is private;

   procedure add_device (ic : in out T_IOController;
                        addr: T_Address; -- start I/O-address
                        mask : T_Word; -- a mask is using to recognize all addreses of device
                        dev: in P_IODeviceInterface );
   procedure remove_device(ic : in out T_IOController; addr: T_Address; dev: out P_IODeviceInterface );
   procedure remove_device(ic : in out T_IOController; addr: T_Address);

   function find_device(ic : in out T_IOController; addr: T_Address) return P_IODeviceInterface ;

   procedure run(ic : in out T_IOController);

private

   subtype T_DeviceIndex is T_Address range 0 .. 15;

   type T_DeviceBound is record
      dev : P_IODeviceInterface;
      addr : T_Address; -- gerealized address of device
      mask : T_Word; -- a mask is using to recognize all addreses of device
   end record;

   type T_IODeviceArray is array (T_DeviceIndex) of T_DeviceBound ;

   type T_IOController is record
      devices: T_IODeviceArray; -- list of devices
   end record;

end Kronos2.Bus;
