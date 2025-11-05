with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;

package body Allocation_Schemes is

   ----------------------
   --  Rand_Quicksort  --
   ----------------------

   procedure Rand_Quicksort (A, Status : access Unbounded_Integer_Array;
                             Left, Right : Integer)
   is

      subtype Partition_Range is Integer range Left .. Right;
      package Rand is new Ada.Numerics.Discrete_Random (Partition_Range);
      use Rand;
      G : Generator;
      Pivot : Integer;

      Sub_A : Unbounded_Integer_Array (Partition_Range);
      L : Integer := Sub_A'First;
      H : Integer := Sub_A'Last;

      task type Rec_Call (A, Status : access Unbounded_Integer_Array;
                          Left, Right : Integer);
      task body Rec_Call is
      begin
         Rand_Quicksort (A, Status, Left, Right);
      end Rec_Call;

   begin

      Reset (G);
      Pivot := Random (G);

      if Right - Left < 1 then
         return;
      end if;

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
      A (Partition_Range) := Sub_A;

      if (L - 1 in Partition_Range) and then (L + 1 in Partition_Range) then
         declare
            Left_Task  : Rec_Call (A, Status, Left, L - 1);
            Right_Task : Rec_Call (A, Status, L + 1, Right);
         begin
            null;
         end;
      elsif L - 1 in Partition_Range then
         declare
            Left_Task : Rec_Call (A, Status, Left, L - 1);
         begin
            null;
         end;
      elsif L + 1 in Partition_Range then
         declare
            Right_Task : Rec_Call (A, Status, L + 1, Right);
         begin
            null;
         end;
      end if;

   end Rand_Quicksort;

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
         when One_Choice => return 1;
         when Two_Choice => return 2;
         when D_Choice   => return D;
         when Probabilistic =>
            declare
               use Ada.Numerics.Float_Random;
               G : Generator;
            begin
               Reset (G);
               if Random (G) <= β then
                  return 2;
               else
                  return 1;
               end if;
            end;
      end case;
   end Calculate_D;

   ------------------
   --  Assign_Bin  --
   ------------------

   function Assign_Bin (Strategy : Strategies;
                        M_Bins   : Integer;
                        D        : Integer := 3;
                        β        : Float := 0.5;
                        Status   : Unbounded_Integer_Array)
     return Integer
   is

      New_D : constant Integer := Calculate_D (Strategy, D, β);

      subtype M_Range is Integer range 1 .. M_Bins;
      subtype D_Range is Integer range 1 .. New_D;

      package Rand is new Ada.Numerics.Discrete_Random (M_Range);
      use Rand;

      Drawn_Bins : array (M_Range) of Boolean :=
        [others => False];
      Bins : aliased Unbounded_Integer_Array := [D_Range => 0];
      Rand_Bin : Integer := 0;
      G : Generator;

      Local_Status : aliased Unbounded_Integer_Array := Status;

   begin

      Reset (G);

      for I in D_Range loop
         Rand_Bin := Random (G);
         while Drawn_Bins (Rand_Bin) loop
            Rand_Bin := Random (G);
         end loop;
         Drawn_Bins (Rand_Bin) := True;
         Bins (I) := Rand_Bin;
      end loop;

      case New_D is
         when 1  => return Bins (Bins'First);
         when 2  =>
            return (if Status (Bins (Bins'First)) <= Status (Bins (Bins'Last))
                     then Bins (Bins'First) else Bins (Bins'Last));
         when 3 .. Integer'Last  =>
            Rand_Quicksort (Bins'Access, Local_Status'Access,
                            Bins'First,  Bins'Last);
            return Bins (Bins'First);
         when others => return -1; --  Should never run
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
