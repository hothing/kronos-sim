with Ada.Unchecked_Conversion;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

package body Kronos2.Processor is

   C_TRUE : constant := 16#FFFF_FFFF#;
   C_FALSE : constant := 16#0#;

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

   procedure addi32(au : in out T_ArithmeticUnit)
   is
      x, y : T_Int := 0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         push(au, x + y);
      end if;
   end addi32;

   procedure subi32(au : in out T_ArithmeticUnit)
     is
      x, y : T_Int := 0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         push(au, x - y);
      end if;
   end subi32;

   procedure muli32(au : in out T_ArithmeticUnit)
     is
      x, y : T_Int := 0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         push(au, x * y);
      end if;
   end muli32;

   procedure divi32(au : in out T_ArithmeticUnit)
     is
      x, y : T_Int := 0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         if y /= 0 then
            push(au, x / y);
         else
            set_flag(au, FL_DIV_ZERO);
         end if;
      end if;
   end divi32;

   procedure modi32(au : in out T_ArithmeticUnit)
   is
      x, y : T_Int := 0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         if y /= 0 then
            push(au, x mod y);
         else
            set_flag(au, FL_DIV_ZERO);
         end if;
      end if;
   end modi32;

   procedure xdivi32(au : in out T_ArithmeticUnit)
   is
      x, y : T_Int := 0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         if y /= 0 then
            push(au, x mod y);
            push(au, x rem y);
         else
            set_flag(au, FL_DIV_ZERO);
         end if;
      end if;
   end xdivi32;

   procedure ceqi32(au : in out T_ArithmeticUnit) -- compare: equal
   is
      x, y : T_Int := 0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         if x = y then
            push(au, T_Word(C_TRUE));
         else
            push(au, T_Word(C_FALSE));
         end if;
      end if;
   end;

   procedure cnei32(au : in out T_ArithmeticUnit) -- compare: not equal
   is
      x, y : T_Int := 0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         if x /= y then
            push(au, T_Word(C_TRUE));
         else
            push(au, T_Word(C_FALSE));
         end if;
      end if;
   end;

   procedure clti32(au : in out T_ArithmeticUnit) -- compare: less
   is
      x, y : T_Int := 0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         if x < y then
            push(au, T_Word(C_TRUE));
         else
            push(au, T_Word(C_FALSE));
         end if;
      end if;
   end;

   procedure cgti32(au : in out T_ArithmeticUnit) -- compare: great
   is
      x, y : T_Int := 0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         if x > y then
            push(au, T_Word(C_TRUE));
         else
            push(au, T_Word(C_FALSE));
         end if;
      end if;
   end;

   procedure clei32(au : in out T_ArithmeticUnit) -- compare: less or equal
   is
      x, y : T_Int := 0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         if x <= y then
            push(au, T_Word(C_TRUE));
         else
            push(au, T_Word(C_FALSE));
         end if;
      end if;
   end;

   procedure cgei32(au : in out T_ArithmeticUnit) -- compare: great or equal
   is
      x, y : T_Int := 0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         if x >= y then
            push(au, T_Word(C_TRUE));
         else
            push(au, T_Word(C_FALSE));
         end if;
      end if;
   end;

   procedure addfp(au : in out T_ArithmeticUnit) --math: addition of FP
   is
      x, y : T_Float := 0.0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         push(au, x + y);
      end if;
   end;

   procedure subfp(au : in out T_ArithmeticUnit) --math: substraction of FP
   is
      x, y : T_Float := 0.0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         push(au, x - y);
      end if;
   end;

   procedure mulfp(au : in out T_ArithmeticUnit) --math: multiplication of FP
   is
      x, y : T_Float := 0.0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         push(au, x * y);
      end if;
   end;

   procedure divfp(au : in out T_ArithmeticUnit) --math: division of FP
   is
      x, y : T_Float := 0.0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         push(au, x / y);
      end if;
   end;

   procedure modfp(au : in out T_ArithmeticUnit) --math: division by module of FP
   is
      x, y, m : T_Float := 0.0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         m := abs(x);
         y := abs(y);
         while m >= y loop
            m := m - y;
         end loop;
         if x >= 0.0 then
            push(au, m);
         else
            push(au, -m);
         end if;
      end if;
   end;

   procedure ceqfp(au : in out T_ArithmeticUnit) -- compare: equal
   is
      x, y : T_Float := 0.0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         if x = y then
            push(au, T_Word(C_TRUE));
         else
            push(au, T_Word(C_FALSE));
         end if;
      end if;
   end;

   procedure cnefp(au : in out T_ArithmeticUnit) -- compare: not equal
   is
      x, y : T_Float := 0.0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         if x /= y then
            push(au, T_Word(C_TRUE));
         else
            push(au, T_Word(C_FALSE));
         end if;
      end if;
   end;

   procedure cltfp(au : in out T_ArithmeticUnit)-- compare: less
   is
      x, y : T_Float := 0.0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         if x < y then
            push(au, T_Word(C_TRUE));
         else
            push(au, T_Word(C_FALSE));
         end if;
      end if;
   end;

   procedure cgtfp(au : in out T_ArithmeticUnit) -- compare: great
   is
      x, y : T_Float := 0.0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         if x > y then
            push(au, T_Word(C_TRUE));
         else
            push(au, T_Word(C_FALSE));
         end if;
      end if;
   end;

   procedure clefp(au : in out T_ArithmeticUnit) -- compare: less or equal
   is
      x, y : T_Float := 0.0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         if x <= y then
            push(au, T_Word(C_TRUE));
         else
            push(au, T_Word(C_FALSE));
         end if;
      end if;
   end;

   procedure cgefp(au : in out T_ArithmeticUnit) -- compare: great or equal
   is
      x, y : T_Float := 0.0;
   begin
      pop(au, y);
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         if x >= y then
            push(au, T_Word(C_TRUE));
         else
            push(au, T_Word(C_FALSE));
         end if;
      end if;
   end;

   procedure cvifp(au : in out T_ArithmeticUnit) -- convert: integer to floating-point
   is
      x : T_Int := 0;
   begin
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         push(au, T_Float(x));
      end if;
   end;

   procedure cvrnd(au : in out T_ArithmeticUnit) -- convert: floating-point to integer, round
   is
      x, y : T_Float := 0.0;
   begin
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         push(au, T_Int(x));
      end if;
   end;

   procedure cvtrn(au : in out T_ArithmeticUnit) -- convert: floating-point to integer, truncate
   is
      x, y, z, d : T_Float := 0.0;
   begin
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         z := T_Float(T_Int(x));
         -- FIXME, ERROR: wrong implementation
         d := x - z;
         if x > 0.0 then
            if abs(d) <= 0.5 and d > 0.0 then
               z := z - 1.0;
            end if;
         else
            if abs(d) <= 0.5 and d < 0.0 then
               z := z + 1.0;
            end if;
         end if;
         pragma Compile_Time_Warning(True, "[convert: floating-point to integer, truncate] wrong implementation");
         -- FIXME:END
         push(au, T_Int(z));
      end if;
   end;

   procedure sqrt(au : in out T_ArithmeticUnit) -- math: square root
   is
      x, y : T_Float := 0.0;
   begin
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         push(au, Sqrt(x));
      end if;
   end;

   procedure sin(au : in out T_ArithmeticUnit) -- math: sinus
   is
      x, y : T_Float := 0.0;
   begin
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         push(au, sin(x));
      end if;
   end;

   procedure cos(au : in out T_ArithmeticUnit) -- math: cosinus
   is
      x, y : T_Float := 0.0;
   begin
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         push(au, cos(x));
      end if;
   end;

   procedure tan(au : in out T_ArithmeticUnit) -- math: tangens
   is
      x, y : T_Float := 0.0;
   begin
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         push(au, Tan(x));
      end if;
   end;

   procedure ctg(au : in out T_ArithmeticUnit) -- math: cotanges
   is
      x, y : T_Float := 0.0;
   begin
      pop(au, x);
      if not test_flag(au, FL_STACK_EMPTY) then
         if x /= 0.0 then
            push(au, Cot(x));
         else
            push(au, 0.0);
            set_flag(au, FL_DIV_ZERO);
         end if;
      end if;
   end;

end Kronos2.Processor;
