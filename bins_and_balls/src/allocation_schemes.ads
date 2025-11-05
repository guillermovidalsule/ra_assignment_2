package Allocation_Schemes is

   type Strategies is (
     One_Choice,
     Two_Choice,
     D_Choice,
     Probabilistic
     );

   type Unbounded_Integer_Array is array (Integer range <>) of Integer
     with Default_Component_Value => 0;

   function Assign_Bin (Strategy : Strategies;
                        M_Bins   : Integer;
                        D        : Integer := 3;
                        β        : Float   := 0.5;
                        Status   : Unbounded_Integer_Array)
     return Integer;

   function "+" (Left, Right : Unbounded_Integer_Array)
     return Unbounded_Integer_Array;

end Allocation_Schemes;
