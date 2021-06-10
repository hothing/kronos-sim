with Kronos2.Memory; use Kronos2.Memory;

package Kronos2.Bus is

   type T_BusState is (Bus_Ready,
                       Bus_IORequest,
                       Bus_IOAnswer,
                       Bus_ReadFail,
                       Bus_WriteFail
                      );

   type T_IODeviceInterface is abstract tagged null record;
   type P_IODeviceInterface is access all T_IODeviceInterface ;


   function Ipt(d : P_IODeviceInterface ) return T_ItpNumber is abstract;

   function is_InReq(d : P_IODeviceInterface ) return Boolean is abstract;

   function is_OutReq(d : P_IODeviceInterface ) return Boolean is abstract;

   procedure input(d : P_IODeviceInterface ; val : in out T_Word);

   procedure output(d : P_IODeviceInterface ; val : in T_Word);

   function set_Address(d : P_IODeviceInterface; addr : T_Address ) return T_Address is abstract;

   procedure run(d : P_IODeviceInterface ) is abstract;

   type T_IOController is private;

   procedure add_device(ic : in out T_IOController; addr: T_Address; dev: in P_IODeviceInterface );
   procedure remove_device(ic : in out T_IOController; addr: T_Address; dev: out P_IODeviceInterface );
   procedure remove_device(ic : in out T_IOController; addr: T_Address);

   function find_device(ic : in out T_IOController; addr: T_Address) return P_IODeviceInterface ;

   procedure run(ic : in out T_IOController);

private

   subtype T_DeviceCount is T_Address range 0 .. 15;

   type T_DeviceBound is record
      dev : P_IODeviceInterface;
      addr : T_Address;
   end record;

   type T_IODeviceArray is array (T_DeviceCount) of T_DeviceBound ;

   type T_IOController is record
      devices: T_IODeviceArray; -- list of devices
      dcnt : T_DeviceCount; -- count of devices
   end record;

end Kronos2.Bus;
