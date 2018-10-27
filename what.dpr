  {$APPTYPE console}
{$HINTS OFF}
{$WARNINGS OFF}
program What;

uses Crt, Sysutils;

var F: File of Char;
    SR: TSearchRec;
    S: String;
    I: Integer;
    Extinfo: Boolean;

function CFn(Filename: String): String;
var s1, s2, s3: string;
begin
  s1:=filename;
  s2:='';
  s3:=copy(s1, pos('.', s1), 10);
  delete(s1, pos('.', s1), 10);
  If Length(Filename)>12 Then
    Begin
      s2:='...';
      delete(s1, 11, length(filename));
    End;
  CFn:=s1+s2+s3;
end;

procedure Scan_ACE;
const ACE_const: Array[1..7] of char = '**ACE**';
      Host_OS: Array[0..11] of String = ('MS-DOS', 'OS/2', 'Win32', 'Unix', 'MAC-OS', 'Win NT', 'Primos', 'APPLE GS', 'ATARI', 'VAX VMS', 'AMIGA', 'NEXT');
type  TACE = Record
//               Head_CRC: Word;
               Head_SIZE: Word;
               Head_TYPE: Byte;
               Head_FLAGS: Word;
               Acesign: Array[1..7] of char;
               Ver_EXTRACT: Byte;
               Ver_CREATED: Byte;
               Host_CREATED: Byte;
               Volume_NUM: Byte;
               Time_CREATED: LongWord;
               Reserved: Array[1..2] of LongWord;
             End;
var   A : TACE;
begin
  {$I-}
  If Filesize(F) < SizeOf(A) Then Exit;
  TextColor(13);
  Seek(F, 1);
  BlockRead(F, A, SizeOf(A));
  If (A.Acesign = ACE_const) Then
    Begin
      TextColor(13);
      Write('ACE Archive (.ACE or .C*), ');
      If (A.Head_FLAGS and $0001) > 0 Then Write('no ADDSIZE field, '); TextColor(13); Write('');
      If (A.Head_FLAGS and $0002) > 0 Then Write('presence of a main comment, '); TextColor(13); Write('');
      If (A.Head_FLAGS and $0200) > 0 Then Write('SFX archive, '); TextColor(13); Write('');
      If (A.Head_FLAGS and $0400) > 0 Then Write('dictionary size limited to 256k, '); TextColor(13); Write('');
      If (A.Head_FLAGS and $0800) > 0 Then Write('archive consist of multiple volumes, '); TextColor(13); Write('');
      If (A.Head_FLAGS and $1000) > 0 Then Write('main header contains AV-string, '); TextColor(13); Write('');
      If (A.Head_FLAGS and $2000) > 0 Then Write('recovery record present, '); TextColor(13); Write('');
      If (A.Head_FLAGS and $4000) > 0 Then Write('archive is locked, '); TextColor(13); Write('');
      If (A.Head_FLAGS and $8000) > 0 Then Write('archive is solid, '); TextColor(13); Write('');
      If (A.Head_FLAGS and $0800) > 0 Then Write('volume num ', IntToStr(A.Volume_NUM)); TextColor(13); Write('');
      If ExtInfo Then
        Begin
          TextColor(13);
          WriteLn;
          GotoXY(20, WhereY);
          Writeln('Version needed to extract: ', IntToStr(A.Ver_EXTRACT), ', version used to create: ', IntToStr(A.Ver_CREATED));
          GotoXY(20, WhereY);
          TextColor(13);
          Write('');
          Write('Created under ', Host_OS[A.Host_CREATED]);
        End;
      TextColor(13);
      Write('');
    End;
end;

procedure Scan_DOC;
Const ID: Array[1..8] of Byte = ($D0, $CF, $11, $E0, $A1, $B1, $1A, $E1);
Var   IDm: Array[1..8] of Byte;
      Match: Boolean;
Begin
  TextColor(7);
  Seek(F, 0);
  BlockRead(F, IDm, 8);
  Match := True;
  For I := 1 To 8 Do
    If IDm[I] <> ID[I] Then Match := False;

  If Match Then
    Begin
      TextColor(7);
      Write('Microsoft Office Format (possibly .DOC)');
      TextColor(7);
      Write('');
    End;
End;

procedure Scan_XA;
Const ID: Array[1..4] of Char = ('X', 'A', 'J', #0);
Var   IDm: Array[1..4] of Char;
      Match: Boolean;
Begin
  TextColor(12);
  Seek(F, 0);
  BlockRead(F, IDm, 4);
  Match := True;
  For I := 1 To 4 Do
    If IDm[I] <> ID[I] Then Match := False;

  If Match Then
    Begin
      TextColor(12);
      Write('Maxis XA Sound File (.XA)');
      TextColor(12);
      Write('');
    End;
End;

procedure Scan_RTF;
Const ID: Array[1..7] of Char = ('{', '\', 'r', 't', 'f', '1', '\');
Var   IDm: Array[1..7] of Char;
      Match: Boolean;
Begin
  TextColor(7);
  Seek(F, 0);
  BlockRead(F, IDm, 7);
  Match := True;
  For I := 1 To 7 Do
    If IDm[I] <> ID[I] Then Match := False;

  If Match Then
    Begin
      TextColor(7);
      Write('Rich Text File Format (.RTF)');
      TextColor(7);
      Write('');
    End;
End;

procedure Scan_REG;
Const ID: Array[1..8] of Char = ('R', 'E', 'G', 'E', 'D', 'I', 'T', '4');
Var   IDm: Array[1..8] of Char;
      Match: Boolean;
Begin
  TextColor(7);
  Seek(F, 0);
  BlockRead(F, IDm, 8);
  Match := True;
  For I := 1 To 8 Do
    If IDm[I] <> ID[I] Then Match := False;

  If Match Then
    Begin
      TextColor(7);
      Write('Windows Registry File (.REG)');
      TextColor(7);
      Write('');
    End;
End;

procedure Scan_GAM;
Const ID: Array[1..2] of Byte = ($EC, $BD);
Var   IDm: Array[1..2] of Byte;
      Match: Boolean;
Begin
  TextColor(15);
  Seek(F, 0);
  BlockRead(F, IDm, 2);
  Match := True;
  For I := 1 To 2 Do
    If IDm[I] <> ID[I] Then Match := False;

  If Match Then
    Begin
      TextColor(15);
      Write('Age of Empires II Save Game File (.GAM)');
      TextColor(15);
      Write('');
    End;
End;

procedure Scan_PUD;
Const ID: Array[1..16] of Byte = ($54, $59, $50, $45, $10, $00, $00, $00, $57, $41, $52, $32, $20, $4D, $41, $50);
Var   IDm: Array[1..16] of Byte;
      Match: Boolean;
Begin
  TextColor(15);
  Seek(F, 0);
  BlockRead(F, IDm, 16);
  Match := True;
  For I := 1 To 16 Do
    If IDm[I] <> ID[I] Then Match := False;

  If Match Then
    Begin
      TextColor(15);
      Write('Warcraft II Map File (.PUD)');
      TextColor(15);
      Write('');
    End;
End;

procedure Scan_FAR;
Const ID: Array[1..8] of Char = ('F', 'A', 'R', '!', 'b', 'y', 'A', 'Z');
Var   IDm: Array[1..8] of Char;
      Match: Boolean;
Begin
  TextColor(15);
  Seek(F, 0);
  BlockRead(F, IDm, 8);
  Match := True;
  For I := 1 To 8 Do
    If IDm[I] <> ID[I] Then Match := False;

  If Match Then
    Begin
      TextColor(15);
      Write('Maxis FAR File (.FAR)');
      TextColor(15);
      Write('');
    End;
End;

procedure Scan_IFF;
Const ID: Array[1..35] of Char = ('I', 'F', 'F', ' ', 'F', 'I', 'L', 'E', ' ', '2', '.', '5',
                                 ':', 'T', 'Y', 'P', 'E', ' ', 'F', 'O', 'L', 'L', 'O', 'W',
                                 'E', 'D', ' ', 'B', 'Y', ' ', 'S', 'I', 'Z', 'E', #0);
Var   IDm: Array[1..35] of Char;
      Match: Boolean;
Begin
  TextColor(15);
  Seek(F, 0);
  BlockRead(F, IDm, 35);
  Match := True;
  For I := 1 To 35 Do
    If IDm[I] <> ID[I] Then Match := False;

  If Match Then
    Begin
      TextColor(15);
      Write('Maxis IFF File (.IFF)');
      TextColor(15);
      Write('');
    End;
End;

procedure Scan_DRS;
Const ID: Array[1..37] of Char = ('C', 'o', 'p', 'y', 'r', 'i', 'g', 'h', 't', ' ', '(',
                                  'c', ')', ' ', '1', '9', '9', '7', ' ', 'E', 'n', 's',
                                  'e', 'm', 'b', 'l', 'e', ' ', 'S', 't', 'u', 'd', 'i',
                                  'o', 's', '.', #26);
Var   IDm: Array[1..37] of Char;
      Match: Boolean;
Begin
  TextColor(15);
  Seek(F, 0);
  BlockRead(F, IDm, 37);
  Match := True;
  For I := 1 To 37 Do
    If IDm[I] <> ID[I] Then Match := False;

  If Match Then
    Begin
      TextColor(15);
      Write('Age of Empires II Drs File (.DRS)');
      TextColor(15);
      Write('');
    End;
End;

procedure Scan_CAB;
const MSCF_const: Array[1..4] of char = 'MSCF';
type  TMSCF = Record
                MSCF_Sign : Array[1..4] of char;
                Folders   : Word;
                Files     : Word;
              End;
var   M : TMSCF;
begin
  {$I-}
  If Filesize(F)<$90 Then Exit;
  TextColor(13);
  Seek(F, 0);
  BlockRead(F, M.MSCF_Sign, 4);
  If (M.MSCF_Sign = MSCF_const) Then
    Begin
      Seek(F, 26);
      BlockRead(F, M.Folders, 2);
      BlockRead(F, M.Files, 2);
      TextColor(13);
      Write('Windows Cabinet File (.CAB), Folders: ', M.Folders, ', Files: ', M.Files);
      TextColor(13);
      Write('');
    End;
end;

Procedure Scan_CHR;
const CHR_const : Array[1..8] of char = 'PK'+#08+#08+'BGI ';
type  TCHR = Record
               CHR_Sign : Array[1..8] of char;
               Stroked  : Char;
             End;
var   M : TCHR;
begin
  {$I-}
  If Filesize(F)<$90 Then Exit;
  TextColor(11);
  Seek(F, 0);
  BlockRead(F, M.CHR_Sign, 8);
  If (M.CHR_Sign = CHR_const) Then
    Begin
      Seek(F, 128);
      BlockRead(F, M.Stroked, 1);
      TextColor(11);
      Write('Borland Pascal Font File (.CHR)');
      If M.Stroked='+' Then Write(', Stroke Font');

      TextColor(11); Write('');
    End;
end;

Procedure Scan_WAV;
type TWAV = Record
              rID     : Array[1..4] of char;
              rLEN    : Longint;
              wID     : Array[1..4] of char;
              fID     : Array[1..4] of char;
              fLEN    : Longint;
              wFmtTag : Word;
              nChanel : Word;
              nSamplePerSec   : Word;
              nAvgBytesPerSec : Word;
              nBlkAlg : Word;
              FmtSpec : Word;
              Temp    : Word;
              BitPSec : Word;
            End;
var M : TWAV;
begin
  {$I-}
  If Filesize(F)<SizeOf(M) Then Exit;
  TextColor(12);
  Seek(F, 0);
  BlockRead(F, M, SizeOf(M));
  If (M.rID = 'RIFF') and (M.wID = 'WAVE') and (M.fID = 'fmt ') Then
    Begin
      TextColor(12);
      Write('Wave Audio Format (.WAV), ');
      Case M.nChanel of
        1: Write('Mono');
        2: Write('Stereo');
        4: Write('Dual Channel');
        8: Write('8 Channel');
      End;
      Write(', ',(M.nSamplePerSec div 1000),' Khz, ',M.BitPSec,' bit');
      TextColor(12);
      Write('');
    End;
  If (M.rID = 'RIFF') and (M.wID = 'AVI ') Then
    Begin
      TextColor(12);
      Write('Video for Windows (.AVI), ');
      TextColor(12);
      Write('');
    End;
end;

Procedure Scan_BMP;
Type  BMPhead = record
         bfSize          : longword;
         bfReserved1     : word;
         bfReserved2     : word;
         bfOffBits       : longword;
         biSize          : longword;
         biWidth         : longword;
         biHeight        : longword;
         biPlanes        : word;
         biBitCount      : word;
         biCompression   : longword;
         biSizeImage     : longword;
         biXPelsPerMeter : longword;
         biYPelsPerMeter : longword;
         biClrUsed       : longword;
         biClrImportant  : longword;
      end;

Var M : BMPhead;
    I : LongInt;
    bfType : word;
Begin
  {$I-}
  If Filesize(F)<SizeOf(M)+2 Then Exit;
  TextColor(9);
  I:=Filesize(F);
  Seek(F, 0);
  BlockRead(F, bfType, 2);
  Seek(F, 2);
  BlockRead(F, M, SizeOf(M){54});
  If (bfType=19778) and (M.bfSize=I) Then
    Begin
      TextColor(9);
      Write('Windows Bitmap (.BMP), ');
      TextColor(9);
      Write('Size: ', M.biWidth, 'x', M.biHeight);
      Case M.biBitCount Of
        8:  Write(', 256 color');
        15: Write(', 32k color');
        16: Write(', 64k color');
        24: Write(', 16M color');
        32: Write(', 32 bit');
      End;
      TextColor(9); Write('');
    End;
End;

Procedure Colorize(S: String);
Begin
  Textcolor(11);
  S:=LowerCase(S);
  If (Pos('.txt', S)<>0) or (Pos('.doc', S)<>0) or (Pos('.dok', S)<>0) or (Pos('.nfo', S)<>0) or
     (Pos('.ini', S)<>0) or (Pos('.inf', S)<>0) or (Pos('.reg', S)<>0) or (Pos('.diz', S)<>0) or
     (Pos('.ion', S)<>0) or (Pos('.bbs', S)<>0) or (Pos('.cfg', S)<>0) or (Pos('.htm', S)<>0) or
     (Pos('.1st', S)<>0) Then Textcolor(7);
  If (Pos('.rar', S)<>0) or (Pos('.zip', S)<>0) or (Pos('.arj', S)<>0) or (Pos('.cab', S)<>0) or
     (Pos('.pak', S)<>0) or (Pos('.pk' , S)<>0) or (Pos('.arc', S)<>0) or (Pos('.ain', S)<>0) or
     (Pos('.ace', S)<>0) or (Pos('.r0' , S)<>0) or (Pos('.r1' , S)<>0) or (Pos('.r2' , S)<>0) or
     (Pos('.a0' , S)<>0) or (Pos('.a1' , S)<>0) or (Pos('.a2' , S)<>0) or (Pos('.gz' , S)<>0) or
     (Pos('.tar', S)<>0) or (Pos('.lzh', S)<>0) or (Pos('.zoo', S)<>0) or (Pos('.jar', S)<>0) or
     (Pos('.uc2', S)<>0) or (Pos('.ha' , S)<>0) Then Textcolor(13);
  If (Pos('.mp3', S)<>0) or (Pos('.mpg', S)<>0) or (Pos('.mpeg',S)<>0) or (Pos('.xm' , S)<>0) or
     (Pos('.s3m', S)<>0) or (Pos('.it' , S)<>0) or (Pos('.avi', S)<>0) or (Pos('.bik', S)<>0) or
     (Pos('.wav', S)<>0) or (Pos('.snd', S)<>0) or (Pos('.iff', S)<>0) or (Pos('.xt' , S)<>0) or
     (Pos('.asf', S)<>0) or (Pos('.wma', S)<>0) or (Pos('.mp2', S)<>0) or (Pos('.669', S)<>0) or
     (Pos('.mod', S)<>0) Then TextColor(12);
  If (Pos('.exe', S)<>0) or (Pos('.com', S)<>0) or (Pos('.bat', S)<>0) or (Pos('.cmd', S)<>0) or
     (Pos('.lnk', S)<>0) or (Pos('.pif', S)<>0) Then TextColor(14);
  If (Pos('.bmp', S)<>0) or (Pos('.pcx', S)<>0) or (Pos('.gif', S)<>0) or (Pos('.tga', S)<>0) or
     (Pos('.rle', S)<>0) or (Pos('.ico', S)<>0) or (Pos('.ani', S)<>0) or (Pos('.cur', S)<>0) or
     (Pos('.jpg', S)<>0) or (Pos('.jpeg',S)<>0) or (Pos('.jfif',S)<>0) or (Pos('.tif', S)<>0) or
     (Pos('.tiff',S)<>0) Then TextColor(9);

End;

Procedure Ext_Scan;
Begin
  If ExtInfo Then
    Begin
      Colorize(SR.Name); Write('');
      If WhereX>21 Then WriteLn;
      GotoXY(21, WhereY);
      Write('- File: ', SR.Name);

      If WhereX>21 Then WriteLn;
      GotoXY(21, WhereY);
      Write('- Size: ', SR.Size, ' byte(s) ~ ', (SR.Size div 1024), ' kbyte(s) ~ ', (SR.Size div 1024 div 1024), ' Mbyte(s)');

      If WhereX>21 Then WriteLn;
      GotoXY(21, WhereY);
      Write('- Attr: ');
      If SR.Attr and faArchive > 0 Then Write('a') Else Write('-');
      If SR.Attr and faReadOnly > 0 Then Write('r') Else Write('-');
      If SR.Attr and faHidden > 0 Then Write('h') Else Write('-');
      If Sr.Attr and faSysFile > 0 Then Write('s') Else Write('-');

      Colorize(SR.Name); Write('');
    End;
End;

(*
      If WhereX>21 Then WriteLn;
      GotoXY(21, WhereY);
      Write('- : ', SR.);

  If (Pos('.', S)<>0)  or
     (Pos('.', S)<>0)  or
     (Pos('.', S)<>0)  Then TextColor();
*)
Procedure Scan;
Begin
  Scan_BMP;
  Scan_CAB;
  Scan_CHR;
  Scan_WAV;
  Scan_DOC;
  Scan_DRS;
  Scan_FAR;
  Scan_GAM;
  Scan_IFF;
  Scan_PUD;
  Scan_REG;
  Scan_RTF;
  Scan_XA ;
  Scan_ACE;
  Ext_Scan;
End;

Procedure DoScan(PStr: String);
Begin
  FindFirst(PStr, faAnyFile and not faDirectory, SR);
    Repeat
      AssignFile(F, SR.Name);
      Reset(F);
      Colorize(SR.Name);
      S:=CFn(SR.Name);
      Write(S+'  ');
      If Length(SR.Name)<=17 Then GotoXY(20, WhereY);
      Scan;
      CloseFile(F);
      WriteLn;
    Until FindNext(SR)<>0;
End;

begin
  {$I-}
  Extinfo:=False;
  If ParamStr(1)='-ex' Then
    Begin
      Extinfo := True;
      If ParamStr(2)='' Then DoScan('*.*')
      Else DoScan(ParamStr(2));
      For I := 3 To 10 Do
        If ParamStr(I)<>'' Then DoScan(ParamStr(I));
    End
  Else If ParamStr(1)<>'' Then DoScan(ParamStr(1)) Else DoScan('*.*');
end.
