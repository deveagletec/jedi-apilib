{
@abstract(Contains ansi- and unicode string types that are used by the units of JWSCL)
@author(Christian Wimmer)
@created(03/23/2007)
@lastmod(09/10/2007)

Project JEDI Windows Security Code Library (JWSCL)

The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
you may not use this file except in compliance with the License. You may obtain a copy of the
License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
ANY KIND, either express or implied. See the License for the specific language governing rights
and limitations under the License.

Alternatively, the contents of this file may be used under the terms of the  
GNU Lesser General Public License (the  "LGPL License"), in which case the   
provisions of the LGPL License are applicable instead of those above.        
If you wish to allow use of your version of this file only under the terms   
of the LGPL License and not to allow others to use your version of this file 
under the MPL, indicate your decision by deleting  the provisions above and  
replace  them with the notice and other provisions required by the LGPL      
License.  If you do not delete the provisions above, a recipient may use
your version of this file under either the MPL or the LGPL License.          
                                                                             
For more information about the LGPL: http://www.gnu.org/copyleft/lesser.html 

The Original Code is JwsclAnsiUniCode.pas.

The Initial Developer of the Original Code is Christian Wimmer.
Portions created by Christian Wimmer are Copyright (C) Christian Wimmer. All rights reserved.

Description:
This unit contains ansi- and unicode string types that are used by the units of JWSCL.
You can define UNICODE to use unicode strings. Otherwise ansicode will be used.

}
{$IFNDEF SL_OMIT_SECTIONS}
unit JwsclStrings;
{$INCLUDE Jwscl.inc}
// Last modified: $Date: 2007-09-10 10:00:00 +0100 $

interface

uses JwaWindows;

{$ENDIF SL_OMIT_SECTIONS}

{$IFNDEF SL_IMPLEMENTATION_SECTION}
type
  {$IFDEF UNICODE}
  //@Name defines an unicode string type if compiler directive UNICODE is defined; otherwise ansicode
  TJwString = WideString;
  //@Name defines an unicode pointer to wide char type if compiler directive UNICODE is defined; otherwise ansicode
  TJwPChar  = PWideChar;
  //@Name defines an unicode wide char type if compiler directive UNICODE is defined; otherwise ansicode
  TJwChar   = WideChar;
  {$ELSE}
  //@Name defines an ansicode string type if compiler directive UNICODE is not defined; otherwise unicode
  TJwString = AnsiString;
  //@Name defines an ansicode pointer to ansi char type if compiler directive UNICODE is not defined; otherwise unicode
  TJwPChar  = PChar;
  //@Name defines an ansicode char type if compiler directive UNICODE is not defined; otherwise unicode
  TJwChar   = Char;
  {$ENDIF UNICODE}

  TJwTJwStringArray = array of TJwString;


const
  {@Name defines the size of an char in an ansi- or unicode compilation. }
  TJwCharSize = SizeOf(TJwChar);

function JwCompareString(const S1, S2: TJwString;
  const IgnoreCase: boolean = False): integer;

function JwStringArrayIndexOf(const StrArry: TJwTJwStringArray; const S: TJwString): integer;

{@Name formats a ansi- or unicode string and calls JwReplaceBreaks.}
function JwFormatString(const Str : TJwString; const Args: array of const) : TJwString;

{@Name behaves like JwFormatString but without calling JwReplaceBreaks}
function JwFormatStringEx(const Str : TJwString; const Args: array of const) : TJwString;


{@Name replaces "\r" and "\n" with break line chars.}
procedure JwReplaceBreaks(var Str : TJwString);


{@Name loads a string from a resource using a language id.
@param Index defines the string index to be loaded.
@param(PrimaryLanguageId defines the primary language id.
use PRIMARYLANGID(GetUserDefaultUILanguage), SUBLANGID(GetUserDefaultUILanguage)
to get user language.)
@param(SubLanguageId defines the sub language id.)
@param Instance defines the location of the resource. Can be null to use current module.
@return Returns the resource string.
@raises EJwsclOSError if the resource could not be located.
}
function LoadLocalizedString(const Index : Cardinal;
  const PrimaryLanguageId, SubLanguageId : Word;
  Instance : HInst = 0) : TJwString;

{
type TResourceTStringArray = Array of TJwString;
     TResourceIndexArray = Array of Cardinal;

function LoadLocalizedStringArray(const Index : TResourceIndexArray; LanguageId : Cardinal;
 Instance : HInst) : TResourceTStringArray;}


function JwCreateUnicodeString(const NewString: WideString): PUnicodeString;
function JwCreateTUnicodeString(const NewString: WideString): TUnicodeString;
function JwUnicodeStringToJwString(const AUnicodeString: TUnicodeString):
  TJwString;

  
function JwCreateLSAString(const aString: string): LSA_STRING;
procedure JwFreeLSAString(var aString: LSA_STRING);

function PWideCharToJwString(const APWideChar: PWideChar): TJwString;


{$ENDIF SL_IMPLEMENTATION_SECTION}

{$IFNDEF SL_OMIT_SECTIONS}
implementation

uses
  {$IFDEF JCL}
  JclWideFormat,
  {$ENDIF JCL}
  SysUtils;

{$ENDIF SL_OMIT_SECTIONS}


{$IFNDEF SL_INTERFACE_SECTION}

function JwCreateUnicodeString(const NewString: WideString): PUnicodeString;
begin
  Result := nil; //removes compiler warning "undefined result"
  RtlInitUnicodeString(Result, PWideChar(NewString));
end;

function JwCreateTUnicodeString(const NewString: WideString): TUnicodeString;
begin
  RtlInitUnicodeString(@Result, PWideChar(NewString));
end;

function JwUnicodeStringToJwString(const AUnicodeString: UNICODE_STRING):
  TJwString;
var Len: DWORD;
begin
  // Determine UnicodeStringLength (-1 because string has no #0 terminator)
  Len := RtlUnicodeStringToAnsiSize(@AUnicodeString)-1;
  // Convert to TJwString
  Result := WideCharLenToString(AUniCodeString.Buffer, Len);
end;

procedure JwReplaceBreaks(var Str : TJwString);
var
  i: Integer;

begin
  for i := 2 to Length(Str) do
  begin
    if (Str[i-1] = '\') and (Str[i] = '\') then
    begin
      Str[i-1] := #1;
      Str[i] := #2;
    end
    else
    if (Str[i-1] = '\') and (Str[i] = 'r') {and
       ((i-2 > 0) and (Str[i-2] <> '\') or (i-2 <= 0))} then
    begin
      Str[i-1] := #1;
      Str[i] := #10;
    end
    else
    if (Str[i-1] = '\') and (Str[i] = 'n') {and
       ((i-2 > 0) and (Str[i-2] <> '\') or (i-2 <= 0))} then
    begin
      Str[i-1] := #1;
      Str[i] := #13;
    end;
  end;
  for i := Length(Str) downto 1 do
  begin
    if Str[i] = #1 then
      System.Delete(Str,i,1)
    else
    if Str[i] = #2 then
      Str[i] := '\';
  end;
end;

function JwFormatString(const Str : TJwString; const Args: array of const) : TJwString;
begin
  {$IFDEF UNICODE}
  {$IFDEF JCL}
  result := JclWideFormat.WideFormat(Str, Args);
  {$ELSE}
  result := Sysutils.WideFormat(Str, Args);
  {$ENDIF JCL}
  {$ELSE}
  result := Sysutils.Format(Str, Args);
  {$ENDIF UNICODE}
  JwReplaceBreaks(result);
end;

function JwFormatStringEx(const Str : TJwString; const Args: array of const) : TJwString;
begin
  {$IFDEF UNICODE}
  {$IFDEF JCL}
  result := JclWideFormat.WideFormat(Str, Args);
  {$ELSE}
  result := Sysutils.WideFormat(Str, Args);
  {$ENDIF JCL}
  {$ELSE}
  result := Sysutils.Format(Str, Args);
  {$ENDIF UNICODE}
end;

function JwStringArrayIndexOf(const StrArry: TJwTJwStringArray; const S: TJwString): integer;
var
  i: integer;
begin
  Result := 0;
  for i := low(StrArry) to high(StrArry) do
  begin
    if JwCompareString(StrArry[i], S, True) = 0 then
    begin
      Result := i;
      exit;
    end;
  end;
end;

function JwCompareString(const S1, S2: TJwString;
  const IgnoreCase: boolean = False): integer;
var
  flags: Cardinal;
begin
  flags := 0;
  if IgnoreCase then
    flags := NORM_IGNORECASE;
{$IFDEF UNICODE}
    result := CompareStringW
{$ELSE}
  Result := CompareStringA
{$ENDIF}
    (LOCALE_USER_DEFAULT, flags, TJwPChar(S1), Length(S1),
    TJwPChar(S2), Length(S2));
  if Result <> 0 then
    Dec(Result, 2);
end;

function JwCreateLSAString(const aString: string): LSA_STRING;
var
  pStr: PChar;
begin
  Result.Length := Length(aString);
  Result.MaximumLength := Result.Length;

  GetMem(pStr, Length(aString) + 2);
  FillChar(pStr^, Length(aString) + 2, 0);
  StrLCopy(pStr, PChar(aString), Length(aString));

  Result.Buffer := pStr;
end;

procedure JwFreeLSAString(var aString: LSA_STRING);
begin
  if aString.Buffer <> nil then
    FreeMem(aString.Buffer);

  FillChar(aString, sizeof(aString), 0);
end;

function PWideCharToJwString(const APWideChar: PWideChar): TJwString;
begin
  Result := APWideChar;
end;

function LoadLocalizedString(const Index : Cardinal; const PrimaryLanguageId, SubLanguageId : Word;
 Instance : HInst = 0) : TJwString;
var pS : PWideChar;
    Rsrc : HRSRC;
    res : HGLOBAL;
    S : TJwString;
    Len, i : Cardinal;
begin
  result := '';
  pS := nil;
  S := '#'+IntToStr((Index div 16)+1);
  if Instance = 0 then
    Instance := GetModuleHandle(nil);


  Rsrc := {$IFDEF UNICODE}FindResourceExW{$ELSE}FindResourceExA{$ENDIF}
    (Instance, TJwPChar(RT_STRING), TJwPChar(S), MAKELANGID(PrimaryLanguageId,SubLanguageId));
  if (Rsrc <> 0) then
  begin
    res := LoadResource(Instance, Rsrc);
    if (res <> 0) then
    begin
      pS := LockResource(res);
      if (pS <> nil) then
      begin
        i := 0;
        while i < (Index and 15) do
        begin
          Len := Integer(pS^); //get string length
          Inc(pS);  //skip string length
          Inc(pS, Len); //skip string
          Inc(i);
        end;
        UnlockResource(Cardinal(pS));
      end;
      FreeResource(res);
    end;
  end
  else
{$IFDEF DELPHI6_UP}
    RaiseLastOSError;
{$ELSE}
{$IFDEF FPC}
    RaiseLastOSError;
{$ELSE}
  RaiseLastWin32Error;
{$ENDIF FPC}
{$ENDIF DELPHI6_UP}

  if (pS <> nil) then
  begin
    Len := Integer(pS^); //get string length
    Inc(pS);   //skip string length
    result := TJwString(pS);
    SetLength(result, Len);
  end;
end;

           (*
function LoadLocalizedStringArray(const Index : TResourceIndexArray; LanguageId : Cardinal;
 Instance : HInst) : TResourceTStringArray;
var pS : PWideChar;
    Rsrc : HRSRC;
    res : HGLOBAL;
    S : TJwString;
    SmallestIndex,
    BiggestIndex,
    Len, i, i2 : Cardinal;
begin
  pS := nil;
  Len := 0;

  SmallestIndex := Index[0];
  BiggestIndex := Index[high(Index)];
  S := '#'+IntToStr((SmallestIndex div 16)+1);
  if Instance = 0 then
    Instance := GetModuleHandle(nil);

  SetLength(result, Length(Index));

  Rsrc := FindResourceEx(Instance, RT_STRING, TJwPChar(S), LanguageId);
  if (Rsrc <> 0) then
  begin
    res := LoadResource(Instance, Rsrc);
    if (res <> 0) then
    begin
      pS := LockResource(res);
      if (pS <> nil) then
      begin
        i := 1;
        i2 := 0;
        
        Inc(pS); //get the first string entry
        Len := Integer(pS^); //get string length
        Inc(pS); //skip string length

        result[i2] := TJwString(pS);
        SetLength(result[i2], Len);
        Inc(pS, Len); //skip string
        Inc(i2);
        Inc(i);


        while i <= (BiggestIndex and 15) do
        begin
          Len := Integer(pS^); //get string length
          Inc(pS); //skip string length

          if (i = Index[i2] and 15) then
          begin
            result[i2] := TJwString(pS);
            SetLength(result[i2], Len);
            Inc(i2);
          end;
          
          Inc(pS, Len); //skip string
          Inc(i);
        end;
        UnlockResource(Cardinal(pS));
      end;
      FreeResource(res);
    end;
  end
  else
    RaiseLastOSError; 
end;
        *)
        

{$ENDIF SL_INTERFACE_SECTION}

{$IFNDEF SL_OMIT_SECTIONS}
end.
{$ENDIF SL_OMIT_SECTIONS}
