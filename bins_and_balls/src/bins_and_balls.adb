--------------------------------------------------------------------------
--                                                                      --
--                R A N D O M I Z E D  A L G O R I T H M S              --
--                                                                      --
--                        Programming Assignment 2                      --
--                                                                      --
--                   B I N S _ A N D _ B A L L S . A D B                --
--                                                                      --
--                         Guillermo Vidal Sulé                         --
--                                                                      --
--             Master in Innovation & Research in Informatics           --
--                  Universitat Politècnica de Catalunya                --
--                   Facultat d'Informàtica de Barcelona                --
--                                                                      --
--                             2025-2026 Q1                             --
--                                                                      --
-- The second assignment of the course aims to study the model of balls --
-- and  bins.  This problem is analogous  to other ones such as buffers --
-- with  requests, or routers with incoming  packages. There are  four  --
-- allocation strategies that are of interest:                          --
--                                                                      --
--   (1) One_Choice : A bin is chosen at random with P{Xi} = 1/M        --
--   (2) Two_Choice : Out of two random bins, the one with the least    --
--                    balls is chosen.                                  --
--   (3) D_Choice   : Same as Two_Choice but with D bins                --
--   (4) Beta       : With probability β strategy Two_Choice is used    --
--                    and with probability (1 - β) One_Choice is chosen --
--                                                                      --
-- On top of that, batching can  be enabled to simulate  balls arriving --
-- in batches, being  the amount also  configurable. This works for all --
-- aforementioned strategies. Partial  information can be  enabled when --
-- using two random bins.                                               --
--                                                                      --
--                         I M P O R T A N T                            --
-- The program produces a  CSV file containing the averaged results for --
--            the given allocation strategy and parameters.             --
--                                                                      --
--------------------------------------------------------------------------

with Ada.Characters.Latin_1;
with Ada.Numerics.Elementary_Functions;
with Ada.Text_IO;

with Allocation_Schemes;

procedure Bins_And_Balls is

   use Allocation_Schemes;

   --  Program paramenters
   N_Balls : constant := $N;
   M_Bins  : constant := $M;
   D       : constant := $D;
   β       : constant := $B;
   K       : constant := $K;
   T       : constant := $T;

   --  Strategy
   Strategy : constant Strategies := $STRAT;

   --  Batched configuration
   Batched    : constant Boolean := $BATCH;
   Batch_Size : constant         := $BATCH_SIZE;

   --  Dummy visualization
   Print_Graph : constant Boolean := True;

   --  Array holding ball x bins
   Bins  : Unbounded_Integer_Array (1 .. M_Bins);
   Gaps  : array (1 .. T) of Float;

   --  Output file
   File      : Ada.Text_IO.File_Type;
   File_Name : constant String := "results.csv";

   Allocated_Bin : Integer := 0;

begin

   --  Print simulation start and information
   Ada.Text_IO.Put_Line ("BINS AND BALLS SIM START");
   Ada.Text_IO.Put_Line (Ada.Characters.Latin_1.ESC & "[1;34m");
   Ada.Text_IO.Put_Line ("Balls (N) = " & N_Balls'Image);
   Ada.Text_IO.Put_Line ("Bins  (M) = " & M_Bins'Image);

   --  Main body : simulate each ball independently
   for I in 1 .. T loop
      Bins := [others => 0];
      declare
         Current_Batch : Integer := (if Batched then Batch_Size else 1);
         Bin_Allocation : Unbounded_Integer_Array (1 .. M_Bins);
      begin
         for Ball in 1 .. N_Balls loop
            --  Allocate a bin for the given ball
            Allocated_Bin :=
              Allocation_Schemes.Assign_Bin
               (Strategy => Strategy,
                M_Bins   => M_Bins,
                D        => D,
                β        => β,
                K        => K,
                Status   => Bins);

            --  Update bins
            if Batched and then Batch_Size > 1 then
               Current_Batch := @ - 1;
               Bin_Allocation (Allocated_Bin) := @ + 1;
               if Current_Batch = 0 or Ball = N_Balls then
                  Bins           := @ + Bin_Allocation;
                  Current_Batch  := (if Batched then Batch_Size else 1);
                  Bin_Allocation := [others => 0];
               end if;
            else
               Bins (Allocated_Bin) := @ + 1;
            end if;
         end loop;
      end;
      declare --  Float'Max Reductions are broken in the FSF compiler
         Avg : constant Float := Float (N_Balls) / Float (M_Bins);
         Gap : Float;
      begin
         Gaps (I) := 0.0;
         for E of Bins loop
            Gap := Float (E) - Avg;
            if Gap > Gaps (I) then
               Gaps (I) := Gap;
            end if;
         end loop;
      end;
   end loop;

   --  Write to a CSV file the results
   declare
      use Ada.Numerics.Elementary_Functions;
      Avg_Gap  : constant Float :=
        [for E of Gaps => E]'Reduce ("+", 0.0) / Float (T);
      Variance : constant Float :=
        [for E of Gaps => (E - Avg_Gap) ** 2]'Reduce ("+", 0.0)
         / Float (T);
      Std_Dev  : constant Float := Sqrt (Variance);
   begin
      Ada.Text_IO.Create (File, Ada.Text_IO.Out_File, File_Name);
      Ada.Text_IO.Put_Line (File, "C,N,M,B,G,V,D");
      Ada.Text_IO.Put_Line (
        File, D'Image (2 .. D'Image'Last)
        & ',' & N_Balls'Image (2 .. N_Balls'Image'Last)
        & ',' & M_Bins'Image (2 .. M_Bins'Image'Last)
        & ',' & Batch_Size'Image (2 .. Batch_Size'Image'Last)
        & ',' & Avg_Gap'Image (2 .. Avg_Gap'Image'Last)
        & ',' & Variance'Image (2 .. Variance'Image'Last)
        & ',' & Std_Dev'Image (2 .. Std_Dev'Image'Last));
      Ada.Text_IO.Close (File);
   end;

   --  Print dummy plot
   if Print_Graph then
      for B of Bins loop
         for R in 1 .. B loop
            Ada.Text_IO.Put ("X");
         end loop;
         Ada.Text_IO.New_Line;
      end loop;
   end if;

   --  Simulation finished
   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line (
        Ada.Characters.Latin_1.ESC &
        "[0;32mThe simulation finished successfully!");
   Ada.Text_IO.New_Line;
end Bins_And_Balls;
