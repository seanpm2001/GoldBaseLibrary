﻿namespace runtime;
{$IFDEF ECHOES}
uses
  System.IO, System.Text;
{$ENDIF}

type
  [ValueTypeSemantics]
  Frame = public partial class
  public
    PC: builtin.uintptr;
    Func: builtin.Reference<Func>;
    &Function: String;
    File: String;
    Line: Integer;
    Entry: builtin.uintptr;
  end;
  [ValueTypeSemantics]
  Frames = public partial class
  public
    method Next(): tuple of (Frame, Boolean);
    begin
      exit (nil, false);
    end;
  end;
  [ValueTypeSemantics]
  Func = public partial class

  end;

method Callers(&skip: Integer; pc: builtin.Slice<builtin.uintptr>): Integer;
begin
  exit 0;
end;

method CallersFrames(acallers: builtin.Slice<builtin.uintptr>): builtin.Reference<Frames>;
begin
  exit new builtin.Reference<Frames>(new Frames);
end;

method Stack(buf: builtin.Slice<Byte>; all: Boolean): Integer; public;
begin
  exit 0;
end;

var GOOS: String := {$IFDEF ECHOES}Environment.OSVersion.Platform.ToString{$ELSE}Environment.OSName{$ENDIF};
var GOARCH: String := 'unknown';

method GOROOT: String;
begin
  raise new NotImplementedException;
end;

method StartTrace: builtin.error;
begin
  exit Errors.new('Not supported');
end;

method StopTrace;
begin
  raise new NotImplementedException;
end;

method ReadTrace: builtin.Slice<Byte>;
begin
  raise new NotImplementedException;
end;

method Caller(skip: Integer): tuple of (UIntPtr, String, Integer, Boolean);
begin
  exit (0,'',0, false);
end;

type
  builtin.__Global = public partial class
  private
    {$IFDEF ISLAND}
    class var dtbase : DateTime := new DateTime(1970, 1, 1, 0, 0, 0, 0);
    {$ELSEIF ECHOES}
    class var dtbase : DateTime := new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
    {$ENDIF}

    class method now(): tuple of (Int64, Int32, Int64); assembly;
    begin
      {$IF ISLAND}
      var q := new DateTime(DateTime.UtcNow.Ticks - dtbase.Ticks);
      exit (Int64(q.Ticks / DateTime.TicksPerSecond), (q.Ticks * 100) mod 1 000 000 000, rtl.GetTickCount  * 100);
      {$ELSEIF ECHOES}
      var q := DateTime.UtcNow - dtbase;
      exit (Int64(q.TotalSeconds), (q.Ticks * 100) mod 1 000 000 000, System.Diagnostics.StopWatch.GetTimestamp  * 100);
      {$ENDIF}
    end;

  end;

type
  runtime.trace.__Global = public partial class
  public
    class method userTaskCreate(id, parentID: UInt64; taskType: String);
    begin
      raise new NotImplementedException;
    end;


    class method userTaskEnd(id: UInt64);
    begin
      raise new NotImplementedException;
    end;


    class method userRegion(id, mode: UInt64; regionType: String);
    begin
      raise new NotImplementedException;
    end;

    class method userLog(id: UInt64; category, message: String);
    begin
      raise new NotImplementedException;
    end;
  end;
  &unsafe.__Global = public partial class
  public
    class method Sizeof<T>(o: T): Integer; inline;
    begin
      exit RemObjects.Elements.System.sizeOf(T);
    end;
  end;


  [AliasSemantics]
  syscall.Errno = public record(builtin.error)
  public
    Value: UIntPtr;

    constructor(aValue: UIntPtr);
    begin
      self.Value := aValue;
    end;
    method Error: String;
    begin
      exit Value.ToString;
    end;
  end;


  [AliasSemantics]
  runtime.Error = public record(builtin.error)
  public
    Value: String;

    constructor(aValue: String);
    begin
      self.Value := aValue;
    end;
    method Error: String;
    begin
      exit Value;
    end;
  end;

  [ValueTypeSemantics]
  syscall.SysProcAttr = public class
  public
    HideWindow: Boolean;
    CmdLine: String; // used if non-empty, else the windows command line is built by escaping the arguments passed to StartProcess
    CreationFlags: UInt32;
  end;

  internal.testlog.__Global = public partial class
  public
    class method Getenv(s: String); empty;
    class method Open(s: String); empty;
    class method Stat(s: String); empty;

  end;


  syscall.__Global = public partial class
  public

    class method Getenv(sn: String): tuple of (String, Boolean);
    begin
      var s := Environment.GetEnvironmentVariable(sn);
      if s = nil then
        exit (nil, false);
      exit (s, true);
    end;

    class method Unsetenv(s: String): builtin.error;
    begin
      Environment.SetEnvironmentVariable(s, nil);
    end;

    class method Clearenv: builtin.error;
    begin
      {$IF ISLAND}
      for each el in Environment.GetEnvironmentVariables() do
        Unsetenv(String(el.Key));
      {$ELSEIF ECHOES}
      for each el: System.Collections.DictionaryEntry in Environment.GetEnvironmentVariables() do
        Unsetenv(String(el.Key));
      {$ENDIF}
    end;

    class method Environ: builtin.Slice<String>;
    begin
      {$IF ISLAND}
      var lRes := new List<String>;
      for each el in Environment.GetEnvironmentVariables() do
        lRes.Add(el.Key +'='+el.Value);
      {$ELSEIF ECHOES}
      var lRes := new System.Collections.Generic.List<String>;
      for each el: System.Collections.DictionaryEntry in Environment.GetEnvironmentVariables() do
        lRes.Add(el.Key.ToString() +'='+el.Value);
      {$ENDIF}
      exit new builtin.Slice<String>(lRes.ToArray);
    end;

    class method &Exit(i: Integer);
    begin
      {$IF ISLAND}
      raise new NotImplementedException;
      {$ELSEIF ECHOES}
      Environment.Exit(i);
      {$ENDIF}
    end;

    class method Getuid: Integer;
    begin
      exit -1;
    end;

    class method Geteuid: Integer;
    begin
      exit -1;
    end;

    class method Getgid: Integer;
    begin
      exit -1;
    end;

    class method Getegid: Integer;
    begin
      exit -1;
    end;

    class method Getppid: Integer;
    begin
      exit -1;
    end;

    class method Getpid: Integer;
    begin
      {$IF ISLAND}
      exit Process.CurrentProcessId;
      {$ELSEIF ECHOES}
      exit System.Diagnostics.Process.GetCurrentProcess().Id;
      {$ENDIF}
    end;

  class method Getgroups: tuple of (builtin.Slice<Integer>, builtin.error);
  begin
    exit (new builtin.Slice<Integer>, Errors.New('Not supported'));
  end;

    class var
      ENOENT : syscall.Errno := new syscall.Errno(1); readonly;
    const
      O_RDONLY   = $00000;
      O_WRONLY   = $00001;
      O_RDWR     = $00002;
      O_CREAT    = $00040;
      O_EXCL     = $00080;
      O_NOCTTY   = $00100;
      O_TRUNC    = $00200;
      O_NONBLOCK = $00800;
      O_APPEND   = $00400;
      O_SYNC     = $01000;
      O_ASYNC    = $02000;
      O_CLOEXEC  = $80000;


    class var  ENOTDIR :syscall.Errno := new syscall.Errno(2); readonly;


    class method Setenv(key: String; value: String): builtin.error;
    begin
      var lRes := true;
      if defined('ISLAND') then
        lRes := Environment.SetEnvironmentVariable(key, value)
      else
        if defined('ECHOES') then
          Environment.SetEnvironmentVariable(key, value);

      if lRes = true then
        exit nil
      else
        exit new ExceptionError(new Exception('Error setting environment variable'));
    end;
  end;

  ExceptionError = public class(builtin.error)
  public
    constructor(err: Exception);
    begin
      Exception := err;
    end;
    method Error: String; begin exit Exception.ToString; end;
    property Exception: Exception; readonly;
  end;

  time.__Global = public class
  assembly
    class var zoneSources: builtin.Slice<String> := GetZoneSources();

    class method GetZoneSources:builtin.Slice<String>;
    begin
      exit new builtin.Slice<String>(["/usr/share/zoneinfo/",
      "/usr/share/lib/zoneinfo/",
      "/usr/lib/locale/TZ/"]);
    end;

    class method initLocal;
    begin
      var (tz, ok) := syscall.Getenv("TZ");
      if (not ok) then begin
        var (z, err) := loadLocation("localtime", new builtin.Slice<String>(["/etc/"]));
        if err = nil then begin
          localLoc := builtin.Reference<time.Location>.Get(z);
          localLoc.name := "Local";
          exit;
        end;
      end;
      if (tz <> '') and (tz <> 'UTC') then begin
         var (z, err) := loadLocation(tz, zoneSources);

        if err = nil  then begin
          localLoc := builtin.Reference<time.Location>.Get(z);
          exit;
        end;
      end;

    // Fall back to UTC.
      localLoc.name := "UTC";
    end;

    class method open(name: String): tuple of (Stream, builtin.error);
    begin
      try
        exit (new FileStream(name, FileMode.Open, FileAccess.Read), nil);
      except
        on e: Exception do
          exit (nil, new ExceptionError(e));
       end;
    end;

    class method closefd(fs: Stream);
    begin
      fs.Close;
    end;

    class method preadn(fd: Stream; buff: builtin.Slice<Byte>; off: Integer): builtin.error;
    begin
      if off < 0 then
        fd.Position := fd.Length + off
       else
        fd.Position := off;
      fd.Read(buff.fArray, buff.fStart, buff.Length);
      exit nil;
    end;


    class method read(fd: Stream; buff: builtin.Slice<Byte>): tuple of (Integer, builtin.error);
    begin
      exit (fd.Read(buff.fArray, buff.fStart, buff.Length), nil);
    end;
  public
    class method startTimer(t: builtin.Reference<time.runtimeTimer>);
    begin
      raise new NotImplementedException;
    end;

    class method stopTimer(t: builtin.Reference<time.runtimeTimer>): Boolean;
    begin
      raise new NotImplementedException;
    end;

    class method runtimeNano(): Int64;
    begin
      exit DateTime.Now.Ticks * 100;
    end;

    class method Sleep(x: time.Duration);
    begin
      {$IF ISLAND}
      Thread.Sleep(x.Nanoseconds / 1000000);
      {$ELSEIF ECHOES}
      System.Threading.Thread.Sleep(x.Nanoseconds / 1000000);
      {$ENDIF}
    end;
  end;

  internal.bytealg.__Global = public partial class
  public

    class method Equal(a, b: builtin.Slice<Byte>): Boolean;
    begin
      if a = nil then a := new builtin.Slice<Byte>;
      if b = nil then b := new builtin.Slice<Byte>;
      if a.Length <> b.Length then exit false;

      for i: Integer := 0 to a.Length -1 do
        if a[i] <> b[i] then exit false;
      exit true;
    end;
  end;


  bytes.__Global = public partial class
  public
    class method IndexByte(b: builtin.Slice<Byte>; c: Byte): Integer;
    begin
      for i: Integer := 0 to b.Length -1 do
        if b[i] = c then exit i;
      exit -1;
    end;

    class method Equal(a, b: builtin.Slice<Byte>): Boolean;
    begin
      if a = nil then a := new builtin.Slice<Byte>;
      if b = nil then b := new builtin.Slice<Byte>;
      if a.Length <> b.Length then exit false;

      for i: Integer := 0 to a.Length -1 do
        if a[i] <> b[i] then exit false;
      exit true;
    end;

    class method Compare(a,b: builtin.Slice<Byte>) :Integer;
    begin
      if a = nil then a := new builtin.Slice<Byte>;
      if b = nil then b := new builtin.Slice<Byte>;
      for i: Integer := 0 to Math.Min(a.Length, b.Length) -1 do begin
        if a[i] < b[i] then exit -1;
        if a[i] > b[i] then exit 1;
      end;
      if a.Length < b.Length then
        exit -1;

      if a.Length > b.Length then
        exit 1;
      exit 0;
    end;

  end;

  path.filepath.__Global = public partial class
  public
    class method volumeNameLen(s: String): Integer;
    begin
      if defined('ECHOES') or defined('WINDOWS') then begin
        if defined('ECHOES') and (Environment.OSVersion.Platform = PlatformID.Win32NT) then begin
        end else exit 0;
        if length(s) < 0 then exit 0;
        if s[1] = ':' then exit 2;
      end ;
      exit 0;
    end;

    class method sameWord(a, b: String): Boolean;
    begin
      if defined('WINDOWS') or (defined('ECHOES') and (Environment.OSVersion.Platform = PlatformID.Win32NT)) then
        exit a.ToLowerInvariant = b.ToLowerInvariant;

      exit a = b;
    end;

  end;

  internal.bytealg.__Global = public partial class
  public
    const MaxBruteForce = 0;
    const MaxLen = Int32.MaxValue;

    class method Compare(a, b: builtin.Slice<Byte>): Integer;
    begin
      exit bytes.Compare(a, b);
    end;
    class method Count(b: builtin.Slice<Byte>; c: Byte): Integer;
    begin
      for i: Integer := 0 to b.Length -1 do
        if b[i] = c then inc(resulT);
    end;

    class method CountString(b: String; c: Byte): Integer;
    begin
      for i: Integer := 0 to b.Length -1 do
        if b[i] = Char(c) then inc(resulT);
    end;

    class method IndexByte(b: builtin.Slice<Byte>; c: Byte): Integer;
    begin
      for i: Integer := 0 to b.Length -1 do
        if b[i] = c then exit i;
        exit -1;
    end;

    class method IndexByteString(b: String; c: Byte): Integer;
    begin
      for i: Integer := 0 to b.Length -1 do
        if b[i] = Char(c) then exit i;
        exit -1;
    end;

    class method Index(a, b: builtin.Slice<Byte>): Integer; begin raise new NotSupportedException;end;
    class method IndexString(a, b: String): Integer; begin raise new NotSupportedException;end;
    class method Cutover(nn: Integer): Integer; begin raise new NotSupportedException;end;
  end;

  strings.__Global= public partial class
  public

    class method IndexByte(b: String; c: Byte): Integer;
    begin
      for i: Integer := 0 to b.Length -1 do
        if b[i] = Char(c) then exit i;
        exit -1;
    end;
  end;

  [ValueTypeSemantics]
  strings.Builder = public class(io.Writer)
  private
    fStr: StringBuilder := new StringBuilder;
  public
    method Grow(i: Integer);
    begin
      fStr.Capacity := i;
    end;

    method Cap: Integer;
    begin
      exit fStr.Capacity;
    end;

    method Len: Integer;
    begin
      exit fStr.Length;
    end;

    method Reset;
    begin
      fStr.Clear;
    end;

    method String: String;
    begin
      exit fStr.ToString;
    end;

    method WriteString(s: String);
    begin
      fStr.Append(s);
    end;

    method WriteRune(c: Char);
    begin
      fStr.Append(c);
    end;

    method WriteByte(b: Byte);
    begin
      fStr.Append(Char(b));
    end;

    method Write(p: builtin.Slice<Byte>): tuple of (builtin.int, builtin.error);
    begin
      fStr.Append(Encoding.UTF8.GetString(p.fArray, p.fStart, p.fCount));
      exit (p.fCount, nil);
    end;
  end;

type
  [valueTypeSemantics]
  MemStats = public partial class
  public
  end;

  method ReadMemStats(m: builtin.Reference<MemStats>);
  begin

  end;

end.