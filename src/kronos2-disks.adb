with Ada.Direct_IO;
with Ada.Unchecked_Conversion;
with Kronos2.Memory; use Kronos2.Memory;

package body Kronos2.Disks is

   -------------------
   -- BindDiskImage --
   -------------------

   procedure bind_DiskImage(dc : in out T_DriveController; id : T_Word; image_path : String; ds : T_DriveSpec) is
      t : Boolean;
   begin
      if dc.hdisks(id).mntcnt <= 0 then
         -- check the specification
         t := ds.cyls > 0;
         t := t and ds.heads > 0;
         t := t and ds.sectrk > 1;
         t := t and ds.secsize > 1;
         if t then
            declare
               sz : DIO.Positive_Count;
               size0, size1 : T_Int;
            begin
               DIO.Open(dc.hdisks(id).hostFile, DIO.Inout_File, image_path);
               sz := DIO.Size(dc.hdisks(id).hostFile); -- size of elements = T_Byte'Size
               size0 := T_Int(sz) / ds.secsize; -- size in sectors
               -- calculate a disk size by specification
               size1 := ds.sectrk * ds.cyls * ds.heads;
               -- TODO: add logging message here
               if size0 >= size1 then
                  dc.hdisks(id).spec := ds;
                  dc.hdisks(id).mntcnt := 0;
                  dc.hdisks(id).size_s := size1;
               else
                   -- TODO: a reaction to invalid specification
                  null;
               end if;
            end;
         else
            raise Program_Error with "Disk specification is invalid";
         end if;
      else
         raise Program_Error with "Disk is already bound to this position";
      end if;
   end Bind_Diskimage;

   -----------------
   -- UnbindImage --
   -----------------

   procedure unbind_DiskImage(dc : in out T_DriveController; id : T_Word) is
   begin
      if id in dc.hdisks'Range then
         if dc.hdisks(id).mntcnt < 1 then
            DIO.Close(dc.hdisks(id).hostFile);
            dc.hdisks(id).mntcnt := -1;
         end if;
      end if;
   end unbind_DiskImage;

   -----------
   -- Mount --
   -----------

   function Mount (dc : in out T_DriveController; id : T_Word) return Boolean is
      r : Boolean;
   begin
      r := false;
      if id in dc.hdisks'Range then
         if dc.hdisks(id).mntcnt >= 0 then
            dc.hdisks(id).mntcnt := dc.hdisks(id).mntcnt + 1;
         end if;
         r := dc.hdisks(id).mntcnt > 0;
      end if;
      return r;
   end Mount;

   --------------
   -- Dismount --
   --------------

   function Unmount (dc : in out T_DriveController; id : T_Word) return Boolean is
      mc : T_Int;
      r : Boolean := False;
   begin
      if id in dc.hdisks'Range then
         mc := dc.hdisks(id).mntcnt;
         if dc.hdisks(id).mntcnt > 0 then
            dc.hdisks(id).mntcnt := dc.hdisks(id).mntcnt - 1;
         end if;
         r := dc.hdisks(id).mntcnt < mc;
      end if;
      return r;
   end Unmount;

   ----------------
   -- GetSize4Kb --
   ----------------

   function Word2Int is new Ada.Unchecked_Conversion(Source => T_Word,
                                                     Target => T_Int);

   function Int2Word is new Ada.Unchecked_Conversion(Source => T_Int,
                                                     Target => T_Word);


   function get_size(dc : in out T_DriveController; id : T_Word; memref: T_Address) return Boolean is
      r : Boolean := False;
      size_s : T_Int;
      U_4K : constant := 4096;
   begin
      if id in dc.hdisks'Range then
         if dc.hdisks(id).mntcnt >= 0 then
            if Mount(dc, id) then
               --  if dc.hdisks(id).size_s >= U_4K then
               --     size_s := (dc.hdisks(id).size_s / 4096) * dc.hdisks(id).spec.secsize;
               --  else
               --     size_s := (dc.hdisks(id).size_s * dc.hdisks(id).spec.secsize) / 4096;
               --  end if;
               size_s := (dc.hdisks(id).size_s * dc.hdisks(id).spec.secsize) / 4096;
               write(dc.dma.all, memref, Int2Word(size_s));
               r := Unmount(dc, id);
            end if;
         end if;
      end if;
      return r;
   end Get_Size;

   function Calc_Offset(dc : in out T_DriveController; id : T_Word; sec: T_Int) return DIO.Positive_Count
   is
      s : T_Int;
      max_s : constant := MaxCylinder * MaxHead * MaxSector;
   begin
      s := (max_s) / dc.hdisks(id).spec.secsize;
      if sec <= s then
         s := sec;
      else
         s := max_s;
      end if;
      return DIO.Positive_Count(s);
   end Calc_Offset;

   ----------
   -- Read --
   ----------

   function Read
     (dc : in out T_DriveController; id : T_Word; sec: T_Int; memref: T_Address; len : T_Word) return Boolean
   is
      r : Boolean := False;
   begin
      if id in dc.hdisks'Range then
         declare
            v : T_Byte;
            addr : T_Address := memref;
         begin
            if Mount(dc, id) then
            -- it looks like a translation to linear addressing
            DIO.Set_Index(dc.hdisks(id).hostFile, Calc_Offset(dc, id, sec));
            for i in 1 .. len loop
               DIO.Read(dc.hdisks(id).hostFile, v);
               write(dc.dma.all, addr, v);
               addr := addr + 1;
            end loop;
            -- NOTE: this code is strange, beacuse usualy
            --       the disk drive can read only sector-by-sector
            --       and cannot read a byte.
            -- NOTE2: Argh! It is only optimization!
               r := Unmount(dc, id);
            end if;
         exception
            when DIO.Data_Error => r := False ;
            when DIO.End_Error => r := False ;
            when DIO.Status_Error => r := False ;
            when DIO.Mode_Error => r := False ;
            when DIO.Device_Error => r := False ;
         end;
      end if;

      return r;
   end Read;

   -----------
   -- Write --
   -----------

   function Write
     (dc : in out T_DriveController; id : T_Word; sec: T_Int; memref: T_Address; len : T_Word) return Boolean
   is
      r : Boolean;
   begin
     if id in dc.hdisks'Range then
         declare
            v : T_Byte;
            addr : T_Address := memref;
         begin
            if Mount(dc, id) then
            -- it looks like a translation to linear addressing
            DIO.Set_Index(dc.hdisks(id).hostFile, Calc_Offset(dc, id, sec));
            for i in 1 .. len loop
               v := read(dc.dma.all, addr);
               DIO.Write(dc.hdisks(id).hostFile, v);
               addr := addr + 1;
            end loop;
            -- NOTE: this code is strange, beacuse usualy
            --       the disk drive can read only sector-by-sector
            --       and cannot read a byte.
            -- NOTE2: Argh! It is only optimization!
               r := Unmount(dc, id);
            end if;
         exception
            when DIO.Data_Error => r := False ;
            when DIO.End_Error => r := False ;
            when DIO.Status_Error => r := False ;
            when DIO.Mode_Error => r := False ;
            when DIO.Device_Error => r := False ;
         end;
      end if;
      return r;
   end Write;

   --------------
   -- GetSpecs --
   --------------

   function Get_Specs (dc : in out T_DriveController; id : T_Word; memref: T_Address) return Boolean is
   begin
      pragma Compile_Time_Warning (Standard.True, "GetSpecs unimplemented");
      return False;
   end Get_Specs;

   --------------
   -- SetSpecs --
   --------------

   function Set_Specs (dc : in out T_DriveController; id : T_Word; memref: T_Address) return Boolean is
   begin
      pragma Compile_Time_Warning (Standard.True, "SetSpecs unimplemented");
      return False;
   end Set_Specs;

end Kronos2.Disks;
