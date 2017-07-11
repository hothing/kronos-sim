with Interfaces; use Interfaces;
with Ada.Unchecked_Conversion;

package Kronos2 is


   subtype T_Byte is Unsigned_8;
   subtype T_HalfWord is Unsigned_16;
   subtype T_Word is Unsigned_32;
   subtype T_Int is Integer_32;

   subtype T_Float is Float;
   pragma Compile_Time_Warning (T_Word'Size /= Float'Size, "Float size is not equal Word size!");

   subtype T_Address is T_Word;

   type T_Format is (fmtWord32, fmtHalfWords, fmtBytes4, fmtBits32);

   subtype T_BytesIndex is T_Word range 0 .. 3;
   type T_WordAsBytes is array (T_BytesIndex) of T_Byte;

   subtype T_BoolsIndex is T_Word range 0 .. 31;
   type T_WordAsBools is array (T_BoolsIndex) of Boolean;

   type T_ConvertedWord (fmt : T_Format := fmtWord32) is record
      case fmt is
         when fmtWord32 =>
            w  : T_Word;
         when fmtHalfWords =>
            h  : T_HalfWord;
            l  : T_HalfWord;
         when fmtBytes4 =>
            b : T_WordAsBytes;
         when fmtBits32 =>
            bit : T_WordAsBools;
      end case;
   end record;
   pragma Unchecked_Union (T_ConvertedWord);

   procedure Initialization;

end Kronos2;
