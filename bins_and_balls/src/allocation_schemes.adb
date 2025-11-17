--------------------------------------------------------------------------
--                                                                      --
--                R A N D O M I Z E D  A L G O R I T H M S              --
--                                                                      --
--                        Programming Assignment 2                      --
--                                                                      --
--               A L L O C A T I O N _ S C H E M E S . A D B            --
--                                  Body                                --
--                                                                      --
--                         Guillermo Vidal Sulé                         --
--                                                                      --
--             Master in Innovation & Research in Informatics           --
--                  Universitat Politècnica de Catalunya                --
--                   Facultat d'Informàtica de Barcelona                --
--                                                                      --
--                             2025-2026 Q1                             --
--                                                                      --
-- Body of the allocation schemes described in the assignment statement.--
-- Some of the functions are  hidden inside the  body as they  are only --
-- called  here. These include  a version of the Quickselect algorithm, --
-- the logic of the partial visualization, and some other minor utili-  --
-- ties.                                                                --
--                                                                      --
--------------------------------------------------------------------------

with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;

package body Allocation_Schemes is

   ------------------------------------
   --  Private function definitions  --
   ------------------------------------

   function Rand_Quickselect (A, Status : Unbounded_Integer_Array;
                              Ith, Left, Right : Integer)
     return Integer
     with Pre => Ith in 1 .. (A'Last - A'First + 1);

   function Partial_Info_Assignment (Bins   : Unbounded_Integer_Array;
                                     Status : Unbounded_Integer_Array;
                                     K : Question)
     return Integer
     with Pre => Bins'Length = 2;

   function Calculate_D (Strategy : Strategies;
                         D        : Integer;
                         β        : Float)
     return Integer
     with Post => Calculate_D'Result > 0;

   function Get_Median (Set : Unbounded_Integer_Array)
     return Float;

   ------------------------
   --  Rand_Quickselect  --
   ------------------------

   function Rand_Quickselect (A, Status : Unbounded_Integer_Array;
                              Ith, Left, Right : Integer)
     return Integer
   is

      subtype Partition_Range is Integer range Left .. Right;
      package Rand is new Ada.Numerics.Discrete_Random (Partition_Range);
      use Rand;
      G : Generator;
      Pivot : Integer;

      Sub_A : Unbounded_Integer_Array (Partition_Range);
      L : Integer := Sub_A'First;
      H : Integer := Sub_A'Last;

   begin

      --  We select a pivot at random
      Reset (G);
      Pivot := Random (G);

      --  Elements are organized around the pivot
      for I in Partition_Range loop

         if Status (A (I)) <= Status (A (Pivot)) and then I /= Pivot then
            Sub_A (L) := A (I);
            L := @ + 1;
         elsif Status (A (I)) > Status (A (Pivot)) then
            Sub_A (H) := A (I);
            H := @ - 1;
         end if;

      end loop;
      Sub_A (L) := A (Pivot);

      --  We recursively call quickselect if the pivot is not ith
      if L = Ith then
         return Sub_A (L);
      elsif Ith < L then
         return Rand_Quickselect (Sub_A, Status, Ith, Left, L - 1);
      else
         return Rand_Quickselect (Sub_A, Status, Ith, L + 1, Right);
      end if;

   end Rand_Quickselect;

   -------------------
   --  Calculate_D  --
   -------------------

   function Calculate_D (Strategy : Strategies;
                         D        : Integer;
                         β        : Float)
     return Integer
   is
   begin
      case Strategy is
         when One_Choice    => return 1;
         when Two_Choice    => return 2;
         when D_Choice      => return D;
         when Probabilistic =>
            declare
               use Ada.Numerics.Float_Random;
               G : Generator;
            begin
               Reset (G);
               if Random (G) < β then
                  return 2;
               else
                  return 1;
               end if;
            end;
      end case;
   end Calculate_D;

   ------------------
   --  Get_Median  --
   ------------------

   function Get_Median (Set : Unbounded_Integer_Array)
     return Float
   is
      Median : Float := Float (
        Rand_Quickselect
         (A      => [for I in Set'Range => I], --  All valid indices
          Status => Set,
          Ith    => (Set'First + Set'Last) / 2, --  Median
          Left   => Set'First,
          Right  => Set'Last));
   begin
      if Set'Length rem 2 = 0 then
         Median := @ + Float (Rand_Quickselect
           (A      => [for I in Set'Range => I],
            Status => Set,
            Ith    => (Set'First + Set'Last) / 2 + 1,
            Left   => Set'First,
            Right  => Set'Last));
         Median := @ / 2.0;
      end if;
      return Median;
   end Get_Median;

   -------------------------------
   --  Partial_Info_Assignment  --
   -------------------------------

   function Partial_Info_Assignment (Bins   : Unbounded_Integer_Array;
                                     Status : Unbounded_Integer_Array;
                                     K : Question)
     return Integer
   is

      --  Select the median using random quickselect
      Median : constant Float := Get_Median (Status);
      B_1 : constant Integer := Bins (Bins'First);
      B_2 : constant Integer := Bins (Bins'Last);
      subtype Bin_Range is Integer range Bins'Range;
      package Rand is new Ada.Numerics.Discrete_Random (Bin_Range);
      G : Rand.Generator;

   begin

      Rand.Reset (G);
      if Float (Status (B_1)) < Median xor Float (Status (B_2)) < Median then
         return (if Float (Status (B_1)) < Median then B_1 else B_2);
      end if;

      if K = 1 then
         return Bins (Rand.Random (G));
      end if;

      declare
         Limit : constant Float :=
           (if Float (B_1) < Median then 0.75 else 0.25);
         Load : constant Integer := Status (
           Rand_Quickselect
            (A      => [for I in Status'Range => I],
             Status => Status,
             Ith    => Status'First +
               Integer (Float (Status'Last - Status'First + 1) * Limit),
             Left   => Status'First,
             Right  => Status'Last));
      begin
         if Status (B_1) < Load xor Status (B_2) < Load then
            return (if Status (B_1) < Status (B_2) then B_1 else B_2);
         else
            return Bins (Rand.Random (G));
         end if;
      end;

   end Partial_Info_Assignment;

   ------------------
   --  Assign_Bin  --
   ------------------

   function Assign_Bin (Strategy : Strategies;
                        M_Bins   : Integer;
                        D        : Integer  := 3;
                        β        : Float    := 0.5;
                        K        : Question := 1;
                        Status   : Unbounded_Integer_Array)
     return Integer
   is

      New_D : constant Integer := Calculate_D (Strategy, D, β);

      subtype M_Range is Integer range 1 .. M_Bins;
      subtype D_Range is Integer range 1 .. New_D;

      package Rand is new Ada.Numerics.Discrete_Random (M_Range);
      package Rand_Bin is new Ada.Numerics.Discrete_Random (D_Range);

      Bins : Unbounded_Integer_Array (D_Range);
      G   : Rand.Generator;
      G_2 : Rand_Bin.Generator;
      F : constant Integer := Bins'First;
      L : constant Integer := Bins'Last;

   begin
      --  We randomly select a set of bins
      Rand.Reset (G); Rand_Bin.Reset (G_2);
      Bins := [for B of Bins => Rand.Random (G)];

      --  Ball is allocated according to the selected strategy
      case New_D is
         when 1  => return Bins (F);
         when 2  =>
            if K = 0 then
               if Status (Bins (F)) < Status (Bins (L)) then
                  return Bins (F);
               elsif Status (Bins (F)) > Status (Bins (L)) then
                  return Bins (L);
               else
                  return Bins (Rand_Bin.Random (G_2));
               end if;
            else
               return Partial_Info_Assignment (Bins, Status, K);
            end if;
         when 3 .. Integer'Last  =>
            return Min : Integer := Bins (F) do
               for B of Bins loop
                  if Status (B) < Status (Min) then Min := B; end if;
               end loop;
            end return;
         when others => raise Constraint_Error;
      end case;

   end Assign_Bin;

   --------------------
   --  "+" Overload  --
   --------------------

   function "+" (Left, Right : Unbounded_Integer_Array)
     return Unbounded_Integer_Array
   is
      Min_Length : constant Integer :=
        Integer'Min (Left'Length, Right'Length);
      Result : Unbounded_Integer_Array (1 .. Min_Length);
   begin
      for I in Result'Range loop
         Result (I) := Left (Left'First + I - 1)
                     + Right (Right'First + I - 1);
      end loop;
      return Result;
   end "+";

end Allocation_Schemes;
