with Ada.Direct_IO;
with Kronos2.Bus;

package body Kronos2.Disks is

   package IO is new Ada.Direct_IO(T_Byte);

   type Disk_Image is record
      spec  : T_DriveSpec; -- disk specification
      img   : IO.File_Type; -- refernse to a file with image
      lnkd  : Boolean; -- is linked to the bus
      mntc  : T_Word; -- count of mount references
   end record;

   subtype Imgs_Index is T_Word range 1 .. MaxDisks;
   type Imgs_Array is array(Imgs_Index) of Disk_Image;

   lbus : P_Bus;
   dsks : Imgs_Array;

   procedure setAddress(addr: T_Address) is
   begin
      lbus.addr := addr;
   end setAddress;


   procedure LinkToBus(bus : P_Bus) is
   begin
      for id in dsks'Range loop
         if dsks(id).lnkd then
            IO.Close(dsks(id).img);
         end if;
         dsks(id).mntc := 0;
         dsks(id).lnkd := False;
         dsks(id).spec := (cyls => T_DiskCylinder'First,
                           heads    => T_DiskHead'First,
                           sectrk   => T_DiskSector'First,
                           secsize  => T_DiskSecSize'First,
                           dtype    => T_DiskType'First
                          );
      end loop;
      lbus := bus;
   end LinkToBus;

   -------------------
   -- BindDiskImage --
   -------------------

   procedure BindDiskImage (id : T_Word; image_path : String; ds : T_DriveSpec) is
      t : Boolean;
      sz : T_Word;
   begin
      if not dsks(id).lnkd then
         -- check the specification
         t := ds.cyls > 0;
         t := t and ds.heads > 0;
         t := t and ds.sectrk > 1;
         t := t and ds.secsize > 1;
         -- calculate a disk size
         sz := dsks(id).spec.sectrk
           * dsks(id).spec.secsize
           * dsks(id).spec.cyls
           * dsks(id).spec.heads;
         -- TODO: add logging message here
         if t then
            IO.Open(dsks(id).img, IO.Inout_File, image_path);
            dsks(id).spec := ds;
            dsks(id).lnkd := t;
            dsks(id).mntc := 0;
         else
            raise Program_Error with "Disk specification is invalid";
         end if;
      else
         raise Program_Error with "Disk is already bound to this position";
      end if;
   end BindDiskImage;

   -----------------
   -- UnbindImage --
   -----------------

   procedure UnbindImage (id : T_Word) is
   begin
      if dsks(id).lnkd and dsks(id).mntc < 1 then
         IO.Close(dsks(id).img);
         dsks(id).mntc := 0;
      end if;
   end UnbindImage;

   -----------
   -- Mount --
   -----------

   function Mount (id : T_Word) return Boolean is
   begin
      if dsks(id).lnkd then
         dsks(id).mntc := dsks(id).mntc + 1;
      end if;
      return dsks(id).lnkd;
   end Mount;

   --------------
   -- Dismount --
   --------------

   function Unmount (id : T_Word) return Boolean is
   begin
      if dsks(id).lnkd then
         if dsks(id).mntc > 0 then
            dsks(id).mntc := dsks(id).mntc - 1;
         end if;
      end if;
      return dsks(id).lnkd and dsks(id).mntc >= 0;
   end Unmount;

   ----------------
   -- GetSize4Kb --
   ----------------

   function GetSize4Kb (id : T_Word; memref: T_Word) return Boolean is
      r : Boolean;
   begin
      r := False ;
      if dsks(id).lnkd then
         declare
            sz : IO.Positive_Count;
            size : T_Word;
         begin
            r := Mount(id);
            -- NOTE: This code is direct translated from source of KRONOS-VM
            --       But I think, here must be a calculation from disk specification
            sz := IO.Size(dsks(id).img); -- size of elements = T_Byte'Size
            size := T_Word(sz) / 4096;
            -- calculate size from the drive specification
            size := dsks(id).spec.sectrk
              * dsks(id).spec.secsize
              * dsks(id).spec.cyls
              * dsks(id).spec.heads;
            -- TODO: add logging here to indicate that a file size is not equal a disk size
            -- TODO: a reaction to invalid specification
            setAddress(memref);
            Bus.writeMem(lbus, size);
            r := Bus.getStatus(lbus) = Bus_Ready;
            r := r and Unmount(id);
         exception
            when IO.Data_Error => r := False ;
            when IO.End_Error => r := False ;
            when IO.Status_Error => r := False ;
            when IO.Mode_Error => r := False ;
            when IO.Device_Error => r := False ;
         end;
      end if;
      return r;
   end GetSize4Kb;

   function CalcOffset(id : T_Word; sec: T_DiskLongSector) return IO.Positive_Count
   is
      s : T_DiskLongSector;
   begin
      if sec > T_DiskLongSector'Last - dsks(id).spec.secsize then
         s := T_DiskLongSector'Last - dsks(id).spec.secsize;
      else
         s := sec;
      end if;
      return IO.Positive_Count(dsks(id).spec.secsize * sec + 1);
   end CalcOffset;

   ----------
   -- Read --
   ----------

   function Read
     (id : T_Word; sec: T_DiskLongSector; memref: T_Word; len : T_Word) return Boolean
   is
      r : Boolean;
   begin
      r := False ;

      if dsks(id).lnkd then

         declare
            v : T_Byte;
            mnd : Bus.T_DMA_Mandat;
         begin
            r := Mount(id);
            -- it looks like a translation to linear addressing
            Bus.beginDMA(lbus, memref, len, mnd);
            IO.Set_Index(dsks(id).img, CalcOffset(id, sec));
            for i in 1 .. len loop
               IO.Read(dsks(id).img, v);
               Bus.writeDMAByte(mnd, v);
               r := r and Bus.getStatus(lbus) = Bus_MemoryTransfer;
               exit when not r; -- no sense to continue the reading
            end loop;
            -- NOTE: this code is strange, beacuse usualy
            --       the disk drive can read only sector-by-sector
            --       and cannot read a byte.
            -- NOTE2: Argh! It is only optimization!
            Bus.endDMA(mnd);
            r := r and Unmount(id);
         exception
            when IO.Data_Error => r := False ;
            when IO.End_Error => r := False ;
            when IO.Status_Error => r := False ;
            when IO.Mode_Error => r := False ;
            when IO.Device_Error => r := False ;
         end;
      end if;

      return r;
   end Read;

   -----------
   -- Write --
   -----------

   function Write
     (id : T_Word; sec: T_DiskLongSector; memref: T_Word; len : T_Word) return Boolean
   is
      r : Boolean;
      m : T_DMA_Mandat;
   begin
      r := False ;

      if dsks(id).lnkd then

         declare
            v : T_Byte;
         begin
            r := Mount(id);
            IO.Set_Index(dsks(id).img, CalcOffset(id, sec));
            Bus.beginDMA(lbus, memref, len, m);
            for i in 1 .. len loop
               v := Bus.readDMAByte(m);
               r := r and Bus.getStatus(lbus) = Bus_MemoryTransfer;
               exit when not r; -- no sense to continue the writing
               IO.Write(dsks(id).img, v);
            end loop;
            Bus.endDMA(m);
            r := r and Unmount(id);
         exception
            when IO.Data_Error => r := False ;
            when IO.End_Error => r := False ;
            when IO.Status_Error => r := False ;
            when IO.Mode_Error => r := False ;
            when IO.Device_Error => r := False ;
         end;
      end if;

      return r;
   end Write;

   --------------
   -- GetSpecs --
   --------------

   function GetSpecs (id : T_Word; memref: T_Word) return Boolean is
   begin
      pragma Compile_Time_Warning (Standard.True, "GetSpecs unimplemented");
      return False;
   end GetSpecs;

   --------------
   -- SetSpecs --
   --------------

   function SetSpecs (id : T_Word; memref: T_Word) return Boolean is
   begin
      pragma Compile_Time_Warning (Standard.True, "SetSpecs unimplemented");
      return False;
   end SetSpecs;

end Kronos2.Disks;
