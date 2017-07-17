with Kronos2.Memory; use Kronos2.Memory;
with Kronos2.Bus; use Kronos2.Bus;

package Kronos2.Disks is

   type T_DiskStatus is (Disk_Ready,
                         Disk_Floppy,
                         Disk_Wint,
                         Disk_FmtSec,
                         Disk_FmtTrack,
                         Disk_FmtUnit,
                         Disk_Wprot);

   for T_DiskStatus use (Disk_Ready     => 16#01#,
                         Disk_Floppy    => 16#02#,
                         Disk_Wint      => 16#04#,
                         Disk_FmtSec    => 16#08#,
                         Disk_FmtTrack  => 16#10#,
                         Disk_FmtUnit   => 16#20#,
                         Disk_Wprot     => 16#40#);

   type T_DiskRequest is record
      op     : T_Word;
      drn    : T_Word;
      res    : T_Word;
      dmode  : T_Word;
      dsecs  : T_Word; -- device size in secs
      ssc    : T_Word; -- 2**ssc = secsize
      secsize  : T_Word; -- size of sector
      cyls     : T_Word; -- amount of cylinders
      heads    : T_Word; -- amount of heads
      minsec   : T_Word; -- [?] lowest index of sector
      maxsec   : T_Word; -- [?] highest index of sector
      ressec   : T_Word; --  reserved sectors (ice booter in 2.5)
      precomp  : T_Word; --  precompensation
      rate     : T_Word; --  heads stepping
   end record;

   type T_DiskType is (Disk_Is_Floppy, Disk_Is_Hard, Disk_Is_Virtual);

   MaxCylinder : constant := 1024;
   MaxHead     : constant := 255;
   MaxSector   : constant := 63;
   DefaultSectorSize : constant := 512;

   subtype T_DiskCylinder is T_Word range 0 .. 1024;
   subtype T_DiskHead     is T_Word range 0 .. 255;
   subtype T_DiskSector   is T_Word range 1 .. 255;
   subtype T_DiskSecSize  is T_Word range 1 .. 1024;
   subtype T_DiskLongSector   is T_Word range 0 .. T_Word'Last - 1;

   type T_DriveSpec is record
      cyls     : T_DiskCylinder; -- amount of cylinders/tracks
      heads    : T_DiskHead; -- amount of heads
      sectrk   : T_DiskSector; -- sectors pro track
      secsize  : T_DiskSecSize; -- size of sector
      dtype    : T_DiskType; -- disk type
   end record;

   -- KRONOS2 disk #0 has 1580 sectors per 512 bytes = 808960 bytes
   -- It can be transleted to CHS(79/2/10) or {79 * 20}

   -- KRONOS2 disk #1 has 41680 sectors per 512 bytes =
   -- It can be transleted to CHS(521/2/40) or {521 * 80}

   MaxDisks : constant := 32;

   procedure LinkToBus(bus : P_Bus);
   procedure BindDiskImage(id : T_Word; image_path : String; ds : T_DriveSpec);
   procedure UnbindImage(id : T_Word);

   function Mount(id : T_Word) return Boolean;
   function Unmount(id : T_Word) return Boolean;

   function GetSize4Kb(id : T_Word; memref: T_Word) return Boolean;

   function Read(id : T_Word; sec: T_DiskLongSector; memref: T_Word; len : T_Word) return Boolean;
   function Write(id : T_Word; sec: T_DiskLongSector; memref: T_Word; len : T_Word) return Boolean;

   function GetSpecs (id : T_Word; memref: T_Word) return Boolean;
   function SetSpecs (id : T_Word; memref: T_Word) return Boolean;

end Kronos2.Disks;
