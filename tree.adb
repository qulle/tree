-- Author: Qulle 2017-12-20
-- Github: github.com/qulle/tree
-- Editor: vscode (initially emacs)
-- Compile: gnatmake ./tree.adb
-- Run: ./tree --help

with Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Float_Text_IO;
with Ada.Directories;
with Ada.Command_Line;
with Ada.Calendar.Formatting;

procedure Tree is
    package   CL renames Ada.Command_Line;
    package  DIR renames Ada.Directories;
    package  CAL renames Ada.Calendar;
    package T_IO renames Ada.Text_IO;
    package I_IO renames Ada.Integer_Text_IO;
    package F_IO renames Ada.Float_Text_IO;

    C_RESET    : constant String := "[00m";
    BOLD       : constant String := "[01m";
    C_RED      : constant String := "[31m";
    FC_GREEN   : constant String := "[32m";
    FC_YELLOW  : constant String := "[33m";
    FC_BLUE    : constant String := "[34m";
    FC_MAGENTA : constant String := "[35m";
    FC_CYAN    : constant String := "[36m";
   
    FC_DIRECTORY : constant String := FC_GREEN;
    FC_SIZE      : constant String := FC_CYAN;
    FC_DATE      : constant String := FC_YELLOW;

    SPACING         : constant Natural := 6; 
    Num_Files       : Natural := 0;
    Num_Directories : Natural := 0;
    Level           : Natural := 0;
   
    type Settings_Type is array(Character range 'a' .. 'z') of Boolean;
    Settings : Settings_Type := (others => False);
   
    procedure Print_Branch(C : in Character) is
        I : Natural := Level;
    begin
        while I > 0 loop
            if I mod SPACING = 0 then
                T_IO.Put('|');
            else
                T_IO.Put(' ');
            end if;
            I := I - 1;
        end loop;
        T_IO.Put(C & "---");
    end Print_Branch;   
   
    procedure Print_Size(Item : in DIR.Directory_Entry_Type) is
    begin
        T_IO.Put(Ascii.Esc & FC_CYAN & "[");
        F_IO.Put(Float(DIR.Size(Item)) / 1000.0, Fore => 0, Aft => 0, Exp => 0);
        T_IO.Put("kB]" & Ascii.Esc & C_RESET);
    end Print_Size;
   
    procedure Print_Modified_Time(Item : in DIR.Directory_Entry_Type) is
    begin
        T_IO.Put(Ascii.Esc & FC_YELLOW & "[");
        T_IO.Put(CAL.Formatting.Image(DIR.Modification_Time(Item)));
        T_IO.Put("]" & Ascii.Esc & C_RESET);
    end Print_Modified_Time;
   
    procedure Walk(Name : in String; Pattern : in String) is      
        procedure Print(Item : in DIR.Directory_Entry_Type) is
        begin
            if DIR.Simple_Name(Item) /= "." and then DIR.Simple_Name(Item) /= ".." then
                case DIR.Kind(Item) is
                    when DIR.Directory => null;
                    when DIR.Ordinary_File | DIR.Special_File => 
                        Num_Files := Num_Files + 1;
                        Print_Branch('|');
            
                        if Settings('s') then
                            Print_Size(Item);
                        end if;
            
                        if Settings('m') then
                            Print_Modified_Time(Item);
                        end if;
            
                        if Settings('f') then
                            T_IO.Put_Line(Ascii.Esc & BOLD & DIR.Full_Name(Item) & Ascii.Esc & C_RESET);
                        else
                            T_IO.Put_Line(Ascii.Esc & BOLD & DIR.Simple_Name(Item) & Ascii.Esc & C_RESET);
                        end if;
                end case;
            end if;
        exception
            when DIR.Name_Error => null;
        end Print;  
      
        procedure Walk(Item : in DIR.Directory_Entry_Type) is
        begin
            if DIR.Simple_Name(Item) /= "." and then DIR.Simple_Name(Item) /= ".." then
                Print_Branch('+');
                T_IO.Put_Line(Ascii.Esc & BOLD & Ascii.Esc & FC_DIRECTORY & DIR.Simple_Name(Item) & Ascii.Esc & C_RESET);
                Level := Level + SPACING;
                Num_Directories := Num_Directories + 1;
                Walk(DIR.Full_Name(Item), Pattern);   
            end if;
        exception
            when DIR.Name_Error => null;
        end Walk;
    begin
        DIR.Search(Name, Pattern, (others => True), Print'Access);
        DIR.Search(Name, "", (DIR.Directory => True, others => False), Walk'Access);
        if Level > 0 then
            Level := Level - SPACING;
        end if;
    exception
        when DIR.Name_Error => null;
    end Walk; 
   
    procedure Set_Settings(Argument : in String) is
    begin
        for I in Natural range 2 .. Argument'Length loop        
            if Character'Pos(Argument(I)) >= 97 and Character'Pos(Argument(I)) <= 122 then
                Settings(Argument(I)) := True;
            end if;
        end loop;
    end Set_Settings;
begin
    T_IO.Put_Line(Ascii.Esc & BOLD & Ascii.Esc & FC_DIRECTORY & "+" & Ascii.Esc & C_RESET);
   
    if CL.Argument_Count > 0 then
        if(CL.Argument(1) = "--help") then
            T_IO.Put_Line("./tree [path] -smf");
            T_IO.Put_Line("   -s : print size");
            T_IO.Put_Line("   -m : print modification time");
            T_IO.Put_Line("   -f : print full path");
        else
            if CL.Argument_Count = 1 then
                if CL.Argument(1)(1) = '-' then
                    Set_Settings(CL.Argument(1));
                    Walk(".", "*");
                else
                    Walk(CL.Argument(1), "*");
                end if;
            elsif CL.Argument_Count > 1 then
                Set_Settings(Cl.Argument(2));
                Walk(CL.Argument(1), "*");
            end if;
        end if;
    else
        Walk(".", "*");
    end if;
   
    T_IO.New_Line;
    I_IO.Put(Num_Directories, Width => 0);
    T_IO.Put(" directories, ");
    I_IO.Put(Num_Files, Width => 0);
    T_IO.Put_Line(" files");
end Tree;