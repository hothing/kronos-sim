package Kronos2.Processor is

   type T_ArithmeticUnit is private;
   
   FL_NONE : constant := 16#0#;
   FL_STACK_EMPTY : constant := 16#1#;
   FL_STACK_FULL : constant := 16#2#;

   FL_INT_UNDER : constant := 16#4#;
   FL_INT_OVER : constant := 16#8#;
   FL_IDIV_ZERO : constant := 16#10#;

   FL_FP_UNDER : constant := 16#20#;
   FL_FP_OVER : constant := 16#40#;
   FL_FDIV_ZERO : constant := 16#80#;
   
   procedure push(au : in out T_ArithmeticUnit; val : T_Word);
   procedure push(au : in out T_ArithmeticUnit; val : T_HalfWord);
   procedure push(au : in out T_ArithmeticUnit; val : T_Int);
   procedure push(au : in out T_ArithmeticUnit; val : T_Float);
   
   procedure pop(au : in out T_ArithmeticUnit; var : in out T_Word);
   procedure pop(au : in out T_ArithmeticUnit; var : in out T_HalfWord);
   procedure pop(au : in out T_ArithmeticUnit; var : in out T_Int);
   procedure pop(au : in out T_ArithmeticUnit; var : in out T_Float);
   
   function test_flag(au : in out T_ArithmeticUnit; flag : T_Word) return Boolean;
   
   procedure addi32(au : in out T_ArithmeticUnit); --math: addition of integers
   procedure subi32(au : in out T_ArithmeticUnit); --math: substraction of integers
   procedure muli32(au : in out T_ArithmeticUnit); --math: multiplication of integers
   procedure divi32(au : in out T_ArithmeticUnit); --math: division of integers
   procedure modi32(au : in out T_ArithmeticUnit); --math: division by module of integers
   
   procedure ceqi32(au : in out T_ArithmeticUnit); -- compare: equal
   procedure cnei32(au : in out T_ArithmeticUnit); -- compare: not equal
   procedure clti32(au : in out T_ArithmeticUnit); -- compare: less
   procedure cgti32(au : in out T_ArithmeticUnit); -- compare: great
   procedure clei32(au : in out T_ArithmeticUnit); -- compare: less or equal
   procedure cgei32(au : in out T_ArithmeticUnit); -- compare: great or equal
   
   procedure addfp(au : in out T_ArithmeticUnit); --math: addition of FP
   procedure subfp(au : in out T_ArithmeticUnit); --math: substraction of FP
   procedure mulfp(au : in out T_ArithmeticUnit); --math: multiplication of FP
   procedure divfp(au : in out T_ArithmeticUnit); --math: division of FP
   procedure modfp(au : in out T_ArithmeticUnit); --math: division by module of FP
   
   procedure ceqfp(au : in out T_ArithmeticUnit); -- compare: equal
   procedure cnefp(au : in out T_ArithmeticUnit); -- compare: not equal
   procedure cltfp(au : in out T_ArithmeticUnit); -- compare: less
   procedure cgtfp(au : in out T_ArithmeticUnit); -- compare: great
   procedure clefp(au : in out T_ArithmeticUnit); -- compare: less or equal
   procedure cgefp(au : in out T_ArithmeticUnit); -- compare: great or equal

   procedure cvifp(au : in out T_ArithmeticUnit); -- convert: integer to floating-point
   procedure cvrnd(au : in out T_ArithmeticUnit); -- convert: floating-point to integer, round
   procedure cvtrn(au : in out T_ArithmeticUnit); -- convert: floating-point to integer, truncate
   
   procedure sin(au : in out T_ArithmeticUnit); -- math: sinus
   procedure cos(au : in out T_ArithmeticUnit); -- math: cosinus
   procedure tan(au : in out T_ArithmeticUnit); -- math: tangens
   procedure ctg(au : in out T_ArithmeticUnit); -- math: cotanges
   
   procedure reset_all_flags(au : in out T_ArithmeticUnit);
   
     
private
   
   type T_WordArray is array (T_Word range <>) of T_Word;
   
   type T_ArithmeticUnit is record
      stack : T_WordArray (0 .. 6);
      top : T_Word;
      flags: T_Word;
   end record;
   

end Kronos2.Processor;
