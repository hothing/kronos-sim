package Kronos2.Processor is

   type T_ArithmeticUnit is private;
   
   FL_NONE : constant := 16#0#;
   FL_STACK_EMPTY : constant := 16#1#;
   FL_STACK_FULL : constant := 16#2#;
   FL_INT_UNDER : constant := 16#4#;
   FL_INT_OVER : constant := 16#8#;
   FL_IDIV_ZERO : constant := 16#10#;
   
   procedure push(au : in out T_ArithmeticUnit; val : T_Word);
   procedure push(au : in out T_ArithmeticUnit; val : T_HalfWord);
   procedure push(au : in out T_ArithmeticUnit; val : T_Int);
   procedure push(au : in out T_ArithmeticUnit; val : T_Float);
   
   procedure pop(au : in out T_ArithmeticUnit; var : in out T_Word);
   procedure pop(au : in out T_ArithmeticUnit; var : in out T_HalfWord);
   procedure pop(au : in out T_ArithmeticUnit; var : in out T_Int);
   procedure pop(au : in out T_ArithmeticUnit; var : in out T_Float);
   
   function test_flag(au : in out T_ArithmeticUnit; flag : T_Word) return Boolean;
   
   procedure add_int(au : in out T_ArithmeticUnit);
   procedure sub_int(au : in out T_ArithmeticUnit);
   procedure mul_int(au : in out T_ArithmeticUnit);
   procedure div_int(au : in out T_ArithmeticUnit);
   procedure mod_int(au : in out T_ArithmeticUnit);
   
   procedure reset_all_flags(au : in out T_ArithmeticUnit);
   
     
private
   
   type T_WordArray is array (T_Word range <>) of T_Word;
   
   type T_ArithmeticUnit is record
      stack : T_WordArray (0 .. 6);
      top : T_Word;
      flags: T_Word;
   end record;
   

end Kronos2.Processor;
