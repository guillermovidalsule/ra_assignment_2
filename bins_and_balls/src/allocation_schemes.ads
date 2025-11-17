--------------------------------------------------------------------------
--                                                                      --
--                R A N D O M I Z E D  A L G O R I T H M S              --
--                                                                      --
--                        Programming Assignment 2                      --
--                                                                      --
--                   B I N S _ A N D _ B A L L S . A D B                --
--                                 Spec                                 --
--                                                                      --
--                         Guillermo Vidal Sulé                         --
--                                                                      --
--             Master in Innovation & Research in Informatics           --
--                  Universitat Politècnica de Catalunya                --
--                   Facultat d'Informàtica de Barcelona                --
--                                                                      --
--                             2025-2026 Q1                             --
--                                                                      --
-- This spec includes the essential types, structures and functions for --
-- ball allocation. The most relevant are:                              --
--                                                                      --
--    (1) TYPE : Strategies : Different options for the allocation str- --
--                            ategy.                                    --
--    (2) FUNC : Assign_Bin : Assigns a bin given a strategy and params --
--    (3) FUNC : "+"        : Overload of integer array binary add ope- --
--                            rator. It  adds both arrays truncating to --
--                            the size of the smaller one.              --
--                                                                      --
--------------------------------------------------------------------------

package Allocation_Schemes is

   type Strategies is (
     One_Choice,
     Two_Choice,
     D_Choice,
     Probabilistic
     );

   type Unbounded_Integer_Array is array (Integer range <>) of Integer
     with Default_Component_Value => 0;

   subtype Question is Integer range 0 .. 2;

   function Assign_Bin (Strategy : Strategies;
                        M_Bins   : Integer;
                        D        : Integer  := 3;
                        β        : Float    := 0.5;
                        K        : Question := 1;
                        Status   : Unbounded_Integer_Array)
     return Integer;

   function "+" (Left, Right : Unbounded_Integer_Array)
     return Unbounded_Integer_Array;

end Allocation_Schemes;
