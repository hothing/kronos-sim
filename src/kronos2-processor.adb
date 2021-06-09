with Ada.Unchecked_Conversion;

package body Kronos2.Processor is

   function Word2Int is new Ada.Unchecked_Conversion(Source => T_Word,
                                                     Target => T_Int);

   function Int2Word is new Ada.Unchecked_Conversion(Source => T_Int,
                                                     Target => T_Word);

   function Word2Float is new Ada.Unchecked_Conversion(Source => T_Word,
                                                     Target => T_Float);

   function Float2Word is new Ada.Unchecked_Conversion(Source => T_Float,
                                                       Target => T_Word);

   procedure set_flag(au : in out T_ArithmeticUnit; flag : T_Word)
   is
   begin
      au.flags := au.flags or flag;
   end set_flag;
   pragma Inline(set_flag);

   procedure reset_flag(au : in out T_ArithmeticUnit; flag : T_Word)
   is
   begin
      au.flags := au.flags and not flag;
   end reset_flag;
   pragma Inline(reset_flag);

   procedure reset_all_flags(au : in out T_ArithmeticUnit)
   is
   begin
      au.flags := FL_NONE;
   end reset_all_flags;

   function test_flag(au : in out T_ArithmeticUnit; flag : T_Word) return Boolean
   is
   begin
      return (au.flags and flag) = flag;
   end test_flag;
   pragma Inline(test_flag);

   procedure push_unsafe(au : in out T_ArithmeticUnit; val : T_Word)
   is
      v : T_Word;
      for v'Address use au.stack(au.top)'Address;
   begin
      v := val;
      au.top := au.top + 1;
   end push_unsafe;
   pragma Inline_Always(push_unsafe);

   procedure push(au : in out T_ArithmeticUnit; val : T_Word)
   is
   begin
      if au.top <= au.stack'Last then
         push_unsafe(au, val);
      else
         set_flag(au, FL_STACK_FULL);
         au.top := au.stack'Last + 1;
      end if;
   end push;

   procedure push(au : in out T_ArithmeticUnit; val : T_HalfWord)
   is
   begin
      push(au, T_Word(val));
   end push;

   procedure push(au : in out T_ArithmeticUnit; val : T_Int)
   is
   begin
      push(au, Int2Word(val));
   end push;

   procedure push(au : in out T_ArithmeticUnit; val : T_Float)
   is
   begin
      push(au, Float2Word(val));
   end push;

   procedure pop_unsafe(au : in out T_ArithmeticUnit; val : T_Word)
   is
      v : T_Word;
      t : T_Word := au.top - 1;
      for v'Address use au.stack(t)'Address;
   begin
      v := val;
      au.top := t;
   end pop_unsafe;
   pragma Inline_Always(pop_unsafe);

   procedure pop(au : in out T_ArithmeticUnit; var : in out T_Word)
   is
   begin
      if au.top > au.stack'First then
         pop_unsafe(au, var);
      else
         set_flag(au, FL_STACK_EMPTY);
         au.top := au.stack'First;
      end if;
   end pop;

   procedure pop(au : in out T_ArithmeticUnit; var : in out T_HalfWord)
   is
      v : T_Word := 0;
   begin
      pop(au,v);
      var := T_HalfWord(v);
   end pop;

   procedure pop(au : in out T_ArithmeticUnit; var : in out T_Int)
     is
      v : T_Word := 0;
   begin
      pop(au,v);
      var := Word2Int(v);
   end pop;

   procedure pop(au : in out T_ArithmeticUnit; var : in out T_Float)
     is
      v : T_Word := 0;
   begin
      pop(au,v);
      var := Word2Float(v);
   end pop;

   procedure add_int(au : in out T_ArithmeticUnit)
   is
      x, y : T_Int := 0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         push(au, x + y);
      end if;
   end add_int;

   procedure sub_int(au : in out T_ArithmeticUnit)
     is
      x, y : T_Int := 0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         push(au, x - y);
      end if;
   end sub_int;

   procedure mul_int(au : in out T_ArithmeticUnit)
     is
      x, y : T_Int := 0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         push(au, x * y);
      end if;
   end mul_int;

   procedure div_int(au : in out T_ArithmeticUnit)
     is
      x, y : T_Int := 0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         if y /= 0 then
            push(au, x / y);
         else
            set_flag(au, FL_IDIV_ZERO);
         end if;
      end if;
   end div_int;

   procedure mod_int(au : in out T_ArithmeticUnit)
     is
      x, y : T_Int := 0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         if y /= 0 then
            push(au, x mod y);
         else
            set_flag(au, FL_IDIV_ZERO);
         end if;
      end if;
   end mod_int;


end Kronos2.Processor;
