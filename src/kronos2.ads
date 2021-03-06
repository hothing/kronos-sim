with Interfaces; use Interfaces;
with Ada.Unchecked_Conversion;

package Kronos2 is


   subtype T_Byte is Unsigned_8;
   subtype T_HalfWord is Unsigned_16;
   subtype T_Word is Unsigned_32;
   subtype T_Int is Integer_32;
   subtype T_DWord is Unsigned_64;
   subtype T_DInt is Integer_64;

   subtype T_Float is Float;
   pragma Compile_Time_Warning (T_Word'Size /= Float'Size, "Float size is not equal Word size!");

   subtype T_Address is T_Word;

   subtype T_ItpNumber is T_Byte range 0..31;

   procedure Initialization;

end Kronos2;
