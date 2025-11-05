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
-- This simple project models a Galton board a.k.a. Galton box using    --
-- Ada. It has two configuration parameters: Experiments and Levels.    --
-- They hold the number of balls (or repetitions) and the number of le- --
-- vels of the box, respectively. In addition, it uses PLplot to gener- --
-- ate some informative plots regarding the outcome of the experiment.  --
--                                                                      --
-- NOTE that this crate uses Ada2022 and is quite verbose in order to   --
-- make it understandable for those that are not familiarized with the  --
-- language.                                                            --
--                                                                      --
--------------------------------------------------------------------------

with Ada.Characters.Latin_1;
with Ada.Text_IO;

with Allocation_Schemes;

procedure Bins_And_Balls is

   use Allocation_Schemes;

   --  Program paramenters
   N_Balls  : constant            := 21;
   M_Bins   : constant            := 7;
   D        : constant            := 7;
   Strategy : constant Strategies := D_Choice;
   β        : constant            := 0.05;

   --  Batched configuration
   Batched    : constant Boolean := True;
   Batch_Size : constant         := N_Balls / M_Bins;

   --  Rustic visualization
   Print_Graph : constant Boolean := True;

   --  Array holding ball x bins
   Bins : Unbounded_Integer_Array (1 .. M_Bins);

   --  Output file
   File      : Ada.Text_IO.File_Type;
   File_Name : constant String := "results.csv";

begin

   --  Print simulation start and information
   Ada.Text_IO.Put_Line ("BINS AND BALLS SIM START");
   Ada.Text_IO.Put_Line (Ada.Characters.Latin_1.ESC & "[1;34m");
   Ada.Text_IO.Put_Line ("Balls (N) = " & N_Balls'Image);
   Ada.Text_IO.Put_Line ("Bins  (M) = " & M_Bins'Image);

   --  Main body : simulate each ball independently
   declare
      Current_Batch : Integer := (if Batched then Batch_Size else 1);
      Bin_Allocation : Unbounded_Integer_Array (1 .. M_Bins);
   begin
      for Ball in 1 .. N_Balls loop
         declare
            --  Allocate a bin for the given ball
            Allocated_Bin : constant Integer :=
              Allocation_Schemes.Assign_Bin
               (Strategy => Strategy,
                M_Bins   => M_Bins,
                D        => D,
                β        => β,
                Status   => Bins);
         begin
            --  Update bins
            if Batched and then Batch_Size > 1 then
               Current_Batch := @ - 1;
               Bin_Allocation (Allocated_Bin) := @ + 1;
               if Current_Batch = 0 then
                  Bins           := @ + Bin_Allocation;
                  Current_Batch  := (if Batched then Batch_Size else 1);
                  Bin_Allocation := [others => 0];
               end if;
            else
               Bins (Allocated_Bin) := @ + 1;
            end if;
         end;
      end loop;
   end;

   --  Write to a CSV file the results
   --  Ada.Text_IO.Create (File, Ada.Text_IO.Out_File, File_Name);
   --  Ada.Text_IO.Put_Line (File, "i,balls");
   --  for I in Cell_Index loop
   --   Ada.Text_IO.Put_Line (
   --     File, I'Image (2 .. I'Image'Last) &
   --     ',' & Cells (I)'Image (2 .. Cells (I)'Image'Last));
   --  end loop;
   --  Ada.Text_IO.Close (File);

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
