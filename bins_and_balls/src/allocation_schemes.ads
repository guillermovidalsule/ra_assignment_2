package Allocation_Schemes is

   Partial : constant Boolean := $PARTIAL;

   type Strategies is (
     One_Choice,
     Two_Choice,
     D_Choice,
     Probabilistic
     );

   type Unbounded_Integer_Array is array (Integer range <>) of Integer
     with Default_Component_Value => 0;

   subtype Question is Integer range 1 .. 2;

   function Assign_Bin (Strategy : Strategies;
                        M_Bins   : Integer;
                        D        : Integer  := 3;
                        β        : Float    := 0.5;
                        K        : Question := 1;
                        Status   : Unbounded_Integer_Array)
     return Integer;

   function "+" (Left, Right : Unbounded_Integer_Array)
     return Unbounded_Integer_Array;

   function "/" (Left : Unbounded_Integer_Array; Right : Integer)
     return Unbounded_Integer_Array is
     [for E of Left => E / Right];

end Allocation_Schemes;
