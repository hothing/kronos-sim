with Kronos2.Memory; use Kronos2.Memory;
with Kronos2.Bus; use Kronos2.Bus;
with Ada.Direct_IO;

package Kronos2.Disks is

   type T_DiskType is (Disk_Is_Floppy, Disk_Is_Hard, Disk_Is_Virtual);

   MaxCylinder : constant := 1024;
   MaxHead     : constant := 255;
   MaxSector   : constant := 63;
   MaxSectorSize : constant := 1024;
   DefaultSectorSize : constant := 512;

   subtype T_DiskCylinder is T_Int range 0 .. MaxCylinder;
   subtype T_DiskHead     is T_Int range 0 .. MaxHead;
   subtype T_DiskSector   is T_Int range 1 .. MaxSector;
   subtype T_DiskSecSize  is T_Int range 1 .. MaxSectorSize;

   type T_DriveSpec is record
      cyls     : T_DiskCylinder; -- amount of cylinders/tracks
      heads    : T_DiskHead; -- amount of heads
      sectrk   : T_DiskSector; -- sectors pro track
      secsize  : T_DiskSecSize; -- size of sector
      dtype    : T_DiskType; -- disk type
   end record;

   package DIO is new Ada.Direct_IO(Element_Type => T_Byte);

   type T_DiskImageDescriptor is record
      hostFile : DIO.File_Type; -- host file contains a disk image
      mntcnt : T_Int; -- mount's counter
      size_s : T_Int; -- disk size in sectors (calculated from spec)
      spec: T_DriveSpec;
   end record;

   MaxDisks : constant := 32;

   type T_DiskImageArray is array (T_Word range 1 .. MaxDisks) of T_DiskImageDescriptor;

   type T_DriveController is record
      dma : P_MemoryBlock;
      hdisks : T_DiskImageArray;
   end record;

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

   -- KRONOS2 disk #0 has 1580 sectors per 512 bytes = 808960 bytes (0.7 MiB)
   -- It can be transleted to CHS(79/2/10) or {79 * 20}

   -- KRONOS2 disk #1 has 41680 sectors per 512 bytes = 21340160 bytes (20.35 MiB)
   -- It can be transleted to CHS(521/2/40) or {521 * 80}

   procedure bind_DiskImage(dc : in out T_DriveController; id : T_Word; image_path : String; ds : T_DriveSpec);
   procedure unbind_DiskImage(dc : in out T_DriveController; id : T_Word);

   function mount(dc : in out T_DriveController; id : T_Word) return Boolean;
   function unmount(dc : in out T_DriveController; id : T_Word) return Boolean;

   function get_size(dc : in out T_DriveController; id : T_Word; memref: T_Word) return Boolean;

   function read(dc : in out T_DriveController; id : T_Word; sec: T_Int; memref: T_Address; len : T_Word) return Boolean;
   function write(dc : in out T_DriveController; id : T_Word; sec: T_Int; memref: T_Address; len : T_Word) return Boolean;

   function get_specs (dc : in out T_DriveController; id : T_Word; memref: T_Address) return Boolean;
   function set_specs (dc : in out T_DriveController; id : T_Word; memref: T_Address) return Boolean;

end Kronos2.Disks;
