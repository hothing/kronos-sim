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

   function Ipt(d : T_IODeviceInterface'Class ) return T_ItpNumber is abstract;

   function has_InReq(d : T_IODeviceInterface'Class  ) return Boolean is abstract;

   function has_OutReq(d : T_IODeviceInterface'Class  ) return Boolean is abstract;

   procedure input(d : T_IODeviceInterface'Class  ; val : in out T_Word) is abstract;

   procedure output(d : T_IODeviceInterface'Class  ; val : in T_Word) is abstract;

   procedure run(d : T_IODeviceInterface'Class ) is abstract;

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
