{*******************************************************}
{                     PHP4Delphi                        }
{               ZEND - Delphi interface                 }
{                                                       }
{ Author:                                               }
{ Serhiy Perevoznyk                                     }
{ serge_perevoznyk@hotmail.com                          }
{ http://users.telenet.be/ws36637                       }
{*******************************************************}
{$I PHP.INC}

{ $Id: ZENDAPI.pas,v 7.4 10/2009 delphi32 Exp $ }

unit zendAPI;

{$ifdef fpc}
   {$mode delphi}
{$endif}

interface

uses
  {$IFNDEF FPC} Windows{$ELSE} LCLType,LCLIntf,dynlibs,libc{$ENDIF}, SysUtils,
  {$IFDEF PHP7} hzend_types, {$ElSE} ZendTypes, {$ENDIF} Variants,
  PHPTypes;
type
TArrayVariant = array of variant;
 TWSDate = array of string;
  PWSDate = ^TWSDate;
   TASDate = array of AnsiString;
  PASDate = ^TWSDate;
const
PHPWin =
{$IFDEF PHP_DEBUG}
{$IFDEF PHP7}
  'php7ts_debug.dll'
{$ELSE}
 {$IFDEF PHP5}
  'php5ts_debug.dll'
  {$ELSE}
  'php4ts_debug.dll'
  {$ENDIF}
 {$ENDIF}
{$ELSE}
 {$IFDEF PHP5}
    {$IFDEF PHP7}
    {$IFDEF LINUX}
         'php7ts.so'
   {$ENDIF}
   {$IFDEF MSWINDOWS}
    'php7ts.dll'
     {$ENDIF}
    {$ELSE}
    {$IFDEF LINUX}
         'php5ts.so'
   {$ENDIF}
   {$IFDEF MSWINDOWS}
    'php5ts.dll'
     {$ENDIF}
    {$ENDIF}
  {$ELSE}
  'php4ts.dll'
  {$ENDIF}
{$ENDIF};

type
  EPHP4DelphiException = class(Exception)
   constructor Create(const Msg: zend_ustr);
  end;

  align_test = record
  case Integer of
      1: (ptr: Pointer; );
      2: (dbl: Double; );
      3: (lng: Longint; );
  end;
const
  PLATFORM_ALIGNMENT = (SizeOf(align_test));
{$IFNDEF PHP_UNICE}
function AnsiFormat(const Format: AnsiString; const Args: array of const): AnsiString;
{$ENDIF}
function  LoadZEND(const DllFilename: zend_ustr = PHPWin) : boolean;

procedure UnloadZEND;
function  ZENDLoaded: boolean;

{Memory management functions}
var
  {$IFNDEF PHP7}
  zend_strndup   : function(s: zend_pchar; length: Integer): zend_pchar; cdecl;
  {$ELSE}
  zend_strndup   : function(s:zend_pchar; length:size_t):zend_pchar; cdecl;
  {$ENDIF}
  _emalloc       : function(size: size_t; __zend_filename: zend_pchar; __zend_lineno: uint; __zend_orig_filename: zend_pchar; __zend_orig_line_no: uint): pointer; cdecl;
  _efree         : procedure(ptr: pointer; __zend_filename: zend_pchar; __zend_lineno: uint; __zend_orig_filename: zend_pchar; __zend_orig_line_no: uint); cdecl;
  _ecalloc       : function(nmemb: size_t; size: size_t; __zend_filename: zend_pchar; __zend_lineno: uint; __zend_orig_filename: zend_pchar; __zend_orig_line_no: uint): pointer; cdecl;
  _erealloc      : function(ptr: pointer; size: size_t; allow_failure: integer; __zend_filename: zend_pchar; __zend_lineno: uint; __zend_orig_filename: zend_pchar; __zend_orig_line_no: uint): pointer; cdecl;
  _estrdup       : function(const s: zend_pchar; __zend_filename: zend_pchar; __zend_lineno: uint; __zend_orig_filename: zend_pchar; __zend_orig_line_no: uint): pointer; cdecl;
  _estrndup      : function(s: zend_pchar; Len: Cardinal; __zend_filename: zend_pchar; __zend_lineno: uint; __zend_orig_filename: zend_pchar; __zend_orig_line_no: uint): zend_pchar; cdecl;
  _estrndupu     : function(s: PUTF8Char; Len: Cardinal; __zend_filename: PUTF8Char;
  __zend_lineno: uint; __zend_orig_filename: PUTF8Char;
  __zend_orig_line_no: uint): PUTF8Char; cdecl;
function emalloc(size: size_t): pointer;
procedure efree(ptr: pointer);
function ecalloc(nmemb: size_t; size: size_t): pointer;
function erealloc(ptr: pointer; size: size_t; allow_failure: integer): pointer;
function estrdup(const s: zend_pchar): zend_pchar;
function estrndup(s: zend_pchar; len: Cardinal): zend_pchar;
function STR_EMPTY_ALLOC : zend_pchar;

var
  zend_set_memory_limit                           : function(memory_limit: uint): integer; cdecl;
  start_memory_manager                            : procedure(TSRMLS_D: pointer); cdecl;
  shutdown_memory_manager                         : procedure(silent: integer; clean_cache: integer; TSRMLS_DC: pointer); cdecl;


  { startup/shutdown }

var

  zend_register_resource       : function (rsrc_result : pzval;  rsrc_pointer : pointer;  rsrc_type : integer) : integer; cdecl;
  zend_fetch_resource          : function (passed_id  :{$IFNDEF PHP700} ppzval {$ELSE} pzval{$ENDIF}; TSRMLS_DC : pointer; default_id : integer;  resource_type_name : zend_pchar;  found_resource_type : pointer; num_resource_types: integer; resource_type: integer) : pointer; cdecl;
  zend_list_insert             : function (ptr : pointer; _type: integer) : integer; cdecl;
  {$IFNDEF PHP7}
  _zend_list_addref            : function (id  : integer; TSRMLS_DC : pointer) : integer; cdecl;
  _zend_list_delete            : function (id : integer; TSRMLS_DC : pointer) : integer; cdecl;
  _zend_list_find              : function (id : integer; _type : pointer; TSRMLS_DC : pointer) : pointer; cdecl;
  {$ENDIF}
  zend_rsrc_list_get_rsrc_type : function (resource: integer; TSRMLS_DC : pointer) : zend_pchar; cdecl;
  zend_fetch_list_dtor_id      : function (type_name : zend_pchar) : integer; cdecl;
  zend_register_list_destructors_ex : function (ld : pointer; pld : pointer; type_name : zend_pchar; module_number : integer) : integer; cdecl;



{disable functions}

var
  zend_disable_function : function(function_name : zend_pchar; function_name_length : uint; TSRMLS_DC : pointer) : integer; cdecl;
  zend_disable_class   : function(class_name : zend_pchar; class_name_length : uint; TSRMLS_DC : pointer) : integer; cdecl;


{$IFDEF PHP4}
  zend_hash_add_or_update  : function(ht: PHashTable; arKey: zend_pchar;
    nKeyLength: uint; pData: Pointer; nDataSize: uint; pDest: Pointer;
    flag: Integer): Integer; cdecl;
{$ELSE}
{$IFNDEF PHP7}
var
 _zend_hash_add_or_update : function (ht : {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; arKey : zend_pchar;
    nKeyLength : uint; pData : pointer; nDataSize : uint; pDes : pointer;
    flag : integer; __zend_filename: zend_pchar; __zend_lineno: uint) : integer; cdecl;
{$ENDIF}
 function zend_hash_add_or_update(ht : {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; arKey : zend_pchar;
    nKeyLength : uint; pData : {$IFDEF PHP7}pzval{$ELSE}pointer{$ENDIF}; nDataSize : uint; pDes : pointer;
    flag : integer) : integer; cdecl;

{$ENDIF}

function zend_hash_add(ht : {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; arKey : zend_pchar; nKeyLength : uint; pData : pointer; nDataSize : uint; pDest : pointer) : integer; cdecl;

var
 {$IFDEF PHP4}
  zend_hash_init                                  : function(ht: PHashTable; nSize: uint;
    pHashFunction: pointer; pDestructor: pointer;
    persistent: Integer): Integer; cdecl;

  zend_hash_init_ex                               : function(ht: PHashTable; nSize: uint;
    pHashFunction: pointer; pDestructor: pointer;
    persistent: Integer; bApplyProtection: boolean): Integer; cdecl;


  zend_hash_quick_add_or_update                   : function(ht: PHashTable; arKey: zend_pchar;
    nKeyLength: uint; h: ulong; pData: Pointer; nDataSize: uint;
    pDest: Pointer; flag: Integer): Integer; cdecl;

  zend_hash_index_update_or_next_insert           : function(ht: PHashTable; h: ulong;
    pData: Pointer; nDataSize: uint; pDest: Pointer; flag: Integer): Integer; cdecl;

  zend_hash_merge                                 : procedure(target: PHashTable; source: PHashTable;
    pCopyConstructor: pointer; tmp: Pointer; size: uint; overwrite: Integer); cdecl;

 {$ELSE}

 _zend_hash_init : function (ht : {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; nSize : uint;
   pHashFunction : pointer; pDestructor : pointer; persistent: zend_bool;
   __zend_filename: zend_pchar; __zend_lineno: uint) : integer; cdecl;
 _zend_hash_init_ex : function (ht : {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF};  nSize : uint;
   pHashFunction : pointer; pDestructor : pointer;  persistent : zend_bool;
   bApplyProtection : zend_bool; __zend_filename: zend_pchar; __zend_lineno: uint): integer; cdecl;

 function zend_hash_init (ht : {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; nSize : uint; pHashFunction : pointer;
   pDestructor : pointer; persistent: zend_bool) : integer; cdecl;
 function zend_hash_init_ex (ht : {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF};  nSize : uint; pHashFunction : pointer;
 pDestructor : pointer;  persistent : zend_bool;  bApplyProtection : zend_bool): integer; cdecl;


{$ENDIF}
 {$IFDEF PHP7}
 function zend_hash_num_elements(ht: Pzend_array): integer;
 function  add_char_to_string  (_result: Pzval; op1: Pzval; op2: Pzval): Integer;
 function  add_string_to_string(_result: Pzval; op1: Pzval; op2: Pzval): Integer;
 {$ENDIF}
var
  zend_hash_destroy                               : procedure(ht: PHashTable); cdecl;
  zend_hash_clean                                 : procedure(ht: PHashTable); cdecl;

  { additions/updates/changes }




  zend_hash_add_empty_element                     : function(ht: PHashTable; arKey: zend_pchar;
    nKeyLength: uint): Integer; cdecl;




var
  zend_hash_graceful_destroy                      : procedure(ht: PHashTable); cdecl;
  {$IFNDEF PHP7}
  zend_hash_graceful_reverse_destroy              : zend_hash_graceful_reverse_destroy_t;
  {$ENDIF}
  zend_hash_apply                                 : procedure(ht: PHashTable; apply_func: pointer; TSRMLS_DC: Pointer); cdecl;

  zend_hash_apply_with_argument                   : procedure(ht: PHashTable;
    apply_func: pointer; _noname1: Pointer; TSRMLS_DC: Pointer); cdecl;

  { This function should be used with special care (in other words,
   * it should usually not be used).  When used with the ZEND_HASH_APPLY_STOP
   * return value, it assumes things about the order of the elements in the hash.
   * Also, it does not provide the same kind of reentrancy protection that
   * the standard apply functions do.
   }

  zend_hash_reverse_apply                         : procedure(ht: {$IFDEF PHP7} Pzend_array {$ELSE} PHashTable{$ENDIF};
    apply_func: pointer; TSRMLS_DC: Pointer); cdecl;

  { Deletes }

  {$IFDEF PHP7}
  zend_hash_del_key_or_index                      : function(ht: Pzend_array; key:Pzend_string):longint; cdecl;
  {$ELSE}
  zend_hash_del_key_or_index                      : function(ht:  PHashTable; arKey: zend_pchar;
    nKeyLength: uint; h: ulong; flag: Integer): Integer; cdecl;
  {$ENDIF}
  zend_get_hash_value                             : function(ht: {$IFDEF PHP7} Pzend_array {$ELSE} PHashTable{$ENDIF}; arKey: zend_pchar;
    nKeyLength: uint): Longint; cdecl;

  { Data retreival }

  zend_hash_find                                  : function(ht: {$IFDEF PHP7} Pzend_array {$ELSE} PHashTable{$ENDIF}; arKey: zend_pchar; nKeyLength: uint;
    pData: Pointer): Integer; cdecl;

  zend_hash_quick_find                            :
   function(ht: {$IFDEF PHP7} Pzend_array {$ELSE} PHashTable{$ENDIF}; arKey: zend_pchar;
    nKeyLength: uint; h: ulong; out pData: ppzval): Integer; cdecl;

  zend_hash_index_find                            : function(ht: {$IFDEF PHP7} Pzend_array {$ELSE} PHashTable{$ENDIF}; h: ulong; pData: Pointer): Integer; cdecl;

  { Misc }

  zend_hash_exists                                : function(ht: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; arKey: zend_pchar; nKeyLength: uint): Integer; cdecl;

  zend_hash_index_exists                          : function(ht: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; h: ulong): Integer; cdecl;
  {$IFNDEF PHP7}
  zend_hash_next_free_element                     : function(ht: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}): Longint; cdecl;
  {$ENDIF}
  { traversing }

  zend_hash_move_forward_ex                       : function(ht: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; pos: HashPosition): Integer; cdecl;

  zend_hash_move_backwards_ex                     : function(ht: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; pos: HashPosition): Integer; cdecl;

  zend_hash_get_current_key_ex                    : function(ht: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF};
    var str_index: zend_pchar; var str_length: uint; var num_index: ulong;
    duplicate: boolean; pos: HashPosition): Integer; cdecl;

  zend_hash_get_current_key_type_ex               : function(ht: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; pos: HashPosition): Integer; cdecl;

  zend_hash_get_current_data_ex                   : function(ht: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; pData: Pointer; pos: HashPosition): Integer; cdecl;

  zend_hash_internal_pointer_reset_ex             : procedure(ht: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; pos: HashPosition); cdecl;

  zend_hash_internal_pointer_end_ex               : procedure(ht: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; pos: HashPosition); cdecl;

  { Copying, merging and sorting }

  zend_hash_copy                                  : procedure(target: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; source: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF};
    pCopyConstructor: pointer; tmp: Pointer; size: uint); cdecl;


  zend_hash_sort                                  :
  {$IFDEF PHP7}
  function(ht:PZend_array; sort_func:sort_func_t; compare_func:compare_func_t; renumber:zend_bool):longint; cdecl;
  {$ELSE}
   function(ht: PHashTable; sort_func: pointer;
    compare_func: pointer; renumber: Integer; TSRMLS_DC: Pointer): Integer; cdecl;
  {$ENDIF}

  zend_hash_compare                               : function(ht1: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; ht2: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF};
    compar: pointer; ordered: boolean; TSRMLS_DC: Pointer): Integer; cdecl;

  zend_hash_minmax                                : function(ht: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; compar: pointer;
    flag: Integer; pData: Pointer; TSRMLS_DC: Pointer): Integer; cdecl;
  {$IFNDEF PHP7}
  zend_hash_num_elements                          : function(ht: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}): Integer; cdecl;
  {$ENDIF}
  zend_hash_rehash                                : function(ht: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}): Integer; cdecl;

  zend_hash_func                                  : function(arKey: zend_pchar; nKeyLength: uint): Longint; cdecl;


function zend_hash_get_current_data(ht: {$IFDEF PHP7} Pzend_array {$ELSE} PHashTable{$ENDIF}; pData: Pointer): Integer; cdecl;
procedure zend_hash_internal_pointer_reset(ht: {$IFDEF PHP7} Pzend_array {$ELSE} PHashTable{$ENDIF}); cdecl;


var
  zend_get_constant                               : function(name: zend_pchar; name_len: uint; var result: zval;
    TSRMLS_DC: Pointer): Integer; cdecl;

  zend_register_long_constant                     : procedure(name: zend_pchar; name_len: uint;
    lval: Longint; flags: Integer; module_number: Integer; TSRMLS_DC: Pointer); cdecl;

  zend_register_double_constant                   : procedure(name: zend_pchar; name_len: uint; dval: Double; flags: Integer; module_number: Integer;
    TSRMLS_DC: Pointer); cdecl;

  zend_register_string_constant                   : procedure(name: zend_pchar; name_len: uint; strval: zend_pchar; flags: Integer; module_number: Integer;
    TSRMLS_DC: Pointer); cdecl;

  zend_register_stringl_constant                  : procedure(name: zend_pchar; name_len: uint;
    strval: zend_pchar; strlen: uint; flags: Integer; module_number: Integer;
    TSRMLS_DC: Pointer); cdecl;

  zend_register_constant                          : function(var c: zend_constant; TSRMLS_DC: Pointer): Integer; cdecl;

  zend_register_auto_global :
  {$IFDEF PHP700}
  function(name:Pzend_string; jit:zend_bool; auto_global_callback:Pointer):longint; cdecl;
  {$ELSE}
    {$IFDEF PHP5}
    function(name: zend_pchar; name_len: uint; jit:boolean; callback: Pointer; TSRMLS_DC: Pointer): Integer; cdecl;
     zend_activate_auto_globals: procedure(TSRMLS_C: Pointer); cdecl;
    {$ELSE}
    function(name: zend_pchar; name_len: uint; callback: Pointer; TSRMLS_DC: Pointer): Integer; cdecl;
    {$ENDIF}
  {$ENDIF}
procedure REGISTER_MAIN_LONG_CONSTANT(name: zend_pchar; lval: longint; flags: integer; TSRMLS_DC: Pointer);
procedure REGISTER_MAIN_DOUBLE_CONSTANT(name: zend_pchar; dval: double; flags: integer; TSRMLS_DC: Pointer);
procedure REGISTER_MAIN_STRING_CONSTANT(name: zend_pchar; str: zend_pchar; flags: integer; TSRMLS_DC: Pointer);
procedure REGISTER_MAIN_STRINGL_CONSTANT(name: zend_pchar; str: zend_pchar; len: uint; flags: integer; TSRMLS_DC: Pointer);


var
  tsrm_startup                                    : function(expected_threads: integer;
    expected_resources: integer; debug_level: integer; debug_filename: zend_pchar): integer; cdecl;

  ts_allocate_id                                  : function(rsrc_id: pts_rsrc_id; size: size_t; ctor: pointer; dtor: pointer): ts_rsrc_id; cdecl;
  // deallocates all occurrences of a given id
  ts_free_id                                      : procedure(id: ts_rsrc_id); cdecl;

  tsrm_shutdown                                   : procedure(); cdecl;
  ts_resource_ex                                  : function(id: integer; p: pointer): pointer; cdecl;
  ts_free_thread                                  : procedure; cdecl;

  zend_error                                      : procedure(ErrType: integer; ErrText: zend_pchar); cdecl;
  zend_error_cb                                   : procedure; cdecl;

  zend_eval_string                                : function(str: zend_pchar; val: pointer; strname: zend_pchar; tsrm: pointer): integer; cdecl;
  zend_make_compiled_string_description           : function(a: zend_pchar; tsrm: pointer): zend_pchar; cdecl;

  {$IFDEF PHP4}
  _zval_copy_ctor                                 : function(val: pzval; __zend_filename: zend_pchar; __zend_lineno: uint): integer; cdecl;
  _zval_dtor                                      : procedure(val: pzval; __zend_filename: zend_pchar; __zend_lineno: uint); cdecl;
  {$ELSE}
  _zval_copy_ctor_func                            : procedure(val: pzval; __zend_filename: zend_pchar; __zend_lineno: uint); cdecl;
  _zval_dtor_func                                 : procedure(val: pzval; __zend_filename: zend_pchar; __zend_lineno: uint); cdecl;
  _zval_ptr_dtor: procedure(val: ppzval;  __zend_filename: zend_pchar); cdecl;
  procedure  _zval_copy_ctor (val: pzval; __zend_filename: zend_pchar; __zend_lineno: uint); cdecl;
  procedure _zval_dtor(val: pzval; __zend_filename: zend_pchar; __zend_lineno: uint); cdecl;
  {$ENDIF}

var
  zend_print_variable                             : function(val: pzval): integer; cdecl;


  zend_get_compiled_filename : function(TSRMLS_DC: Pointer): zend_pchar; cdecl;
  zend_get_compiled_lineno   : function(TSRMLS_DC: Pointer): integer; cdecl;


{$IFDEF PHP4}
function zval_copy_ctor(val : pzval) : integer;
{$ENDIF}

function ts_resource(id : integer) : pointer;
function tsrmls_fetch : pointer;

//procedure zenderror(Error : zend_pchar);

var
  zend_stack_init                                 : function(stack: Pzend_stack): Integer; cdecl;

  zend_stack_push                                 : function(stack: Pzend_stack; element: Pointer; size: Integer): Integer; cdecl;

  zend_stack_top                                  : function(stack: Pzend_stack; element: Pointer): Integer; cdecl;

  zend_stack_del_top                              : function(stack: Pzend_stack): Integer; cdecl;

  zend_stack_int_top                              : function(stack: Pzend_stack): Integer; cdecl;

  zend_stack_is_empty                             : function(stack: Pzend_stack): Integer; cdecl;

  zend_stack_destroy                              : function(stack: Pzend_stack): Integer; cdecl;

  zend_stack_base                                 : function(stack: Pzend_stack): Pointer; cdecl;

  zend_stack_count                                : function(stack: Pzend_stack): Integer; cdecl;

  zend_stack_apply                                : procedure(stack: Pzend_stack; _type: Integer; apply_function: Integer); cdecl;

  zend_stack_apply_with_argument                  : procedure(stack: Pzend_stack; _type: Integer; apply_function: Integer; arg: Pointer); cdecl;


  //zend_operators.h

var
  _convert_to_string                              : procedure(op: pzval; __zend_filename: zend_pchar; __zend_lineno: uint); cdecl;

procedure convert_to_string(op: pzval);

var
  add_function                                    : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  sub_function                                    : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  mul_function                                    : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  div_function                                    : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  mod_function                                    : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  boolean_xor_function                            : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  boolean_not_function                            : function(_result: Pzval; op1: Pzval): Integer; cdecl;

  bitwise_not_function                            : function(_result: Pzval; op1: Pzval): Integer; cdecl;

  bitwise_or_function                             : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  bitwise_and_function                            : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  bitwise_xor_function                            : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  shift_left_function                             : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  shift_right_function                            : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  concat_function                                 : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  is_equal_function                               : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  is_identical_function                           : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  is_not_identical_function                       : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  is_not_equal_function                           : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  is_smaller_function                             : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  is_smaller_or_equal_function                    : function(_result: Pzval; op1: Pzval; var op2: zval; TSRMLS_DC: Pointer): Integer; cdecl;

  increment_function                              : function(op1: Pzval): Integer; cdecl;

  decrement_function                              : function(op2: Pzval): Integer; cdecl;

  convert_scalar_to_number                        : procedure(op: Pzval; TSRMLS_DC: Pointer); cdecl;

  convert_to_long                                 : procedure(op: Pzval); cdecl;

  convert_to_double                               : procedure(op: Pzval); cdecl;

  convert_to_long_base                            : procedure(op: Pzval; base: Integer); cdecl;

  convert_to_null                                 : procedure(op: Pzval); cdecl;

  convert_to_boolean                              : procedure(op: Pzval); cdecl;

  convert_to_array                                : procedure(op: Pzval); cdecl;

  convert_to_object                               : procedure(op: Pzval); cdecl;
  {$IFNDEF PHP7}
  add_char_to_string                              : function(_result: Pzval; op1: Pzval; op2: Pzval): Integer; cdecl;

  add_string_to_string                            : function(_result: Pzval; op1: Pzval; op2: Pzval): Integer; cdecl;
  {$ENDIF}
  zend_string_to_double                           : function(number: zend_pchar; length: zend_uint): Double; cdecl;

  zval_is_true                                    : function(op: Pzval): Integer; cdecl;

  compare_function                                : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  numeric_compare_function                        : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  string_compare_function                         : function(_result: Pzval; op1: Pzval; op2: Pzval; TSRMLS_DC: Pointer): Integer; cdecl;

  zend_str_tolower                                : procedure(str: zend_pchar; length: Integer); cdecl;

  zend_binary_zval_strcmp                         : function(s1: Pzval; s2: Pzval): Integer; cdecl;

  zend_binary_zval_strncmp                        : function(s1: Pzval; s2: Pzval; s3: Pzval): Integer; cdecl;

  zend_binary_zval_strcasecmp                     : function(s1: Pzval; s2: Pzval): Integer; cdecl;

  zend_binary_zval_strncasecmp                    : function(s1: Pzval; s2: Pzval; s3: Pzval): Integer; cdecl;

  zend_binary_strcmp                              : function(s1: zend_pchar; len1: uint; s2: zend_pchar; len2: uint): Integer; cdecl;

  zend_binary_strncmp                             : function(s1: zend_pchar; len1: uint; s2: zend_pchar; len2: uint; length: uint): Integer; cdecl;

  zend_binary_strcasecmp                          : function(s1: zend_pchar; len1: uint; s2: zend_pchar; len2: uint): Integer; cdecl;

  zend_binary_strncasecmp                         : function(s1: zend_pchar; len1: uint; s2: zend_pchar; len2: uint; length: uint): Integer; cdecl;

  zendi_smart_strcmp                              : procedure(_result: zval; s1: Pzval; s2: Pzval); cdecl;

  zend_compare_symbol_tables                      : procedure(_result: Pzval; ht1: PHashTable; ht2: PHashTable; TSRMLS_DC: Pointer); cdecl;

  zend_compare_arrays                             : procedure(_result: zval; a1: Pzval; a2: Pzval; TSRMLS_DC: Pointer); cdecl;

  zend_compare_objects                            : procedure(_result: Pzval; o1: Pzval; o2: Pzval; TSRMLS_DC: Pointer); cdecl;

  zend_atoi                                       : function(str: zend_pchar; str_len: Integer): Integer; cdecl;

  //zend_execute.h
  get_active_function_name                        : function(TSRMLS_D: pointer): zend_pchar; cdecl;

  zend_get_executed_filename                      : function(TSRMLS_D: pointer): zend_pchar; cdecl;

  zend_get_executed_lineno                        : function(TSRMLS_DC: pointer): uint; cdecl;

  zend_set_timeout                                : procedure(seconds: Longint); cdecl;

  zend_unset_timeout                              : procedure(TSRMLS_D: pointer); cdecl;

  zend_timeout                                    : procedure(dummy: Integer); cdecl;


var
  zend_highlight                                  : procedure(syntax_highlighter_ini: Pzend_syntax_highlighter_ini; TSRMLS_DC: Pointer); cdecl;

  zend_strip                                      : procedure(TSRMLS_D: pointer); cdecl;

  highlight_file                                  : function(filename: zend_pchar; syntax_highlighter_ini: Pzend_syntax_highlighter_ini; TSRMLS_DC: Pointer): Integer; cdecl;

  highlight_string                                : function(str: Pzval; syntax_highlighter_ini: Pzend_syntax_highlighter_ini; str_name: zend_pchar; TSRMLS_DC: Pointer): Integer; cdecl;

  zend_html_putc                                  : procedure(c: zend_uchar); cdecl;

  zend_html_puts                                  : procedure(s: zend_pchar; len: uint; TSRMLS_DC: Pointer); cdecl;
  {$IFDEF PHP7}
  zend_parse_parameters_throw                     : function(num_args:longint; type_spec:PAnsiChar):longint; cdecl varargs;
  {$ELSE}
  zend_indent                                     : procedure; cdecl;
  {$ENDIF}
  ZendGetParameters                               :
  {$IFDEF PHP7}
    function(ht:longint; param_count:longint):longint; cdecl varargs;
  {$ELSE}
    function: integer; cdecl;
  {$ENDIF}
  zend_get_params_ex :
  {$IFDEF PHP7}
  function(param_count:longint):longint; cdecl varargs;
  {$ELSE}
  function(param_count : Integer; Args : ppzval): integer; cdecl varargs;
  {$ENDIF}
  {$IFDEF PHP7}
   ZvalGetArgs: function(Count: Integer; Args: ppzval): Integer;cdecl varargs;
	_zend_get_parameters_array_ex:function(param_count:longint; argument_array:Pzval):longint; cdecl;
  {$ELSE}
  _zend_get_parameters_array_ex : function(param_count: integer; argument_array:
  pppzval; TSRMLS_CC: pointer): integer; cdecl;
  {$ENDIF}
function zend_get_parameters_ex(number: integer; var Params: pzval_array): integer;
function zend_get_parameters_my(number: integer; var Params: pzval_array; TSRMLS_DC: Pointer): integer;
{$IFNDEF PHP7}
function zend_get_parameters(ht: integer; param_count: integer; Params: array of
ppzval): integer;
{$ENDIF}


procedure dispose_pzval_array(Params: pzval_array);

var
  zend_ini_refresh_caches                         : procedure(stage: Integer; TSRMLS_DC: Pointer); cdecl;


var
  _zend_bailout                                   : procedure (filename : zend_pchar; lineno : uint); cdecl;

  zend_alter_ini_entry                            : function(name: PAnsiChar; name_length: uint; new_value: PAnsiChar; new_value_length: uint; modify_type: Integer; stage: Integer): Integer; cdecl;
  zend_alter_ini_entry_ex                            : function(name: zend_pchar; name_length: uint; new_value: zend_pchar; new_value_length: uint; modify_type: Integer; stage: Integer; force_change: integer): Integer; cdecl;

  zend_restore_ini_entry                          : function(name: zend_pchar; name_length: uint; stage: Integer): Integer; cdecl;

  zend_ini_long                                   : function(name: zend_pchar; name_length: uint; orig: Integer): Longint; cdecl;

  zend_ini_double                                 : function(name: zend_pchar; name_length: uint; orig: Integer): Double; cdecl;

  zend_ini_string                                 : function(name: zend_pchar; name_length: uint; orig: Integer): zend_pchar; cdecl;

  compile_string                                  : function(source_string: pzval; filename: zend_pchar; TSRMLS_DC: Pointer): pointer; cdecl;

  execute                                         : procedure(op_array: pointer; TSRMLS_DC: Pointer); cdecl;

  zend_wrong_param_count                          : procedure(TSRMLS_D: pointer); cdecl;
  _zend_hash_quick_add_or_update:function(ht: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; arKey: zend_pchar; nKeyLength: uint; h: uint; out pData: pzval; nDataSize: uint; pDest: PPointer; flag: Integer) : Integer; cdecl;
  {$IFDEF PHP4}
  add_property_long_ex                            : function(arg: pzval; key: zend_pchar; key_len: uint; l: longint): integer; cdecl;
  {$ELSE}
  add_property_long_ex                            : function(arg: pzval; key: zend_pchar; key_len: uint; l: longint; TSRMLS_DC : pointer): integer; cdecl;
  {$ENDIF}

  {$IFDEF PHP4}
  add_property_null_ex                            : function(arg: pzval; key: zend_pchar; key_len: uint): integer; cdecl;
  add_property_bool_ex                            : function(arg: pzval; key: zend_pchar; key_len: uint; b: integer): integer; cdecl;
  add_property_resource_ex                        : function(arg: pzval; key: zend_pchar; key_len: uint; r: integer): integer; cdecl;
  add_property_double_ex                          : function(arg: pzval; key: zend_pchar; key_len: uint; d: double): integer; cdecl;
  add_property_string_ex                          : function(arg: pzval; key: zend_pchar; key_len: uint; str: zend_pchar; duplicate: integer): integer; cdecl;
  add_property_stringl_ex                         : function(arg: pzval; key: zend_pchar; key_len: uint; str: zend_pchar; len: uint; duplicate: integer): integer; cdecl;
  add_property_zval_ex                            : function(arg: pzval; key: zend_pchar; key_len: uint; value: pzval): integer; cdecl;
  {$ELSE}
  add_property_null_ex                            : function(arg: pzval; key: zend_pchar; key_len: uint; TSRMLS_DC: Pointer): integer; cdecl;
  add_property_bool_ex                            : function(arg: pzval; key: zend_pchar; key_len: uint; b: integer; TSRMLS_DC: Pointer): integer; cdecl;
  add_property_resource_ex                        : function(arg: pzval; key: zend_pchar; key_len: uint; r: integer; TSRMLS_DC: Pointer): integer; cdecl;
  add_property_double_ex                          : function(arg: pzval; key: zend_pchar; key_len: uint; d: double; TSRMLS_DC: Pointer): integer; cdecl;
  add_property_string_ex                          : function(arg: pzval; key: zend_pchar; key_len: uint; str: zend_pchar; duplicate: integer; TSRMLS_DC: Pointer): integer; cdecl;
  add_property_stringl_ex                         : function(arg: pzval; key: zend_pchar; key_len: uint; str: zend_pchar; len: uint; duplicate: integer; TSRMLS_DC: Pointer): integer; cdecl;
  add_property_zval_ex                            : function(arg: pzval; key: zend_pchar; key_len: uint; value: pzval; TSRMLS_DC: Pointer): integer; cdecl;
  {$ENDIF}

  {$IFDEF P_CUT}
  call_user_function : procedure(func:pzval; argv:pzval; argc:integer);cdecl;
  {$ELSE}
   call_user_function : function(function_table: PHashTable; object_pp: pzval;
                         function_name: pzval; return_ptr: pzval; param_count: zend_uint; params: pzval_array_ex;
                          TSRMLS_DC: Pointer): integer; cdecl;

  call_user_function_ex : function(function_table: PHashTable; object_pp: pzval;
                         function_name: pzval; return_ptr_ptr: {$IFNDEF PHP700} ppzval {$ELSE} pzval{$ENDIF}; param_count: zend_uint;
                         params: pzval_array;
                         no_separation: zend_uint; symbol_table: PHashTable;
                          TSRMLS_DC: Pointer): integer; cdecl;
  {$ENDIF}
                          {
call_user_function_ex(HashTable *function_table,
                      zval **object_pp,
                      zval *function_name,
                      zval **retval_ptr_ptr,
                      zend_uint param_count,
                      zval **params[],
                      int no_separation,
                      HashTable *symbol_table
                      TSRMLS_DC);
}


  add_assoc_long_ex                               : function(arg: pzval; key: zend_pchar; key_len: uint; n: longint): integer; cdecl;
  add_assoc_null_ex                               : function(arg: pzval; key: zend_pchar; key_len: uint): integer; cdecl;
  add_assoc_bool_ex                               : function(arg: pzval; key: zend_pchar; key_len: uint; b: integer): integer; cdecl;
  add_assoc_resource_ex                           : function(arg: pzval; key: zend_pchar; key_len: uint; r: integer): integer; cdecl;
  add_assoc_double_ex                             : function(arg: pzval; key: zend_pchar; key_len: uint; d: double): integer; cdecl;
  add_assoc_string_ex                             : function(arg: pzval; key: zend_pchar; key_len: uint; str: zend_pchar; duplicate: integer): integer; cdecl;
  add_assoc_stringl_ex                            : function(arg: pzval; key: zend_pchar; key_len: uint; str: zend_pchar; len: uint; duplicate: integer): integer; cdecl;
  add_assoc_zval_ex                               : function(arg: pzval; key: zend_pchar; key_len: uint; value: pzval): integer; cdecl;

  add_index_long                                  : function(arg: pzval; idx: uint; n: longint): integer; cdecl;
  add_index_null                                  : function(arg: pzval; idx: uint): integer; cdecl;
  add_index_bool                                  : function(arg: pzval; idx: uint; b: integer): integer; cdecl;
  add_index_resource                              : function(arg: pzval; idx: uint; r: integer): integer; cdecl;
  add_index_double                                : function(arg: pzval; idx: uint; d: double): integer; cdecl;
  add_index_string                                : function(arg: pzval; idx: uint; str: zend_pchar; duplicate: integer): integer; cdecl;
  add_index_stringl                               : function(arg: pzval; idx: uint; str: zend_pchar; len: uint; duplicate: integer): integer; cdecl;
  add_index_zval                                  : function(arg: pzval; index: uint; value: pzval): integer; cdecl;

  add_next_index_long                             : function(arg: pzval; n: longint): integer; cdecl;
  add_next_index_null                             : function(arg: pzval): integer; cdecl;
  add_next_index_bool                             : function(arg: pzval; b: integer): integer; cdecl;
  add_next_index_resource                         : function(arg: pzval; r: integer): integer; cdecl;
  add_next_index_double                           : function(arg: pzval; d: double): integer; cdecl;
  add_next_index_string                           : function(arg: pzval; str: zend_pchar; duplicate: integer): integer; cdecl;
  add_next_index_stringl                          : function(arg: pzval; str: zend_pchar; len: uint; duplicate: integer): integer; cdecl;
  add_next_index_zval                             : function(arg: pzval; value: pzval): integer; cdecl;

  add_get_assoc_string_ex                         : function(arg: pzval; key: zend_pchar; key_len: uint; str: zend_pchar; dest: pointer; duplicate: integer): integer; cdecl;
  add_get_assoc_stringl_ex                        : function(arg: pzval; key: zend_pchar; key_len: uint; str: zend_pchar; len: uint; dest: pointer; duplicate: integer): integer; cdecl;

  add_get_index_long                              : function(arg: pzval; idx: uint; l: longint; dest: pointer): integer; cdecl;
  add_get_index_double                            : function(arg: pzval; idx: uint; d: double; dest: pointer): integer; cdecl;
  add_get_index_string                            : function(arg: pzval; idx: uint; str: zend_pchar; dest: pointer; duplicate: integer): integer; cdecl;
  add_get_index_stringl                           : function(arg: pzval; idx: uint; str: zend_pchar; len: uint; dest: pointer; duplicate: integer): integer; cdecl;

  _array_init                                     : function(arg: pzval; __zend_filename: zend_pchar; __zend_lineno: uint): integer; cdecl;

  {$IFDEF PHP4}
  _object_init                                    : function(arg: pzval; __zend_filename: zend_pchar; __zend_lineno: uint; TSRMLS_DC: pointer): integer; cdecl;
  {$ELSE}
  _object_init                                    : function(arg: pzval;TSRMLS_DC: pointer): integer; cdecl;
  {$ENDIF}

  {$IFDEF PHP4}
  _object_init_ex                                 : function (arg: pzval; ce: pzend_class_entry; __zend_filename: zend_pchar; __zend_lineno: uint; TSRMLS_DC: pointer) : integer; cdecl;
  {$ELSE}
  _object_init_ex                                 : function (arg: pzval; ce: pzend_class_entry; __zend_lineno : integer; TSRMLS_DC : pointer) : integer; cdecl;
  {$ENDIF}

  _object_and_properties_init                     : function(arg: pzval; ce: pointer; properties: phashtable; __zend_filename: zend_pchar; __zend_lineno: uint; TSRMLS_DC: pointer): integer; cdecl;


  {$IFDEF PHP5}
  zend_destroy_file_handle : procedure(file_handle : PZendFileHandle; TSRMLS_DC : pointer); cdecl;
  {$ENDIF}

var
  zend_write                                      : zend_write_t;

procedure ZEND_PUTS(str: zend_pchar);


var
  zend_register_internal_class     : function(class_entry: pzend_class_entry; TSRMLS_DC: pointer): Pzend_class_entry; cdecl;
  zend_register_internal_class_ex  : function(class_entry: pzend_class_entry; parent_ce: pzend_class_entry; parent_name: zend_pchar; TSRMLS_DC: pointer): Pzend_class_entry; cdecl;
  zend_startup_module              : function(module_entry: Pzend_module_entry):integer; cdecl;
  zend_startup_module_ex           : function(module_entry: Pzend_module_entry; TSRMLS_DC: pointer):integer; cdecl;
  zend_register_module_ex          : function(module_entry: Pzend_module_entry; TSRMLS_DC: pointer): Pzend_module_entry;cdecl;
  zend_register_internal_module    : function(module_entry: Pzend_module_entry; TSRMLS_DC: pointer): Pzend_module_entry;cdecl;
  zend_startup_modules             : function(TSRMLS_DC:pointer):integer;
  zend_collect_module_handlers     : function(TSRMLS_DC:pointer):integer;
  function ZvalInt(z:zval):Integer;
  function ZvalDouble(z:zval):Double;
  function ZvalBool(z:zval):Boolean;

  function ZvalStrS(z:zval) : string;
  function ZvalStr(z:zval)  : zend_ustr;
  function ZvalStrW(z:zval) : WideString;

  procedure ZvalVAL(z:pzval; v:Boolean) overload;
  procedure ZvalVAL(z:pzval; v:Integer; const _type:Integer = IS_LONG) overload;
  procedure ZvalVAL(z:pzval) overload;
  procedure ZvalVAL(z:pzval; v:Double) overload;
  procedure ZvalVAL(z: pzval; s: zend_ustr; len: Integer = 0); overload;
  procedure ZvalString(z:pzval) overload;
  procedure ZvalString(z:pzval; s:zend_pchar; len:Integer = 0) overload;
  procedure ZvalString(z:pzval; s:PWideChar; len:Integer = 0) overload;
  procedure ZvalString(z:pzval; s:string; len:Integer = 0) overload;

function ZvalArrayAdd(z: pzval; Args: array of const): Integer; overload;
function ZvalArrayAdd(z: pzval; idx: Integer; Args: array of const)
  : Integer; overload;
function ZvalArrayAdd(z: pzval; key: zend_ustr; Args: array of const)
  : Integer; overload;

function ZValArrayKeyExists(v: pzval; key: zend_ustr): Boolean; overload;
function ZValArrayKeyExists(v: pzval; key: zend_ustr; out pData: pzval)
  : Boolean; overload;
function ZValArrayKeyExists(v: pzval; idx: Integer): Boolean; overload;
function ZValArrayKeyExists(v: pzval; idx: Integer; out pData: pzval)
  : Boolean; overload;
function ZValArrayKeyDel(v: pzval; key: zend_ustr): Boolean; overload;
function ZValArrayKeyDel(v: pzval; idx: Integer): Boolean; overload;

function ZValArrayKeyFind(v: pzval; key: zend_ustr; out pData: ppzval)
  : Boolean; overload;
function ZValArrayKeyFind(v: pzval; idx: Integer; out pData: ppzval)
  : Boolean; overload;

 function GetArgPZval(Args: TVarRec; const _type: Integer = IS_LONG;
  Make: Boolean = false): pzval;
procedure ZVAL_RESOURCE(value: pzval; l: longint);
procedure ZVAL_BOOL(z: pzval; b: boolean);
procedure ZVAL_NULL(z: pzval);
procedure ZVAL_LONG(z: pzval; l: longint);
procedure ZVAL_DOUBLE(z: pzval; d: double);
procedure ZVAL_EMPTY_STRING(z: pzval);
procedure ZVAL_TRUE(z: pzval);
procedure ZVAL_FALSE(z: pzval);
function add_next_index_variant(arg: pzval; value: variant): integer;
procedure ZVAL_ARRAY(z: pzval; arr:  TWSDate); overload;
procedure ZVAL_ARRAY(z: pzval; arr:  TASDate); overload;
procedure ZVAL_ARRAY(z: pzval; arr:  array of string); overload;
procedure ZVAL_ARRAY(z: pzval; arr:  array of zend_ustr); overload;
procedure ZVAL_ARRAY(z: pzval; arr: array of variant); overload;
procedure ZVAL_ARRAY(z: pzval; arr: System.TArray<System.integer>); overload;
procedure ZVAL_ARRAY(z: pzval; arr: Variant); overload;
procedure ZVAL_ARRAYAC(z: pzval; keynames: Array of AnsiChar; keyvals: Array of AnsiChar);
procedure ZVAL_ARRAYWC(z: pzval; keynames: Array of PWideChar; keyvals: Array of PWideChar);
procedure ZVAL_ARRAYAS(z: pzval; keynames: Array of AnsiString; keyvals: Array of AnsiString); overload;
procedure ZVAL_ARRAYAS(z: pzval; keynames: TASDate; keyvals: TASDate);  overload;
procedure ZVAL_ARRAYWS(z: pzval; keynames: TWSDate; keyvals: TWSDate);  overload;
procedure ZVAL_ARRAYWS(z: pzval; keynames: array of string; keyvals: array of string); overload;
procedure HashToArray(HT: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; var AR: TArrayVariant); overload;
procedure ArrayToHash(AR: Array of Variant; var HT: pzval); overload;
procedure ArrayToHash(Keys,AR: Array of Variant; var HT: pzval); overload;
function ToStrA(V: Variant): zend_ustr;
function ToStr(V: Variant): String;
function toWChar(s: zend_pchar): PWideChar;
{$IFNDEF PHP7}
function ZendToVariant(const Value: pppzval): Variant; overload;
function ZendToVariant(const Value: ppzval): Variant; overload;
{$ENDIF}
procedure ZVAL_STRING(z: pzval; s: zend_pchar; duplicate: boolean);
procedure ZVAL_STRINGU(z: pzval; s: PUtf8Char; duplicate: boolean);
procedure ZVAL_STRINGW(z: pzval; s: PWideChar; duplicate: boolean);

procedure ZVAL_STRINGL(z: pzval; s: zend_pchar; l: integer; duplicate: boolean);
procedure ZVAL_STRINGLW(z: pzval; s: PWideChar; l: integer; duplicate: boolean);

procedure INIT_CLASS_ENTRY(var class_container: Tzend_class_entry; class_name: zend_pchar; functions:
{$IFDEF PHP7}HashTable{$ELSE}pointer{$ENDIF});


var
  get_zend_version           : function(): zend_pchar; cdecl;
  zend_make_printable_zval   : procedure(expr: pzval; expr_copy: pzval; use_copy: pint); cdecl;
  zend_print_zval            : function(expr: pzval; indent: integer): integer; cdecl;
  zend_print_zval_r          : procedure(expr: pzval; indent: integer); cdecl;
  zend_output_debug_string   : procedure(trigger_break: boolean; Msg: zend_pchar); cdecl;

{$IFDEF PHP5}
  zend_copy_constants: procedure(target: PHashTable; source: PHashTable); cdecl;
  zend_objects_new : function (_object : pointer; class_type : pointer; TSRMLS_DC : pointer) : {$IFDEF PHP7}zend_object{$ELSE}_zend_object_value{$ENDIF}; cdecl;
  zend_objects_clone_obj: function(_object: pzval; TSRMLS_DC : pointer): {$IFDEF PHP7}zend_object{$ELSE}_zend_object_value{$ENDIF}; cdecl;
  zend_objects_store_add_ref: procedure (_object : pzval; TSRMLS_DC : pointer); cdecl;
  zend_objects_store_del_ref: procedure (_object : pzval; TSRMLS_DC : pointer); cdecl;

  function_add_ref: procedure (func: {$IFDEF PHP7}Pzend_function{$ELSE}PZendFunction{$ENDIF}); cdecl;

  zend_class_add_ref: procedure(aclass: Ppzend_class_entry); cdecl;


{$ENDIF}


const
  MSCRT = 'msvcrt.dll';

//Microsoft C++ functions

{$IFDEF PHP4}
function  pipe(phandles : pointer; psize : uint; textmode : integer) : integer; cdecl; external MSCRT name '_pipe';
procedure close(AHandle : THandle); cdecl; external MSCRT name '_close';
function  _write(AHandle : integer; ABuffer : pointer; count : uint) : integer; cdecl; external MSCRT name '_write';
function  setjmp(buf : jump_buf) : integer; cdecl; external  MSCRT name '_setjmp3';
{$ENDIF}

{$IFNDEF COMPILER_VC9}
function  strdup(strSource : zend_pchar) : zend_pchar; cdecl; external MSCRT name '_strdup';
{$ELSE}
function  DupStr(strSource : zend_pchar) : zend_pchar; cdecl;
{$ENDIF}
{$IFNDEF PHP7}
function ZEND_FAST_ALLOC: pzval;
function ALLOC_ZVAL: pzval; overload;
procedure ALLOC_ZVAL(out Result: pzval); overload;
{$ENDIF}
procedure INIT_PZVAL(p: pzval);
function MAKE_STD_ZVAL: pzval; overload;
procedure MAKE_STD_ZVAL(out Result: pzval); overload;
{$IFNDEF QUIET_LOAD}
procedure CheckZendErrors;
{$ENDIF}

var
  PHPLib : THandle = 0;

var
 zend_ini_deactivate : function(TSRMLS_D : pointer) : integer; cdecl;

function GetGlobalResource(resource_name: AnsiString) : pointer;

function GetCompilerGlobals : Pzend_compiler_globals;
function GetExecutorGlobals : pzend_executor_globals;
function GetAllocGlobals : pointer;

function zend_register_functions(functions : {$IFDEF PHP7}P_zend_function_entry{$ELSE}pzend_function_entry{$ENDIF};  function_table :  {$IFDEF PHP7} Pzend_array {$ELSE} PHashTable{$ENDIF}; _type: integer;  TSRMLS_DC : pointer) : integer;
function zend_unregister_functions(functions : {$IFDEF PHP7}P_zend_function_entry{$ELSE}pzend_function_entry{$ENDIF}; count : integer; function_table :  {$IFDEF PHP7} Pzend_array {$ELSE} PHashTable{$ENDIF}; TSRMLS_DC : pointer) : integer;

{$IFDEF PHP5}

var
  zend_get_std_object_handlers : function() : {$IFDEF PHP7}P_zend_object_handlers{$ELSE}pzend_object_handlers{$ENDIF};
  zend_objects_get_address : function (_object : pzval; TSRMLS_DC : pointer) : pzend_object; cdecl;
  zend_is_true : function(z : pzval) : integer; cdecl;

function object_init(arg: pzval; ce: pzend_class_entry; TSRMLS_DC : pointer) : integer; cdecl; assembler;

function Z_LVAL(z : Pzval) : longint;
function Z_BVAL(z : Pzval) : boolean;
function Z_DVAL(z : Pzval) : double;
function Z_STRVAL(z : Pzval) : zend_ustr;
function Z_STRUVAL(z : PZval): UTF8String;
function Z_STRWVAL(z : pzval) : String;
function Z_STRLEN(z : Pzval) : longint;
function Z_ARRVAL(z : Pzval ) : PHashTable;
function Z_OBJ_HANDLE(z :Pzval) : {$IFDEF PHP7} P_zend_object_handlers {$ELSE} zend_object_handle{$ENDIF};
function Z_OBJ_HT(z : Pzval) : {$IFDEF PHP7}P_zend_object_handlers{$ELSE}pzend_object_handlers{$ENDIF};
function Z_OBJPROP(z : Pzval) : PHashTable;
function Z_VARREC(z: pzval): TVarRec;

 procedure zend_addref_p(z: pzval); cdecl;
 procedure my_class_add_ref(aclass: Ppzend_class_entry); cdecl;
 procedure copy_zend_constant(C: PZendConstant); cdecl;


{$ENDIF}

implementation


function zend_hash_add(ht : {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; arKey : zend_pchar; nKeyLength : uint; pData : pointer; nDataSize : uint; pDest : pointer) : integer; cdecl;
begin
  result := zend_hash_add_or_update(ht, arKey, nKeyLength, pData, nDataSize, pDest, HASH_ADD);
end;

{$IFDEF PHP7}
function zend_hash_num_elements(ht: Pzend_array): integer;
  begin
    Result := integer(ht.nNumOfElements);
  end;
function  add_char_to_string  (_result: Pzval; op1: Pzval; op2: Pzval): Integer;
Begin
  Result := -1;
  if op1.u1.v._type = IS_STRING then
  begin
    _result.value.str.len := op1.value.str.len + op2.value.str.len;
    _result.value.str.val := zend_pchar(zend_ustr(op1.value.str.val) + zend_ustr(op2.value.str.val));
    Result := SUCCESS;
  end;
End;
function  add_string_to_string(_result: Pzval; op1: Pzval; op2: Pzval): Integer;
begin
  Result := add_char_to_string(_result, op1, op2);
end;
{$ENDIF}

function STR_EMPTY_ALLOC : zend_pchar;
begin
  Result := estrndup('', 0);
end;

function estrndup(s: zend_pchar; len: Cardinal): zend_pchar;
begin
  if assigned(s) then
    Result := _estrndup(s, len, nil, 0, nil, 0)
     else
      Result := nil;
end;
function estrndupu(s: PUtf8Char; len: Cardinal): PUTf8Char;
begin
  if assigned(s) then
    Result := _estrndupu(s, len, nil, 0, nil, 0)
     else
      Result := nil;
end;
function emalloc(size: size_t): pointer;
begin
  Result := _emalloc(size, nil, 0, nil, 0);
end;

procedure efree(ptr: pointer);
begin
  _efree(ptr, nil, 0, nil, 0);
end;

function ecalloc(nmemb: size_t; size: size_t): pointer;
begin
  Result := _ecalloc(nmemb, size, nil, 0, nil, 0);
end;

function erealloc(ptr: pointer; size: size_t; allow_failure: integer): pointer;
begin
  Result := _erealloc(ptr, size, allow_failure, nil, 0, nil, 0);
end;

function estrdup(const s: zend_pchar): zend_pchar;
begin
  if assigned(s) then
  begin
   Result := _estrdup(s, nil, 0, nil, 0);
  end
    else
     Result := nil;
end;


procedure REGISTER_MAIN_LONG_CONSTANT(name: zend_pchar; lval: longint; flags: integer; TSRMLS_DC: Pointer);
begin
  zend_register_long_constant(name, length(name) + 1, lval, flags, 0, TSRMLS_DC);
end;

procedure REGISTER_MAIN_DOUBLE_CONSTANT(name: zend_pchar; dval: double; flags: integer; TSRMLS_DC: Pointer);
begin
  zend_register_double_constant(name, length(name) + 1, dval, flags, 0, TSRMLS_DC);
end;

procedure REGISTER_MAIN_STRING_CONSTANT(name: zend_pchar; str: zend_pchar; flags: integer; TSRMLS_DC: Pointer);
begin
  zend_register_string_constant(name, length(name) + 1, str, flags, 0, TSRMLS_DC);
end;

procedure REGISTER_MAIN_STRINGL_CONSTANT(name: zend_pchar; str: zend_pchar; len: uint; flags: integer; TSRMLS_DC: Pointer);
begin
  zend_register_stringl_constant(name, length(name) + 1, str, len, flags, 0, TSRMLS_DC);
end;

procedure ZVAL_RESOURCE(value: pzval; l: longint);
begin
  {$IFDEF PHP7}
  value^.u1.v._type
  {$ELSE}
  value^._type
  {$ENDIF} := IS_RESOURCE;
  value^.value.lval := l;
end;

procedure ZVAL_BOOL(z: pzval; b: boolean);
begin
  {$IFDEF PHP7}
  z^.u1.v._type
  {$ELSE}
  z^._type
  {$ENDIF} := IS_BOOL;
  z^.value.lval := integer(b);
end;

procedure ZVAL_NULL(z: pzval);
begin
  {$IFDEF PHP7}
  z^.u1.v._type
  {$ELSE}
  z^._type
  {$ENDIF}  := IS_NULL;
end;

procedure ZVAL_LONG(z: pzval; l: longint);
begin
  {$IFDEF PHP7}
  z^.u1.v._type
  {$ELSE}
  z^._type
  {$ENDIF}  := IS_LONG;
  z^.value.lval := l;
end;

procedure ZVAL_DOUBLE(z: pzval; d: double);
begin
  {$IFDEF PHP7}
  z^.u1.v._type
  {$ELSE}
  z^._type
  {$ENDIF}  := IS_DOUBLE;
  z^.value.dval := d;
end;
procedure ZvalString(z:pzval);
begin
  z^.value.str.len := 0;
  z^.value.str.val := '';
  {$IFDEF PHP7}
  z^.u1.v._type
  {$ELSE}
  z^._type
  {$ENDIF}  := IS_STRING;
end;

procedure ZvalString(z:pzval; s:zend_pchar; len:Integer = 0);
var
  lens:Integer;
begin
  if not assigned(s) then
    ZvalString(z)
  else begin
    if len = 0 then
      lens := Length(s)
    else
      lens := len;

    z^.value.str.len := lens;
    z^.value.str.val := estrndup(s, lens);
    {$IFDEF PHP7}
    z^.u1.v._type
    {$ELSE}
    z^._type
    {$ENDIF}  := IS_STRING;
  end;
end;

procedure ZvalString(z:pzval; s:PWideChar; len:Integer = 0);
begin
  if not assigned(s) then
    ZvalString(z)
  else
    ZvalString(z, zend_pchar(zend_ustr(WideString(s))), len);
end;

procedure ZvalString(z:pzval; s:string; len:Integer = 0);
var
  _s:PWideChar;
begin
  _s := PWideChar(s);

  if not assigned(_s) then
    ZvalString(z)
  else
    ZvalString(z, _s, len);
end;
function ZvalInt;
begin
  Result := z.value.lval;
end;

function ZvalDouble;
begin
  Result := z.value.dval;
end;

function ZvalBool;
begin
  Result := boolean(z.value.lval);
end;

function ZvalStrS;
begin
 Result := z.value.str.val;
end;

function ZvalStr;
begin
 Result := z.value.str.val;
end;

function ZvalStrW;
begin
 Result := WideString(z.value.str.val);
end;

procedure ZvalVAL(z:pzval; v:Boolean);
Begin
  {$IFDEF PHP7}
  z^.u1.v._type
  {$ELSE}
  z^._type
  {$ENDIF}  := IS_BOOL;
  z.value.lval := integer(v);
End;

procedure ZvalVAL(z:pzval; v:Integer; const _type:Integer = IS_LONG);
Begin
  {$IFDEF PHP7}
  z^.u1.v._type
  {$ELSE}
  z^._type
  {$ENDIF}  := _type;
  z^.value.lval := v;
End;

procedure ZvalVAL(z:pzval);
Begin
  {$IFDEF PHP7}
  z^.u1.v._type
  {$ELSE}
  z^._type
  {$ENDIF}  := IS_NULL;
End;

procedure ZvalVAL(z:pzval; v:Double);
Begin
  {$IFDEF PHP7}
  z^.u1.v._type
  {$ELSE}
  z^._type
  {$ENDIF} := IS_LONG;
  z.value.dval := v;
End;
procedure ZvalVAL(z: pzval; s: zend_ustr; len: Integer = 0);
var
  lens: Integer;
  AChar: zend_pchar;
begin
  AChar := zend_pchar(s);

  if not assigned(AChar) then
    ZVAL_NULL(z)
  else
  begin
    if len = 0 then
      lens := Length(AChar)
    else
      lens := len;

    z^.value.str.len := lens;
    z^.value.str.val := _estrndup(AChar, lens, nil, 0, nil, 0);
    {$IFDEF PHP7}
    z^.u1.v._type
    {$ELSE}
    z^._type
    {$ENDIF}  := IS_STRING;
  end;
end;

function AddElementZvalArray(z: pzval; Args: array of const; flag: Integer;
  idx: uint = 0; len: uint = 0; const key: zend_ustr = ''): Integer;
var
  tmp: pzval;
  arKey: zend_pchar;
begin
  Result := FAILURE;
  if {$IFDEF PHP7}
  z^.u1.v._type
  {$ELSE}
  z^._type
  {$ENDIF}  <> IS_ARRAY then
    exit;

  if len <> 0 then
  begin
    inc(len);
    arKey := zend_pchar(key);
    idx := zend_hash_func(arKey, len);
  end;

  tmp := GetArgPZval(Args[0], 1, true);

  Result := _zend_hash_quick_add_or_update(
  {$IFDEF PHP7}z.value.arr{$ELSE}z.value.ht{$ENDIF}, arKey, len, idx, tmp,
    sizeof(pzval), nil, flag);
end;
// Add Next
function ZvalArrayAdd(z: pzval; Args: array of const): Integer; overload;
begin
  Result := FAILURE;
  if {$IFDEF PHP7}
  z^.u1.v._type
  {$ELSE}
  z^._type
  {$ENDIF} <> IS_ARRAY then
    exit;
  Result := AddElementZvalArray(z, Args, HASH_NEXT_INSERT,
    {$IFDEF PHP7} z.value.arr.nNextFreeElement {$ELSE} z.value.ht.nNextFreeElement {$ENDIF});
end;

// Add Index
function ZvalArrayAdd(z: pzval; idx: Integer; Args: array of const)
  : Integer; overload;
begin
  Result := AddElementZvalArray(z, Args, HASH_UPDATE, idx);
end;

// Add Assoc
function ZvalArrayAdd(z: pzval; key: zend_ustr; Args: array of const)
  : Integer; overload;
begin
  Result := AddElementZvalArray(z, Args, HASH_UPDATE, 0, Length(key), key);
end;

function IsArrayRetVal(v: pzval): Boolean;
begin
  Result := {$IFDEF PHP7}
  v^.u1.v._type
  {$ELSE}
  v^._type
  {$ENDIF} = IS_ARRAY;
end;

function ZValArrayKeyExists(v: pzval; key: zend_ustr): Boolean; overload;
begin
  Result := false;
  if {$IFDEF PHP7}
  v^.u1.v._type
  {$ELSE}
  v^._type
  {$ENDIF} <> IS_ARRAY then
    exit;

  if {$IFDEF PHP7} v.value.arr.nNumOfElements {$ELSE} v.value.ht.nNumOfElements {$ENDIF} = 0  then
    exit;

  Result := zend_hash_exists({$IFDEF PHP7}v.value.arr{$ELSE}v.value.ht{$ENDIF}, zend_pchar(key), Length(key) + 1) = 1;
end;

function ZValArrayKeyExists(v: pzval; idx: Integer): Boolean; overload;
begin
  Result := false;
  if ({$IFDEF PHP7} v.u1.v._type {$ELSE} v._type {$ENDIF} <> IS_ARRAY) then
    exit;

  if {$IFDEF PHP7} v.value.arr.nNumOfElements {$ELSE} v.value.ht.nNumOfElements {$ENDIF} = 0  then
    exit;

  Result := zend_hash_index_exists({$IFDEF PHP7}v.value.arr{$ELSE}v.value.ht{$ENDIF}, idx) = 1;
end;

function ZValArrayKeyExists(v: pzval; key: zend_ustr; out pData: pzval)
  : Boolean; overload;
var
  tmp: ppzval;
begin
  Result := ZValArrayKeyExists(v, key);
  if Result then
  begin
    pData := nil;
    if ZValArrayKeyFind(v, key, tmp) then
      pData := tmp^;
  end;
end;

function ZValArrayKeyExists(v: pzval; idx: Integer; out pData: pzval)
  : Boolean; overload;
var
  tmp: ppzval;
begin
  Result := ZValArrayKeyExists(v, idx);
  if Result then
  begin
    pData := nil;
    if ZValArrayKeyFind(v, idx, tmp) then
      pData := tmp^;
  end;
end;

function ZValArrayKeyDel(v: pzval; key: zend_ustr): Boolean; overload;
{$IFDEF PHP7}
var
  pzs: pzend_string;
{$ENDIF}
begin
  Result := false;
  if ZValArrayKeyExists(v, key) then
  {$IFDEF PHP7}
  begin
  pzs^.len := strlen(zend_pchar(key));
  pzs^.val := estrdup(zend_pchar(key));
  Result := zend_hash_del_key_or_index(v.value.arr, pzs) = SUCCESS
  end;
  {$ELSE}
    Result := zend_hash_del_key_or_index(v.value.ht, zend_pchar(key),
      Length(key) + 1, 0, HASH_DEL_KEY) = SUCCESS;
  {$ENDIF}
end;

function ZValArrayKeyDel(v: pzval; idx: Integer): Boolean; overload;
{$IFDEF PHP7}
var
  pzs: pzend_string;
{$ENDIF}
begin
  Result := false;
  if ZValArrayKeyExists(v, idx) then
  {$IFDEF PHP7}
  begin
  pzs^.len := strlen(zend_pchar(inttostr(idx)));
  pzs^.val := estrdup(zend_pchar(inttostr(idx)));
  Result := zend_hash_del_key_or_index(v.value.arr, pzs) = SUCCESS
  end;
  {$ELSE}
    Result := zend_hash_del_key_or_index({$IFDEF PHP7}v.value.arr{$ELSE}v.value.ht{$ENDIF}, nil, 0, idx,
      HASH_DEL_INDEX) = SUCCESS;
  {$ENDIF}
end;

function ZValArrayKeyFind(v: pzval; key: zend_ustr; out pData: ppzval)
  : Boolean; overload;
var
  keyStr: zend_pchar;
  KeyLength: uint;
begin
  keyStr := zend_pchar(key);
  KeyLength := Length(key) + 1;

  Result := zend_hash_quick_find({$IFDEF PHP7}v.value.arr{$ELSE}v.value.ht{$ENDIF}, keyStr, KeyLength,
    zend_hash_func(keyStr, KeyLength), pData) = SUCCESS;
end;

function ZValArrayKeyFind(v: pzval; idx: Integer; out pData: ppzval)
  : Boolean; overload;
begin
  Result := zend_hash_quick_find({$IFDEF PHP7}v.value.arr{$ELSE}v.value.ht{$ENDIF}, nil, 0, idx, pData) = SUCCESS;
end;
procedure MAKE_STD_ZVAL(out Result: pzval);
begin
  {$IFNDEF PHP7}
    ALLOC_ZVAL(Result);
  {$ENDIF}
  INIT_PZVAL(Result);
end;



function GetArgPZval;
begin
  if Args._Reserved1 = 0 then // nil
  begin
    if Make then
      MAKE_STD_ZVAL(Result);
   {$IFDEF PHP7} Result.u1.v._type {$ELSE} Result._type {$ENDIF} := IS_NULL;
  end
  else if Args.VType = vtPointer then
    Result := Args.VPointer
  else
  begin
    if Make then
      MAKE_STD_ZVAL(Result);
    case Args.VType of
      vtInteger:
        ZvalVAL(Result, Args.VInteger, _type);
      vtInt64:
        ZvalVAL(Result, NativeInt(Args.VInt64^), _type);
      vtBoolean:
        ZvalVAL(Result, Args.VBoolean);
      vtExtended:
        ZvalVAL(Result, Args.VExtended^);
      vtClass, vtObject:
        ZvalVAL(Result, Args._Reserved1);
      vtString:
        ZvalVAL(Result, zend_ustr(Args.VString^));
      vtAnsiString:
        ZvalVAL(Result, zend_pchar(zend_ustr(Args.VAnsiString)));
      vtUnicodeString:
        ZvalVAL(Result, UnicodeString(Args._Reserved1));
      vtWideChar:
        ZvalVAL(Result, zend_ustr(Args.VWideChar));
      vtChar:
        ZvalVAL(Result, zend_pchar(zend_uchar(Args.VChar)));
      vtPWideChar:
        ZvalVAL(Result, Args.VPWideChar);
      vtPChar:
        ZvalVAL(Result, zend_pchar(Args.VPChar));
      vtWideString:
        ZvalVAL(Result, zend_pchar(Args.VWideString));
    end;
  end;
end;


procedure ZVAL_STRINGU(z: pzval; s: PUtf8Char; duplicate: boolean);
var
  __s : PUTF8Char;
begin
  if not assigned(s) then
   __s := ''
    else
     __s := s;

  z^.value.str.len := length(__s);
  if duplicate then

   z^.value.str.val := estrndup(__s, z^.value.str.len)
  else
    z^.value.str.val := __s;
  {$IFDEF PHP7} z^.u1.v._type {$ELSE} z^._type {$ENDIF} := IS_STRING;
end;

procedure ZVAL_STRING(z: pzval; s: zend_pchar; duplicate: boolean);
var
  __s : zend_pchar;
begin
  if not assigned(s) then
   __s := ''
    else
     __s := s;

  z^.value.str.len := strlen(__s);
  if duplicate then

   z^.value.str.val := estrndup(__s, z^.value.str.len)
  else
    z^.value.str.val := __s;
  {$IFDEF PHP7} z^.u1.v._type {$ELSE} z^._type {$ENDIF} := IS_STRING;
end;

procedure ZVAL_STRINGW(z: pzval; s: PWideChar; duplicate: boolean);
var
  __s : zend_pchar;
  StA : zend_ustr;
  StW : WideString;
begin
  if not assigned(s) then
   __s := ''
    else
      begin
        StW := WideString(s);
        StA := zend_ustr(StW);
        __s := zend_pchar(StA);
      end;

  z^.value.str.len := strlen(__s);
  if duplicate then

   z^.value.str.val := estrndup(__s, z^.value.str.len)
  else
    z^.value.str.val := __s;
  {$IFDEF PHP7} z^.u1.v._type {$ELSE} z^._type {$ENDIF} := IS_STRING;
end;

procedure ZVAL_STRINGL(z: pzval; s: zend_pchar; l: integer; duplicate: boolean);
var
  __s  : zend_pchar;
  __l  : integer;
begin
  if not assigned(s) then
   __s := ''
    else
     __s := s;
  __l := l;
  z^.value.str.len := __l;
  if duplicate then
    z^.value.str.val := estrndup(__s, __l)
  else
    z^.value.str.val := __s;
  {$IFDEF PHP7} z^.u1.v._type {$ELSE} z^._type {$ENDIF} := IS_STRING;
end;

procedure ZVAL_STRINGLW(z: pzval; s: PWideChar; l: integer; duplicate: boolean);
var
  __s  : zend_pchar;
  __l  : integer;
  StA : zend_ustr;
  StW : WideString;
begin
  if not assigned(s) then
   __s := ''
    else
     begin
       StW := WideString(s);
       StA := zend_ustr(StW);
        __s := zend_pchar(StA);
     end;

  __l := l;
  z^.value.str.len := __l;
  if duplicate then
    z^.value.str.val := estrndup(__s, __l)
  else
    z^.value.str.val := __s;
  {$IFDEF PHP7} z^.u1.v._type {$ELSE} z^._type {$ENDIF} := IS_STRING;
end;

procedure ZVAL_EMPTY_STRING(z: pzval);
begin
  z^.value.str.len := 0;
 // {$IFDEF PHP510}
  z^.value.str.val := STR_EMPTY_ALLOC;
  (*{$ELSE}
  z^.value.str.val := '';
  {$ENDIF}*)
  {$IFDEF PHP7} z^.u1.v._type {$ELSE} z^._type {$ENDIF} := IS_STRING;
end;

procedure ZVAL_TRUE(z: pzval);
begin
  {$IFDEF PHP7} z^.u1.v._type {$ELSE} z^._type {$ENDIF} := IS_BOOL;
  z^.value.lval := 1;
end;

procedure ZVAL_FALSE(z: pzval);
begin
  {$IFDEF PHP7} z^.u1.v._type {$ELSE} z^._type {$ENDIF} := IS_BOOL;
  z^.value.lval := 0;
end;
function ToStrA(V: Variant): zend_ustr;
begin
  Result := V;
end;

function ToStr(V: Variant): String;
begin
  Result := V;
end;

function ToPChar(V: Variant): zend_pchar;
begin
  Result := zend_pchar(ToStr(V));
end;

function toWChar(s: zend_pchar): PWideChar;
  var
  ss: WideString;
  ss2: string;
begin
  ss2 := s;
  ss := ss2;
  Result := PWideChar(ss);
end;

function ZendToVariant(const Value: pppzval): Variant; overload;
  Var
  S: String;
begin
 case {$IFDEF PHP7} Value^^^.u1.v._type {$ELSE}Value^^^._type{$ENDIF} of
 1: Result := Value^^^.value.lval;
 2: Result := Value^^^.value.dval;
 6: begin S := Value^^^.value.str.val; Result := S; end;
 4,5: Result := Null;
 end;
end;

function ZendToVariant(const Value: ppzval): Variant; overload;
  Var
  S: String;
begin
Result := Null;
 case {$IFDEF PHP7} Value^^.u1.v._type {$ELSE}Value^^._type{$ENDIF} of
 1: Result := Value^^.value.lval;
 2: Result := Value^^.value.dval;
 6: begin S := Value^^.value.str.val; Result := S; end;
 4,5: Result := Null;
 end;
end;

procedure HashToArray(HT: {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; var AR: TArrayVariant); overload;
  Var
  Len,I: Integer;
  tmp : pppzval;
begin
 len := zend_hash_num_elements(HT);
 SetLength(AR,len);
 for i:=0 to len-1 do
  begin
    new(tmp);

    zend_hash_index_find(ht,i,tmp);

    AR[i] := ZendToVariant(tmp);
    freemem(tmp);
  end;
end;


procedure ArrayToHash(AR: Array of Variant; var HT: pzval); overload;
  Var
  I,Len: Integer;
begin
  _array_init(ht,nil,1);
  len := Length(AR);
  for i:=0 to len-1 do
   begin
     case VarType(AR[i]) of
     varInteger, varSmallint, varLongWord, 17: add_index_long(ht,i,AR[i]);
     varDouble,varSingle: add_index_double(ht,i,AR[i]);
     varBoolean: add_index_bool(ht,i,AR[I]);
     varEmpty: add_index_null(ht,i);
     varString: add_index_string(ht,i,zend_pchar(ToStr(AR[I])),1);
     258: add_index_string(ht,i,zend_pchar(zend_ustr(ToStr(AR[I]))),1);
     end;
   end;
end;

procedure ArrayToHash(Keys,AR: Array of Variant; var HT: pzval); overload;
  Var
  I,Len: Integer;
    v: Variant;
    key: zend_pchar;
    s: zend_pchar;
begin
  _array_init(ht,nil,1);
  len := Length(AR);
  for i:=0 to len-1 do
   begin
     v := AR[I];
     key := zend_pchar(ToStrA(keys[i]));
     s := zend_pchar(ToStrA(v));
     case VarType(AR[i]) of
     varInteger, varSmallint, varLongWord, 17: add_assoc_long_ex(ht,ToPChar(Keys[i]),strlen(ToPChar(Keys[i]))+1,AR[i]);
     varDouble,varSingle: add_assoc_double_ex(ht,ToPChar(Keys[i]),strlen(ToPChar(Keys[i]))+1,AR[i]);
     varBoolean: add_assoc_bool_ex(ht,ToPChar(Keys[i]),strlen(ToPChar(Keys[i]))+1,AR[I]);
     varEmpty: add_assoc_null_ex(ht,ToPChar(Keys[i]),strlen(ToPChar(Keys[i]))+1);
     varString,258: add_assoc_string_ex(ht,key,strlen(key)+1,s,1);
     end;
   end;
end;

function add_next_index_variant(arg: pzval; value: variant): integer;
var iz: pzval;
    W: WideString;
    S: String;
begin
  iz := MAKE_STD_ZVAL;
  if VarIsEmpty(value) then
   begin
     ZVAL_NULL(iz);
     Result := add_next_index_zval(arg, iz);
     Exit;
   end;
    //   MessageBoxA(0, zend_pchar(AnsiString( TVarData(Value).VType.ToString)), '', 0 ) ;
   case TVarData(Value).VType of
     varString    : //Peter Enz
         begin
           if Assigned ( TVarData(Value).VString ) then
             begin
               ZVAL_STRING(iz, TVarData(Value).VString , true);
             end
               else
                 begin
                   ZVAL_STRING(iz, '', true);
                 end;
         end;

     varUString    : //Peter Enz
         begin
            S := string(TVarData(Value).VUString);

             ZVAL_STRING(iz, zend_pchar(zend_ustr(S)), true);
         end;

     varOleStr    : //Peter Enz
         begin
           if Assigned ( TVarData(Value).VOleStr ) then
             begin
               W := WideString(Pointer(TVarData(Value).VOleStr));
               ZVAL_STRINGW(iz, PWideChar(W),  true);
             end
               else
                 begin
                   ZVAL_STRING(iz, '', true);
                 end;
         end;
     varSmallInt : ZVAL_LONG(iz, TVarData(Value).VSmallint);
     varInteger  : ZVAL_LONG(iz, TVarData(Value).VInteger);
     varBoolean  : ZVAL_BOOL(iz, TVarData(Value).VBoolean);
     varSingle   : ZVAL_DOUBLE(iz, TVarData(Value).VSingle);
     varDouble   : ZVAL_DOUBLE(iz, TVarData(Value).VDouble);
     varError    : ZVAL_LONG(iz, TVarData(Value).VError);
     varByte     : ZVAL_LONG(iz, TVarData(Value).VByte);
     varDate     : ZVAL_DOUBLE(iz, TVarData(Value).VDate);
     else
       ZVAL_NULL(iz);
   end;

    Result := add_next_index_zval(arg, iz);
end;


procedure ZVAL_ARRAY(z: pzval; arr:  TWSDate); overload;
var
  i : integer;
begin
 if _array_init(z, nil, 0) = FAILURE then //������ ������ ������� ������
  begin
    ZVAL_FALSE(z);
    Exit;
  end;

  if Length(arr) = 0 then
  begin
    {$IFDEF PHP7}
    z^.value.counted.gc.refcount
    {$ELSE}
    z^.refcount
    {$ENDIF} := 1;
    Exit;
  end;

   for i := 0 to Length(arr)-1 do
    begin
       add_next_index_string(z, zend_pchar(zend_ustr(arr[i])), 1);
    end;
    Exit;
end;

procedure ZVAL_ARRAY(z: pzval; arr:  TASDate); overload;
var
  i : integer;
begin
 if _array_init(z, nil, 0) = FAILURE then //������ ������ ������� ������
  begin
    ZVAL_FALSE(z);
    Exit;
  end;

  if Length(arr) = 0 then
  begin
    {$IFDEF PHP7}
    z^.value.counted.gc.refcount
    {$ELSE}
    z^.refcount
    {$ENDIF} := 1;
    Exit;
  end;

   for i := 0 to Length(arr)-1 do
    begin
       add_next_index_string(z, zend_pchar(arr[i]), 1);
    end;
    Exit;
end;

procedure ZVAL_ARRAY(z: pzval; arr: array of string); overload;
var
  i: integer;
begin
 if _array_init(z, nil, 0) = FAILURE then //������ ������ ������� ������
  begin
    ZVAL_FALSE(z);
    Exit;
  end;

  if Length(arr) = 0 then
  begin
    {$IFDEF PHP7}
    z^.value.counted.gc.refcount
    {$ELSE}
    z^.refcount
    {$ENDIF} := 1;
    Exit;
  end;

   for i := 0 to Length(arr)-1 do
    begin
       add_next_index_string(z, zend_pchar(zend_ustr(arr[i])), 1);
    end;
    Exit;
end;

procedure ZVAL_ARRAY(z: pzval; arr:  array of zend_ustr); overload;
var
  i: integer;
begin
 if _array_init(z, nil, 0) = FAILURE then //������ ������ ������� ������
  begin
    ZVAL_FALSE(z);
    Exit;
  end;

  if Length(arr) = 0 then
  begin
    {$IFDEF PHP7}
    z^.value.counted.gc.refcount
    {$ELSE}
    z^.refcount
    {$ENDIF} := 1;
    Exit;
  end;

   for i := 0 to Length(arr)-1 do
    begin
       add_next_index_string(z, zend_pchar(arr[i]), 1);
    end;
    Exit;
end;

procedure ZVAL_ARRAY(z: pzval; arr:  array of variant); overload;
var
  i: integer;
begin
 if _array_init(z, nil, 0) = FAILURE then //������ ������ ������� ������
  begin
    ZVAL_FALSE(z);
    Exit;
  end;

  if Length(arr) = 0 then
  begin
    {$IFDEF PHP7}
    z^.value.counted.gc.refcount
    {$ELSE}
    z^.refcount
    {$ENDIF} := 1;
    Exit;
  end;

   for i := 0 to Length(arr)-1 do
    begin
       add_next_index_variant(z, arr[i]);
    end;
    Exit;
end;
procedure ZVAL_ARRAY(z: pzval; arr: System.TArray<System.integer>); overload;
var
  i: integer;
begin
 if _array_init(z, nil, 0) = FAILURE then //������ ������ ������� ������
  begin
    ZVAL_FALSE(z);
    Exit;
  end;

  if Length(arr) = 0 then
  begin
    {$IFDEF PHP7}
    z^.value.counted.gc.refcount
    {$ELSE}
    z^.refcount
    {$ENDIF} := 1;
    Exit;
  end;

   for i := 0 to Length(arr)-1 do
    begin
       add_next_index_long(z, arr[i]);
    end;
    Exit;
end;

procedure ZVAL_ARRAY(z: pzval; arr: Variant); overload;
var
  i: integer;
  {V: TVarData;}
begin
 if _array_init(z, nil, 0) = FAILURE then //������ ������ ������� ������
  begin
    ZVAL_FALSE(z);
    Exit;
  end;

  if arr.PVarArray.DimCount = 0 then
  begin
    ZVAL_FALSE(z);
    Exit;
  end;

   for i := 0 to arr.DimCount-1 do
    begin
    {V := TVarData(  arr[i] );
    case V.VType of
      varEmpty, varNull:
        add_next_index_null(z);
      varSmallInt:
        add_next_index_string(z, zend_pchar(zend_ustr(IntToStr(V.VSmallInt))), 1);
      varInteger:
        add_next_index_string(z, zend_pchar(zend_ustr(IntToStr(V.VInteger))), 1);
      varSingle:
        add_next_index_string(z, zend_pchar(zend_ustr(V.VSingle.ToString())), 1);
      varDouble:
        add_next_index_double(z, V.VDouble);
      varCurrency:
        add_next_index_string(z, zend_pchar(zend_ustr(CurrToStr(V.VCurrency))), 1);
      varDate:
        add_next_index_string(z, zend_pchar(zend_ustr(DateTimeToStr(V.VDate))), 1);
      varOleStr:
        add_next_index_string(z, zend_pchar(zend_ustr(V.VOleStr)), 1);
      varBoolean:
        add_next_index_bool(z, V.VBoolean.ToInteger());
      varByte:
        add_next_index_string(z, zend_pchar(zend_ustr(IntToStr(V.VByte))), 1);
      varWord:
        add_next_index_string(z, zend_pchar(zend_ustr(IntToStr(V.VWord))), 1);
      varShortInt:
        add_next_index_string(z, zend_pchar(zend_ustr(IntToStr(V.VShortInt))), 1);
      varLongWord:
        add_next_index_long(z, V.VLongWord);
      varInt64:
        add_next_index_string(z, zend_pchar(zend_ustr(IntToStr(V.VInt64))), 1);
      varString:
        add_next_index_string(z, zend_pchar(zend_ustr(V.VString)), 1);
      {$IFDEF SUPPORTS_UNICODE_STRING}{
      varUString:
        add_next_index_string(z, zend_pchar(zend_ustr(V.VUString)), 1);
      {$ENDIF SUPPORTS_UNICODE_STRING}
      {varArray,
      varDispatch,
      varError,
      varUnknown,
      varAny,
      varByRef:}{
      varObject:
      add_next_index_long(z, Integer(
    end;                               }
       add_next_index_variant(z, arr[i]);
    end;
    Exit;
end;

procedure ZVAL_ARRAYAC(z: pzval; keynames: Array of ansichar; keyvals: Array of ansichar);
var
  i : integer;
begin
 if _array_init(z, nil, 0) = FAILURE then
  begin
    ZVAL_FALSE(z);
    Exit;
  end;

  if (Length(keynames) = 0)and(Length(keynames) = Length(keyvals)) then
  begin
    {$IFDEF PHP7}
    z^.value.counted.gc.refcount
    {$ELSE}
    z^.refcount
    {$ENDIF} := 1;
    Exit;
  end;

  if Length(keynames) = Length(keyvals) then
   begin
   for i := 0 to Length(keynames)-1 do
      add_assoc_string_ex(z, zend_pchar(zend_uchar(keynames[i])), StrLen(PAnsiChar(keynames[i])) + 1, zend_pchar(zend_uchar(keyvals[i])), 1);
   end
   else
   begin
      ZVAL_FALSE(z);
   end;
end;
procedure ZVAL_ARRAYWC(z: pzval; keynames: Array of PWideChar; keyvals: Array of PWideChar);
var
  i : integer;
begin
 if _array_init(z, nil, 0) = FAILURE then
  begin
    ZVAL_FALSE(z);
    Exit;
  end;

  if (Length(keynames) = 0)and(Length(keynames) = Length(keyvals)) then
  begin
    {$IFDEF PHP7}
    z^.value.counted.gc.refcount
    {$ELSE}
    z^.refcount
    {$ENDIF} := 1;
    Exit;
  end;

  if Length(keynames) = Length(keyvals) then
   begin
   for i := 0 to Length(keynames)-1 do
    begin
      add_assoc_string_ex(z, zend_pchar(keynames[i]), StrLen(zend_pchar(keynames[i])) + 1, zend_pchar(keyvals[i]), 1);
    end;
    Exit;
   end
   else
   begin
      ZVAL_FALSE(z);
    Exit;
   end;

end;
procedure ZVAL_ARRAYWS(z: pzval; keynames:  TWSDate; keyvals:  TWSDate); overload;
var
  i : integer;
begin
 if _array_init(z, nil, 0) = FAILURE then //������ ������ ������� ������
  begin
    ZVAL_FALSE(z);
    Exit;
  end;
   //z^.refcount := Length(keynames); //������� ���������� ������������ ��������
  if (Length(keynames) = 0) then
  begin
    {$IFDEF PHP7}
    z^.value.counted.gc.refcount
    {$ELSE}
    z^.refcount
    {$ENDIF} := 1;
    Exit;
  end;

  if Length(keynames) = Length(keyvals) then
   begin
   for i := 0 to Length(keynames)-1 do
    begin
                    //������ ������ � ������� ������� ������
                    //������ ���������� ������ � ������ ������� ������
      add_assoc_string_ex(z, zend_pchar(zend_ustr(keynames[i])), StrLen(zend_pchar(zend_ustr(keynames[i]))) + 1,
      zend_pchar(zend_ustr(keyvals[i])), 1);

                    //���������� ����
    end;
    Exit;
   end
   else
   begin
      ZVAL_FALSE(z);
    Exit;
   end;

end;
procedure ZVAL_ARRAYWS(z: pzval; keynames:  array of string; keyvals:  array of string); overload;
var
  i : integer;
begin
 if _array_init(z, nil, 0) = FAILURE then
  begin
    ZVAL_FALSE(z);
    Exit;
  end;

  if (Length(keynames) = 0)and(Length(keynames) = Length(keyvals)) then
  begin
    {$IFDEF PHP7}
    z^.value.counted.gc.refcount
    {$ELSE}
    z^.refcount
    {$ENDIF} := 1;
    Exit;
  end;

  if Length(keynames) = Length(keyvals) then
   begin
   for i := 0 to Length(keynames)-1 do
    begin
      add_assoc_string_ex(z, zend_pchar(zend_ustr(keynames[i])), StrLen(zend_pchar(zend_ustr(keynames[i]))) + 1,
      zend_pchar(zend_ustr(keyvals[i])), 1);
    end;
    Exit;
   end
   else
   begin
      ZVAL_FALSE(z);
    Exit;
   end;

end;
procedure ZVAL_ARRAYAS(z: pzval; keynames: TASDate; keyvals: TASDate); overload;
var
  i : integer;
begin
 if _array_init(z, nil, 0) = FAILURE then
  begin
    ZVAL_FALSE(z);
    Exit;
  end;

  if (Length(keynames) = 0)and(Length(keynames) = Length(keyvals)) then
  begin
    {$IFDEF PHP7}
    z^.value.counted.gc.refcount
    {$ELSE}
    z^.refcount
    {$ENDIF} := 1;
    Exit;
  end;

  if Length(keynames) = Length(keyvals) then
   begin
   for i := 0 to Length(keynames)-1 do
    begin
      add_assoc_string_ex(z, zend_pchar(keynames[i]), StrLen(zend_pchar(keynames[i])) + 1, zend_pchar(keyvals[i]), 1);
    end;
    Exit;
   end
   else
   begin
      ZVAL_FALSE(z);
    Exit;
   end;

end;
procedure ZVAL_ARRAYAS(z: pzval; keynames: Array of AnsiString; keyvals: Array of AnsiString); overload;
var
  i : integer;
begin
 if _array_init(z, nil, 0) = FAILURE then
  begin
    ZVAL_FALSE(z);
    Exit;
  end;

  if (Length(keynames) = 0)and(Length(keynames) = Length(keyvals)) then
  begin
    {$IFDEF PHP7}
    z^.value.counted.gc.refcount
    {$ELSE}
    z^.refcount
    {$ENDIF} := 1;
    Exit;
  end;

  if Length(keynames) = Length(keyvals) then
   begin
   for i := 0 to Length(keynames)-1 do
    begin
      add_assoc_string_ex(z, zend_pchar(zend_ustr(keynames[i])), StrLen(PAnsiChar(keynames[i])) + 1, zend_pchar(zend_ustr(keyvals[i])), 1);
    end;
    Exit;
   end
   else
   begin
      ZVAL_FALSE(z);
    Exit;
   end;

end;
function ZENDLoaded: boolean;
begin
  Result := PHPLib <> 0;
end;

procedure UnloadZEND;
var
 H : THandle;
begin
  H := InterlockedExchange(Integer(PHPLib), 0);
  if H > 0 then
  begin
    FreeLibrary(H);
  end;
end;


function LoadZEND(const DllFilename: zend_ustr = PHPWin) : boolean;
var
  WriteFuncPtr  : pointer;
begin
 {$IFDEF QUIET_LOAD}
  Result := false;
 {$ENDIF}
  PHPLib := {$IFDEF PHP_UNICE}LoadLibrary( PWideChar(WideString(DllFilename)) ){$ELSE}LoadLibraryA(zend_pchar(DllFileName)){$ENDIF};

{$IFNDEF QUIET_LOAD}
  if PHPLib = 0 then
  begin
   RaiseLastOSError;
  // raise Exception.Create(RaiseLastOSError);
  end;
{$ELSE}
  if PHPLib = 0 then Exit;
{$ENDIF}

 {$IFDEF PHP5}
   zend_copy_constants := GetProcAddress(PHPLib, 'zend_copy_constants');
   zend_objects_new := GetProcAddress(PHPLib, 'zend_objects_new');
   zend_objects_clone_obj := GetProcAddress(PHPLib, 'zend_objects_clone_obj');
   function_add_ref := GetProcAddress(PHPLib, 'function_add_ref');
   zend_class_add_ref := GetProcAddress(PHPLib, 'zend_class_add_ref');

   zend_objects_store_add_ref := GetProcAddress(PHPLib, 'zend_objects_store_add_ref');
   zend_objects_store_del_ref := GetProcAddress(PHPLib, 'zend_objects_store_del_ref');

   zend_get_std_object_handlers := GetProcAddress(PHPLib, 'zend_get_std_object_handlers');
   zend_objects_get_address := GetProcAddress(PHPLib, 'zend_objects_get_address');
   zend_is_true := GetProcAddress(PHPLib, 'zend_is_true');
{$ENDIF}

  _zend_bailout := GetProcAddress(PHPLib, '_zend_bailout');

  zend_disable_function := GetProcAddress(PHPLib, 'zend_disable_function');
  zend_disable_class := GetProcAddress(PHPLib, 'zend_disable_class');
  zend_register_list_destructors_ex   := GetProcAddress(PHPLib, 'zend_register_list_destructors_ex');
  zend_register_resource :=           GetProcAddress(PHPLib, 'zend_register_resource');
  zend_fetch_resource :=              GetProcAddress(PHPLib, 'zend_fetch_resource');
  zend_list_insert :=                 GetProcAddress(PHPLib, 'zend_list_insert');
  {$IFNDEF PHP7}
  _zend_list_addref :=                GetProcAddress(PHPLib, '_zend_list_addref');
  _zend_list_delete :=                GetProcAddress(PHPLib, '_zend_list_delete');
  _zend_list_find :=                  GetProcAddress(PHPLib, '_zend_list_find');
  {$ENDIF}
  zend_rsrc_list_get_rsrc_type :=     GetProcAddress(PHPLib, 'zend_rsrc_list_get_rsrc_type');
  zend_fetch_list_dtor_id :=          GetProcAddress(PHPLib, 'zend_fetch_list_dtor_id');

  zend_get_compiled_filename := GetProcAddress(PHPLib, 'zend_get_compiled_filename');

  zend_get_compiled_lineno := GetProcAddress(PHPLib, 'zend_get_compiled_lineno');

  zend_ini_deactivate := GetProcAddress(PHPLib, 'zend_ini_deactivate');

  // -- tsrm_startup
  tsrm_startup := GetProcAddress(PHPLib, 'tsrm_startup');

  // -- ts_allocate_id
  ts_allocate_id := GetProcAddress(PHPLib, 'ts_allocate_id');

  // -- ts_free_id
  ts_free_id := GetProcAddress(PHPLib, 'ts_free_id');

  // -- zend_strndup
  zend_strndup := GetProcAddress(PHPLib,
  {$IFNDEF PHP7}
  'zend_strndup'
  {$ELSE}
  'zend_strndup@@8'
  {$ENDIF});

  // -- _emalloc
  _emalloc := GetProcAddress(PHPLib,
  {$IFNDEF PHP7}
  '_emalloc'
  {$ELSE}
  '_emalloc@@4'
  {$ENDIF});


  // -- _efree
  _efree := GetProcAddress(PHPLib,
  {$IFNDEF PHP7}
  '_efree'
  {$ELSE}
  '_efree@@4'
  {$ENDIF});


  // -- _ecalloc
  _ecalloc := GetProcAddress(PHPLib,
  {$IFNDEF PHP7}
  '_ecalloc'
  {$ELSE}
  '_ecalloc@@8'
  {$ENDIF});


  // -- _erealloc
  _erealloc := GetProcAddress(PHPLib,
  {$IFNDEF PHP7}
  '_erealloc'
  {$else}
  '_erealloc@@8'
  {$ENDIF});


  // -- _estrdup
  _estrdup := GetProcAddress(PHPLib,
  {$IFNDEF PHP7}
  '_estrdup'
  {$ELSE}
  '_estrdup@@4'
  {$ENDIF});

  // -- _estrndup
  _estrndup := GetProcAddress(PHPLib,
  {$IFNDEF PHP7}
  '_estrndup'
  {$ELSE}
  '_estrndup@@8'
  {$ENDIF});

  // -- _estrndup  Unicode
  _estrndupu := GetProcAddress(PHPLib,
  {$IFNDEF PHP7}
  '_estrndup'
  {$ELSE}
  '_estrndup@@8'
  {$ENDIF});

  // -- zend_set_memory_limit
  zend_set_memory_limit := GetProcAddress(PHPLib, 'zend_set_memory_limit');

  // -- start_memory_manager
  start_memory_manager := GetProcAddress(PHPLib, 'start_memory_manager');

  // -- shutdown_memory_manager
  shutdown_memory_manager := GetProcAddress(PHPLib, 'shutdown_memory_manager');

  {$IFDEF PHP4}
  // -- zend_hash_init
  zend_hash_init := GetProcAddress(PHPLib, 'zend_hash_init');

  // -- zend_hash_init_ex
  zend_hash_init_ex := GetProcAddress(PHPLib, 'zend_hash_init_ex');

  // -- zend_hash_quick_add_or_update
  zend_hash_quick_add_or_update := GetProcAddress(PHPLib, 'zend_hash_quick_add_or_update');

  // -- zend_hash_index_update_or_next_insert
  zend_hash_index_update_or_next_insert := GetProcAddress(PHPLib, 'zend_hash_index_update_or_next_insert');

  // -- zend_hash_merge
  zend_hash_merge := GetProcAddress(PHPLib, 'zend_hash_merge');
  {$ELSE}
  _zend_hash_init := GetProcAddress(PHPLib, '_zend_hash_init');
  _zend_hash_init_ex := GetProcAddress(PHPLib, '_zend_hash_init_ex');

  {$ENDIF}

  {$IFDEF PHP4}
  // -- zend_hash_add_or_update
  zend_hash_add_or_update := GetProcAddress(PHPLib, 'zend_hash_add_or_update');
  {$ELSE}
  // -- zend_hash_add_or_update
  _zend_hash_add_or_update := GetProcAddress(PHPLib,
  {$IFDEF PHP7}'_zend_hash_add_or_update@@16'{$ELSE}'_zend_hash_add_or_update'{$ENDIF});
  {$ENDIF}

  // -- zend_hash_destroy
  zend_hash_destroy := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_destroy@@4'{$ELSE}'zend_hash_destroy'{$ENDIF});

  // -- zend_hash_clean
  zend_hash_clean := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_clean@@4'{$ELSE}'zend_hash_clean'{$ENDIF});

  // -- zend_hash_add_empty_element
  zend_hash_add_empty_element := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_add_empty_element@@8'{$ELSE}'zend_hash_add_empty_element'{$ENDIF});

  // -- zend_hash_graceful_destroy
  zend_hash_graceful_destroy := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_graceful_destroy@@4'{$ELSE}'zend_hash_graceful_destroy'{$ENDIF});

  // -- zend_hash_graceful_reverse_destroy
  zend_hash_graceful_reverse_destroy := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_graceful_reverse_destroy@@4'{$ELSE}'zend_hash_graceful_reverse_destroy'{$ENDIF});

  // -- zend_hash_apply
  zend_hash_apply := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_apply@@8'{$ELSE}'zend_hash_apply'{$ENDIF});

  // -- zend_hash_apply_with_argument
  zend_hash_apply_with_argument := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_apply_with_argument@@12'{$ELSE}'zend_hash_apply_with_argument'{$ENDIF});

  // -- zend_hash_reverse_apply
  zend_hash_reverse_apply := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_reverse_apply@@8'{$ELSE}'zend_hash_reverse_apply'{$ENDIF});

  // -- zend_hash_del_key_or_index
  zend_hash_del_key_or_index := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_del@@8'{$ELSE}'zend_hash_del_key_or_index'{$ENDIF});

  // -- zend_get_hash_value
  zend_get_hash_value := GetProcAddress(PHPLib,
  {$IFDEF PHP560}'zend_hash_func'{$ELSE}'zend_get_hash_value'{$ENDIF});

  // -- zend_hash_find
  zend_hash_find := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_find@@8'{$ELSE}'zend_hash_find'{$ENDIF});

  // -- zend_hash_quick_find
  zend_hash_quick_find := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_find@@8'{$ELSE}'zend_hash_quick_find'{$ENDIF});

  // -- zend_hash_index_find
  zend_hash_index_find := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_index_find@@8'{$ELSE}'zend_hash_index_find'{$ENDIF});

  // -- zend_hash_exists
  zend_hash_exists := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_exists@@8'{$ELSE}'zend_hash_exists'{$ENDIF});

  // -- zend_hash_index_exists
  zend_hash_index_exists := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_index_exists@@8'{$ELSE}'zend_hash_index_exists'{$ENDIF});
  {$IFDEF PHP7}
  _zend_hash_add_or_update := GetProcAddress(PHPLib, '_zend_hash_add_or_update@@16');
  _zend_hash_add := GetProcAddress(PHPLib, '_zend_hash_add@@12');
  {$IFDEF P_CUT}
  zend_hash_index_findZval := GetProcAddress(PHPLib,'zend_hash_index_findZval');
  zend_symtable_findTest := GetProcAddress(PHPLib,'zend_symtable_findTest');
  zend_hash_index_existsZval := GetProcAddress(PHPLib,'zend_hash_index_existsZval');
  {$ENDIF}
  {$ELSE}
  // -- zend_hash_next_free_element
  zend_hash_next_free_element := GetProcAddress(PHPLib, 'zend_hash_next_free_element');
  {$ENDIF}
  // -- zend_hash_move_forward_ex
  zend_hash_move_forward_ex := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_move_forward_ex@@8'{$ELSE}'zend_hash_move_forward_ex'{$ENDIF});

  // -- zend_hash_move_backwards_ex
  zend_hash_move_backwards_ex := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_move_backwards_ex@@8'{$ELSE}'zend_hash_move_backwards_ex'{$ENDIF});

  // -- zend_hash_get_current_key_ex
  zend_hash_get_current_key_ex := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_get_current_key_ex@@16'{$ELSE}'zend_hash_get_current_key_ex'{$ENDIF});

  // -- zend_hash_get_current_key_type_ex
  zend_hash_get_current_key_type_ex := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_get_current_key_type_ex@@8'{$ELSE}'zend_hash_get_current_key_type_ex'{$ENDIF});

  // -- zend_hash_get_current_data_ex
  zend_hash_get_current_data_ex := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_get_current_data_ex@@8'{$ELSE}'zend_hash_get_current_data_ex'{$ENDIF});

  // -- zend_hash_internal_pointer_reset_ex
  zend_hash_internal_pointer_reset_ex := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_internal_pointer_reset_ex@@8'{$ELSE}'zend_hash_internal_pointer_reset_ex'{$ENDIF});

  // -- zend_hash_internal_pointer_end_ex
  zend_hash_internal_pointer_end_ex := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_internal_pointer_end_ex@@8'{$ELSE}'zend_hash_internal_pointer_end_ex'{$ENDIF});

  // -- zend_hash_copy
  zend_hash_copy := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_copy@@12'{$ELSE}'zend_hash_copy'{$ENDIF});


  // -- zend_hash_sort
  zend_hash_sort := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_sort_ex@@16'{$ELSE}'zend_hash_sort'{$ENDIF});

  // -- zend_hash_compare
  zend_hash_compare := GetProcAddress(PHPLib, 'zend_hash_compare');

  // -- zend_hash_minmax
  zend_hash_minmax := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_minmax@@12'{$ELSE}'zend_hash_minmax'{$ENDIF});

  // -- zend_hash_num_elements
  {$IFNDEF PHP7}
  zend_hash_num_elements := GetProcAddress(PHPLib, 'zend_hash_num_elements');
  {$ENDIF}

  // -- zend_hash_rehash
  zend_hash_rehash := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_hash_rehash@@4'{$ELSE}'zend_hash_rehash'{$ENDIF});

  // -- zend_hash_func
  zend_hash_func := GetProcAddress(PHPLib, 'zend_hash_func');

  // -- zend_get_constant
  zend_get_constant := GetProcAddress(PHPLib, 'zend_get_constant');

  // -- zend_register_long_constant
  zend_register_long_constant := GetProcAddress(PHPLib, 'zend_register_long_constant');

  // -- zend_register_double_constant
  zend_register_double_constant := GetProcAddress(PHPLib, 'zend_register_double_constant');

  // -- zend_register_string_constant
  zend_register_string_constant := GetProcAddress(PHPLib, 'zend_register_string_constant');

  // -- zend_register_stringl_constant
  zend_register_stringl_constant := GetProcAddress(PHPLib, 'zend_register_stringl_constant');

  // -- zend_register_constant
  zend_register_constant := GetProcAddress(PHPLib, 'zend_register_constant');

  zend_register_auto_global := GetProcAddress(PHPLib, 'zend_register_auto_global');
  {$IFDEF PHP5}
  zend_activate_auto_globals := GetProcAddress(PHPLib, 'zend_activate_auto_globals');
  {$ENDIF}

  // -- tsrm_shutdown
  tsrm_shutdown := GetProcAddress(PHPLib, 'tsrm_shutdown');

  // -- ts_resource_ex
  ts_resource_ex := GetProcAddress(PHPLib, 'ts_resource_ex');

  // -- ts_free_thread
  ts_free_thread := GetProcAddress(PHPLib, 'ts_free_thread');

  // -- zend_error
  zend_error := GetProcAddress(PHPLib, 'zend_error');

  // -- zend_error_cb
  zend_error_cb := GetProcAddress(PHPLib, 'zend_error_cb');

  // -- zend_eval_string
  zend_eval_string := GetProcAddress(PHPLib, 'zend_eval_string');

  // -- zend_make_compiled_string_description
  zend_make_compiled_string_description := GetProcAddress(PHPLib, 'zend_make_compiled_string_description');


  {$IFDEF PHP4}
  // -- _zval_dtor
  _zval_dtor := GetProcAddress(PHPLib, '_zval_dtor');

  // -- _zval_copy_ctor
  _zval_copy_ctor := GetProcAddress(PHPLib, '_zval_copy_ctor');

  {$ELSE}
  _zval_copy_ctor_func := GetProcAddress(PHPLib, {$IFDEF PHP7}'_zval_copy_ctor_func@@4'{$ELSE}'_zval_copy_ctor_func'{$ENDIF});
  _zval_dtor_func := GetProcAddress(PHPLib, {$IFDEF PHP7}'_zval_dtor_func@@4'{$ELSE}'_zval_dtor_func'{$ENDIF});
  _zval_ptr_dtor := GetProcAddress(PHPLib, '_zval_ptr_dtor');

  {$ENDIF}

  // -- zend_print_variable
  zend_print_variable := GetProcAddress(PHPLib, 'zend_print_variable');

  // -- zend_stack_init
  zend_stack_init := GetProcAddress(PHPLib, 'zend_stack_init');

  // -- zend_stack_push
  zend_stack_push := GetProcAddress(PHPLib, 'zend_stack_push');

  // -- zend_stack_top
  zend_stack_top := GetProcAddress(PHPLib, 'zend_stack_top');

  // -- zend_stack_del_top
  zend_stack_del_top := GetProcAddress(PHPLib, 'zend_stack_del_top');

  // -- zend_stack_int_top
  zend_stack_int_top := GetProcAddress(PHPLib, 'zend_stack_int_top');

  // -- zend_stack_is_empty
  zend_stack_is_empty := GetProcAddress(PHPLib, 'zend_stack_is_empty');

  // -- zend_stack_destroy
  zend_stack_destroy := GetProcAddress(PHPLib, 'zend_stack_destroy');

  // -- zend_stack_base
  zend_stack_base := GetProcAddress(PHPLib, 'zend_stack_base');

  // -- zend_stack_count
  zend_stack_count := GetProcAddress(PHPLib, 'zend_stack_count');

  // -- zend_stack_apply
  zend_stack_apply := GetProcAddress(PHPLib, 'zend_stack_apply');

  // -- zend_stack_apply_with_argument
  zend_stack_apply_with_argument := GetProcAddress(PHPLib, 'zend_stack_apply_with_argument');

  // -- _convert_to_string
  _convert_to_string := GetProcAddress(PHPLib, {$IFDEF PHP7}'_convert_to_string@@4'{$ELSE}'_convert_to_string'{$ENDIF});

  // -- add_function
  add_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'add_function@@12'{$ELSE}'add_function'{$ENDIF});

  // -- sub_function
  sub_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'sub_function@@12'{$ELSE}'sub_function'{$ENDIF});

  // -- mul_function
  mul_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'mul_function@@12'{$ELSE}'mul_function'{$ENDIF});

  // -- div_function
  div_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'div_function@@12'{$ELSE}'div_function'{$ENDIF});

  // -- mod_function
  mod_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'mod_function@@12'{$ELSE}'mod_function'{$ENDIF});

  // -- boolean_xor_function
  boolean_xor_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'boolean_xor_function@@12'{$ELSE}'boolean_xor_function'{$ENDIF});

  // -- boolean_not_function
  boolean_not_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'boolean_not_function@@8'{$ELSE}'boolean_not_function'{$ENDIF});

  // -- bitwise_not_function
  bitwise_not_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'bitwise_not_function@@8'{$ELSE}'bitwise_not_function'{$ENDIF});

  // -- bitwise_or_function
  bitwise_or_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'bitwise_or_function@@12'{$ELSE}'bitwise_or_function'{$ENDIF});

  // -- bitwise_and_function
  bitwise_and_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'bitwise_and_function@@12'{$ELSE}'bitwise_and_function'{$ENDIF});

  // -- bitwise_xor_function
  bitwise_xor_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'bitwise_xor_function@@12'{$ELSE}'bitwise_xor_function'{$ENDIF});

  // -- shift_left_function
  shift_left_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'shift_left_function@@12'{$ELSE}'shift_left_function'{$ENDIF});

  // -- shift_right_function
  shift_right_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'shift_right_function@@12'{$ELSE}'shift_right_function'{$ENDIF});

  // -- concat_function
  concat_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'concat_function@@12'{$ELSE}'concat_function'{$ENDIF});

  // -- is_equal_function
  is_equal_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'is_equal_function@@12'{$ELSE}'is_equal_function'{$ENDIF});

  // -- is_identical_function
  is_identical_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'is_identical_function@@12'{$ELSE}'is_identical_function'{$ENDIF});

  // -- is_not_identical_function
  is_not_identical_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'is_not_identical_function@@12'{$ELSE}'is_not_identical_function'{$ENDIF});

  // -- is_not_equal_function
  is_not_equal_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'is_not_equal_function@@12'{$ELSE}'is_not_equal_function'{$ENDIF});

  // -- is_smaller_function
  is_smaller_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'is_smaller_function@@12'{$ELSE}'is_smaller_function'{$ENDIF});

  // -- is_smaller_or_equal_function
  is_smaller_or_equal_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'is_smaller_or_equal_function@@12'{$ELSE}'is_smaller_or_equal_function'{$ENDIF});

  // -- increment_function
  increment_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'increment_function@@4'{$ELSE}'increment_function'{$ENDIF});

  // -- decrement_function
  decrement_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'decrement_function@@4'{$ELSE}'decrement_function'{$ENDIF});

  // -- convert_scalar_to_number
  convert_scalar_to_number := GetProcAddress(PHPLib, {$IFDEF PHP7}'convert_scalar_to_number@@4'{$ELSE}'convert_scalar_to_number'{$ENDIF});

  // -- convert_to_long
  convert_to_long := GetProcAddress(PHPLib, {$IFDEF PHP7}'convert_to_long@@4'{$ELSE}'convert_to_long'{$ENDIF});

  // -- convert_to_double
  convert_to_double := GetProcAddress(PHPLib, {$IFDEF PHP7}'convert_to_double@@4'{$ELSE}'convert_to_double'{$ENDIF});

  // -- convert_to_long_base
  convert_to_long_base := GetProcAddress(PHPLib, {$IFDEF PHP7}'convert_to_long_base@@8'{$ELSE}'convert_to_long_base'{$ENDIF});

  // -- convert_to_null
  convert_to_null := GetProcAddress(PHPLib, {$IFDEF PHP7}'convert_to_null@@4'{$ELSE}'convert_to_null'{$ENDIF});

  // -- convert_to_boolean
  convert_to_boolean := GetProcAddress(PHPLib, {$IFDEF PHP7}'convert_to_boolean@@4'{$ELSE}'convert_to_boolean'{$ENDIF});

  // -- convert_to_array
  convert_to_array := GetProcAddress(PHPLib, {$IFDEF PHP7}'convert_to_array@@4'{$ELSE}'convert_to_array'{$ENDIF});

  // -- convert_to_object
  convert_to_object := GetProcAddress(PHPLib, {$IFDEF PHP7}'convert_to_object@@4'{$ELSE}'convert_to_object'{$ENDIF});
  {$IFNDEF PHP7}
  // -- add_char_to_string
  add_char_to_string := GetProcAddress(PHPLib, 'add_char_to_string');

  // -- add_string_to_string
  add_string_to_string := GetProcAddress(PHPLib, 'add_string_to_string');
  {$ENDIF}
  // -- zend_string_to_double
  zend_string_to_double := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_strtod'{$ELSE}'zend_string_to_double'{$ENDIF});

  // -- zval_is_true
  zval_is_true := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_is_true@@4'{$ELSE}'zval_is_true'{$ENDIF});

  // -- compare_function
  compare_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'compare_function@@12'{$ELSE}'compare_function'{$ENDIF});

  // -- numeric_compare_function
  numeric_compare_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'numeric_compare_function@@8'{$ELSE}'numeric_compare_function'{$ENDIF});

  // -- string_compare_function
  string_compare_function := GetProcAddress(PHPLib, {$IFDEF PHP7}'string_compare_function@@8'{$ELSE}'string_compare_function'{$ENDIF});

  // -- zend_str_tolower
  zend_str_tolower := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_str_tolower@@8'{$ELSE}'zend_str_tolower'{$ENDIF});

  // -- zend_binary_zval_strcmp
  zend_binary_zval_strcmp := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_binary_zval_strcmp@@8'{$ELSE}'zend_binary_zval_strcmp'{$ENDIF});

  // -- zend_binary_zval_strncmp
  zend_binary_zval_strncmp := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_binary_zval_strncmp@@12'{$ELSE}'zend_binary_zval_strncmp'{$ENDIF});

  // -- zend_binary_zval_strcasecmp
  zend_binary_zval_strcasecmp := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_binary_zval_strcasecmp@@8'{$ELSE}'zend_binary_zval_strcasecmp'{$ENDIF});

  // -- zend_binary_zval_strncasecmp
  zend_binary_zval_strncasecmp := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_binary_zval_strncasecmp@@12'{$ELSE}'zend_binary_zval_strncasecmp'{$ENDIF});

  // -- zend_binary_strcmp
  zend_binary_strcmp := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_binary_strcmp@@16'{$ELSE}'zend_binary_strcmp'{$ENDIF});

  // -- zend_binary_strncmp
  zend_binary_strncmp := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_binary_strncmp@@20'{$ELSE}'zend_binary_strncmp'{$ENDIF});

  // -- zend_binary_strcasecmp
  zend_binary_strcasecmp := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_binary_strcasecmp@@16'{$ELSE}'zend_binary_strcasecmp'{$ENDIF});

  // -- zend_binary_strncasecmp
  zend_binary_strncasecmp := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_binary_strncasecmp@@20'{$ELSE}'zend_binary_strncasecmp'{$ENDIF});

  // -- zendi_smart_strcmp
  zendi_smart_strcmp := GetProcAddress(PHPLib, {$IFDEF PHP7}'zendi_smart_strcmp@@8'{$ELSE}'zendi_smart_strcmp'{$ENDIF});

  // -- zend_compare_symbol_tables
  zend_compare_symbol_tables := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_compare_symbol_tables@@8'{$ELSE}'zend_compare_symbol_tables'{$ENDIF});

  // -- zend_compare_arrays
  zend_compare_arrays := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_compare_arrays@@8'{$ELSE}'zend_compare_arrays'{$ENDIF});

  // -- zend_compare_objects
  zend_compare_objects := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_compare_objects@@8'{$ELSE}'zend_compare_objects'{$ENDIF});

  // -- zend_atoi
  zend_atoi := GetProcAddress(PHPLib, {$IFDEF PHP7}'zend_atoi@@8'{$ELSE}'zend_atoi'{$ENDIF});

  // -- get_active_function_name
  get_active_function_name := GetProcAddress(PHPLib, 'get_active_function_name');

  // -- zend_get_executed_filename
  zend_get_executed_filename := GetProcAddress(PHPLib, 'zend_get_executed_filename');

  // -- zend_get_executed_lineno
  zend_get_executed_lineno := GetProcAddress(PHPLib, 'zend_get_executed_lineno');

  // -- zend_set_timeout
  zend_set_timeout := GetProcAddress(PHPLib, 'zend_set_timeout');

  // -- zend_unset_timeout
  zend_unset_timeout := GetProcAddress(PHPLib, 'zend_unset_timeout');

  // -- zend_timeout
  zend_timeout := GetProcAddress(PHPLib, 'zend_timeout');

  // -- zend_highlight
  zend_highlight := GetProcAddress(PHPLib, 'zend_highlight');

  // -- zend_strip
  zend_strip := GetProcAddress(PHPLib, 'zend_strip');

  // -- highlight_file
  highlight_file := GetProcAddress(PHPLib, 'highlight_file');

  // -- highlight_string
  highlight_string := GetProcAddress(PHPLib, 'highlight_string');

  // -- zend_html_putc
  zend_html_putc := GetProcAddress(PHPLib, 'zend_html_putc');

  // -- zend_html_puts
  zend_html_puts := GetProcAddress(PHPLib, 'zend_html_puts');
  {$IFDEF PHP7}
  // -- zend_parse_parameters_throw
  zend_parse_parameters_throw := GetProcAddress(PHPLib, 'zend_parse_parameters_throw');
  ZvalGetArgs  := GetProcAddress(PHPLib, 'zend_get_parameters_ex');
  _zend_get_parameters_array_ex := GetProcAddress(PHPLib, '_zend_get_parameters_array_ex');
  {$ELSE}
  // -- zend_indent
  zend_indent := GetProcAddress(PHPLib, 'zend_indent');
  {$ENDIF}
  // -- _zend_get_parameters_array_ex
  _zend_get_parameters_array_ex := GetProcAddress(PHPLib, {$IFDEF PHP7}{$ELSE}{$ENDIF}'_zend_get_parameters_array_ex');

  // -- zend_ini_refresh_caches
  zend_ini_refresh_caches := GetProcAddress(PHPLib, 'zend_ini_refresh_caches');

  // -- zend_alter_ini_entry
  zend_alter_ini_entry := GetProcAddress(PHPLib, 'zend_alter_ini_entry');
  zend_alter_ini_entry_ex:= GetProcAddress(PHPLib, 'zend_alter_ini_entry_ex');
  // -- zend_restore_ini_entry
  zend_restore_ini_entry := GetProcAddress(PHPLib, 'zend_restore_ini_entry');

  // -- zend_ini_long
  zend_ini_long := GetProcAddress(PHPLib, 'zend_ini_long');

  // -- zend_ini_double
  zend_ini_double := GetProcAddress(PHPLib, 'zend_ini_double');

  // -- zend_ini_string
  zend_ini_string := GetProcAddress(PHPLib, 'zend_ini_string');

  // -- compile_string
  compile_string := GetProcAddress(PHPLib, 'compile_string');

  // -- execute
  execute := GetProcAddress(PHPLib, {$IFDEF PHP550}'zend_execute'{$ELSE}'execute'{$ENDIF});

  // -- zend_wrong_param_count
  zend_wrong_param_count := GetProcAddress(PHPLib, 'zend_wrong_param_count');

  // -- zend_hash_quick_add_or_update
  _zend_hash_quick_add_or_update := GetProcAddress(PHPLib, '_zend_hash_quick_add_or_update');

  // -- add_property_long_ex
  add_property_long_ex := GetProcAddress(PHPLib, 'add_property_long_ex');

  // -- add_property_null_ex
  add_property_null_ex := GetProcAddress(PHPLib, 'add_property_null_ex');

  // -- add_property_bool_ex
  add_property_bool_ex := GetProcAddress(PHPLib, 'add_property_bool_ex');

  // -- add_property_resource_ex
  add_property_resource_ex := GetProcAddress(PHPLib, 'add_property_resource_ex');

  // -- add_property_double_ex
  add_property_double_ex := GetProcAddress(PHPLib, 'add_property_double_ex');

  // -- add_property_string_ex
  add_property_string_ex := GetProcAddress(PHPLib, 'add_property_string_ex');

  // -- add_property_stringl_ex
  add_property_stringl_ex := GetProcAddress(PHPLib, 'add_property_stringl_ex');

  // -- add_property_zval_ex
  add_property_zval_ex := GetProcAddress(PHPLib, 'add_property_zval_ex');

  call_user_function := GetProcAddress(PHPLib, {$IFDEF P_CUT}'__call_function'{$ELSE}'call_user_function'{$ENDIF});
  {$IFNDEF P_CUT}
  call_user_function_ex := GetProcAddress(PHPLib, 'call_user_function_ex');
  {$ENDIF}
  // -- add_assoc_long_ex
  add_assoc_long_ex := GetProcAddress(PHPLib, 'add_assoc_long_ex');

  // -- add_assoc_null_ex
  add_assoc_null_ex := GetProcAddress(PHPLib, 'add_assoc_null_ex');

  // -- add_assoc_bool_ex
  add_assoc_bool_ex := GetProcAddress(PHPLib, 'add_assoc_bool_ex');

  // -- add_assoc_resource_ex
  add_assoc_resource_ex := GetProcAddress(PHPLib, 'add_assoc_resource_ex');

  // -- add_assoc_double_ex
  add_assoc_double_ex := GetProcAddress(PHPLib, 'add_assoc_double_ex');

  // -- add_assoc_string_ex
  add_assoc_string_ex := GetProcAddress(PHPLib, 'add_assoc_string_ex');

  // -- add_assoc_stringl_ex
  add_assoc_stringl_ex := GetProcAddress(PHPLib, 'add_assoc_stringl_ex');

  // -- add_assoc_zval_ex
  add_assoc_zval_ex := GetProcAddress(PHPLib, 'add_assoc_zval_ex');

  // -- add_index_long
  add_index_long := GetProcAddress(PHPLib, 'add_index_long');

  // -- add_index_null
  add_index_null := GetProcAddress(PHPLib, 'add_index_null');

  // -- add_index_bool
  add_index_bool := GetProcAddress(PHPLib, 'add_index_bool');

  // -- add_index_resource
  add_index_resource := GetProcAddress(PHPLib, 'add_index_resource');

  // -- add_index_double
  add_index_double := GetProcAddress(PHPLib, 'add_index_double');

  // -- add_index_string
  add_index_string := GetProcAddress(PHPLib, 'add_index_string');

  // -- add_index_stringl
  add_index_stringl := GetProcAddress(PHPLib, 'add_index_stringl');

  // -- add_index_zval
  add_index_zval := GetProcAddress(PHPLib, 'add_index_zval');

  // -- add_next_index_long
  add_next_index_long := GetProcAddress(PHPLib, 'add_next_index_long');

  // -- add_next_index_null
  add_next_index_null := GetProcAddress(PHPLib, 'add_next_index_null');

  // -- add_next_index_bool
  add_next_index_bool := GetProcAddress(PHPLib, 'add_next_index_bool');

  // -- add_next_index_resource
  add_next_index_resource := GetProcAddress(PHPLib, 'add_next_index_resource');

  // -- add_next_index_double
  add_next_index_double := GetProcAddress(PHPLib, 'add_next_index_double');

  // -- add_next_index_string
  add_next_index_string := GetProcAddress(PHPLib, 'add_next_index_string');

  // -- add_next_index_stringl
  add_next_index_stringl := GetProcAddress(PHPLib, 'add_next_index_stringl');

  // -- add_next_index_zval
  add_next_index_zval := GetProcAddress(PHPLib, 'add_next_index_zval');

  // -- add_get_assoc_string_ex
  add_get_assoc_string_ex := GetProcAddress(PHPLib, 'add_get_assoc_string_ex');

  // -- add_get_assoc_stringl_ex
  add_get_assoc_stringl_ex := GetProcAddress(PHPLib, 'add_get_assoc_stringl_ex');

  // -- add_get_index_long
  add_get_index_long := GetProcAddress(PHPLib, 'add_get_index_long');

  // -- add_get_index_double
  add_get_index_double := GetProcAddress(PHPLib, 'add_get_index_double');

  // -- add_get_index_string
  add_get_index_string := GetProcAddress(PHPLib, 'add_get_index_string');

  // -- add_get_index_stringl
  add_get_index_stringl := GetProcAddress(PHPLib, 'add_get_index_stringl');

  // -- _array_init
  _array_init := GetProcAddress(PHPLib, '_array_init');

  // -- _object_init
  _object_init := GetProcAddress(PHPLib, '_object_init');

  // -- _object_init_ex
  _object_init_ex := GetProcAddress(PHPLib, '_object_init_ex');

  // -- _object_and_properties_init
  _object_and_properties_init := GetProcAddress(PHPLib, '_object_and_properties_init');

  // -- zend_register_internal_class
  zend_register_internal_class := GetProcAddress(PHPLib, 'zend_register_internal_class');

  // -- zend_register_internal_class_ex
  zend_register_internal_class_ex := GetProcAddress(PHPLib, 'zend_register_internal_class_ex');

  // -- zend_startup_module
  zend_startup_module  := GetProcAddress(PHPLib, 'zend_startup_module');

  // -- zend_startup_module_ex
  zend_startup_module_ex  := GetProcAddress(PHPLib, 'zend_startup_module_ex');

  // -- zend_register_module_ex
  zend_register_module_ex := GetProcAddress(PHPLib, 'zend_register_module_ex');

  // --  zend_register_internal_module
  zend_register_internal_module := GetProcAddress(PHPLib, 'zend_register_internal_module');

  // -- zend_startup_modules
  zend_startup_modules := GetProcAddress(PHPLib, 'zend_startup_modules');

  // -- zend_collect_module_handlers
  zend_collect_module_handlers := GetProcAddress(PHPLib, 'zend_collect_module_handlers');

  // -- get_zend_version
  get_zend_version := GetProcAddress(PHPLib, 'get_zend_version');

  // -- zend_make_printable_zval
  zend_make_printable_zval := GetProcAddress(PHPLib, 'zend_make_printable_zval');

  // -- zend_print_zval
  zend_print_zval := GetProcAddress(PHPLib, 'zend_print_zval');

  // -- zend_print_zval_r
  zend_print_zval_r := GetProcAddress(PHPLib, 'zend_print_zval_r');

  // -- zend_output_debug_string
  zend_output_debug_string := GetProcAddress(PHPLib, 'zend_output_debug_string');

  // -- zend_get_parameters
  ZendGetParameters := GetProcAddress(PHPLib, 'zend_get_parameters');

  // - zend_get_parameters_ex (native call)
  zend_get_params_ex := GetProcAddress(PHPLib, 'zend_get_parameters_ex');
  {$IFDEF PHP5}
  zend_destroy_file_handle := GetProcAddress(PHPLib, 'zend_destroy_file_handle');
  {$ENDIF}

 {$IFNDEF QUIET_LOAD}
 CheckZendErrors;
 {$ENDIF}

  WriteFuncPtr := GetProcAddress(PHPLib, 'zend_write');
  if Assigned(WriteFuncPtr) then
    @zend_write := pointer(WriteFuncPtr^);

  Result := true;
end;

procedure ZEND_PUTS(str: zend_pchar);
begin
  if assigned(str) then
    zend_write(str, strlen(str));
end;

procedure convert_to_string(op: pzval);
begin
  _convert_to_string(op, nil, 0);
end;

procedure INIT_CLASS_ENTRY(var class_container: Tzend_class_entry; class_name: zend_pchar; functions: {$IFDEF PHP7}HashTable{$ELSE}pointer{$ENDIF});
begin

  if class_name = nil then
   Exit;

  ZeroMemory(@class_container, sizeof(Tzend_class_entry));

  {$IFNDEF COMPILER_VC9}
  class_container.name := strdup(class_name);
  {$ELSE}
  {$IFDEF PHP7}
      class_container.name.val := estrdup(class_name);
    {$ELSE}
      class_container.name := estrdup(class_name);
    {$ENDIF}
  {$ENDIF}
  {$IFDEF PHP7}
   class_container.name.len := strlen(class_name);
   class_container.function_table := functions;
  {$ELSE}
  class_container.name_length := strlen(class_name);
  class_container.builtin_functions := functions;
  {$ENDIF}
  {$IFDEF PHP4}
  class_container.handle_function_call := nil;
  class_container.handle_property_get := nil;
  class_container.handle_property_set := nil;
  {$ENDIF}
end;
{$IFNDEF PHP7}
function ZEND_FAST_ALLOC: pzval;
begin
  Result := emalloc(sizeof(zval));
end;

function ALLOC_ZVAL: pzval;
begin
  Result := emalloc(sizeof(zval));
end;

procedure ALLOC_ZVAL(out Result: pzval);
begin
  Result := emalloc(sizeof(zval));
end;
{$ENDIF}
procedure INIT_PZVAL(p: pzval);
begin
  {$IFDEF PHP7}
  p^.value.counted.gc.refcount := 1;
  {$ELSE}
  p^.refcount := 1;
  p^.is_ref := 0;
  {$ENDIF}
end;

procedure LOCK_ZVAL(p: pzval);
begin
  Inc({$IFDEF PHP7}
  p^.value.counted.gc.refcount{$ELSE}p^.refcount{$ENDIF});
end;

procedure UNLOCK_ZVAL(p: pzval);
begin
  if {$IFDEF PHP7}
  p^.value.counted.gc.refcount{$ELSE}p^.refcount{$ENDIF} > 0 then
    Dec({$IFDEF PHP7}
  p^.value.counted.gc.refcount{$ELSE}p^.refcount{$ENDIF});
end;

function MAKE_STD_ZVAL: pzval;
begin
  {$IFNDEF PHP7}
    Result := ALLOC_ZVAL;
  {$ENDIF}
  INIT_PZVAL(Result);
end;

function zend_get_parameters_ex(number: integer; var Params: pzval_array): integer;
var
  i  : integer;
begin

  if number = 0 then
  begin
    Result := SUCCESS;
    Exit;
  end;
  {$IFDEF PHP7}
  Params.value.arr.nNumOfElements := number;
  for i := 0 to number - 1 do
    zend_hash_index_add_empty_element(Params.value.arr, i);
  Result := ZvalGetArgs(number, @Params);
  {$ELSE}
   SetLength(Params, number);
  for i := 0 to number - 1 do
    New(Params[i]);
  Result := zend_get_parameters(number, number, Params);
  {$ENDIF}
end;

function zend_get_parameters_my(number: integer; var Params: pzval_array; TSRMLS_DC: Pointer): integer;
var
  i  : integer;

  p:
  {$IFDEF PHP7}
  pzval
  {$ELSE}
  pppzval
  {$ENDIF};
begin
  if number = 0 then
  begin
    Result := SUCCESS;
    Exit;
  end;
  {$IFDEF PHP7}
  Params.value.arr.nNumOfElements := number;
  for i := 0 to number - 1 do
    zend_hash_index_add_empty_element(Params.value.arr, i);

  p := emalloc(number * sizeOf(zval));
  Result := _zend_get_parameters_array_ex(number, p);

  for i := 0 to number - 1 do
  begin
    _zend_hash_update_ind(Params.value.arr, i, p, '', 0);
     if i <> number then
         inc(integer(p), sizeof(zval));
  end;

  efree(p);
    _zend_get_parameters_array_ex(number, p);
  {$ELSE}
  SetLength(Params, number);
  for i := 0 to number - 1 do
    New(Params[i]);

  p := emalloc(number * sizeOf(ppzval));
  Result := _zend_get_parameters_array_ex(number, p, TSRMLS_DC);

  for i := 0 to number - 1 do
  begin
     Params[i]^ :=  p^^;
     if i <> number then
         inc(integer(p^), sizeof(ppzval));
  end;

  efree(p);
  {$ENDIF}
end;
{$IFNDEF PHP7}
function zend_get_parameters(ht: integer; param_count: integer; Params: array of ppzval): integer; assembler; register;
asm
  push  esi
  mov   esi, ecx
  mov   ecx, [ebp+8]
  cmp   ecx, 0
  je @first
  @toploop:
  {$IFDEF VERSION6}
  push  [esi][ecx * 4]
  {$ELSE}
  push  dword [esi][ecx * 4]
  {$ENDIF}
  loop   @toploop
  @first:
  push    dword [esi]
  push    edx
  push    eax
  call    ZendGetParameters
  mov   ecx, [ebp+8]
  add     ecx, 3
  @toploop2:
  pop     edx
  loop   @toploop2
  pop     esi
end;
{$ENDIF}
procedure dispose_pzval_array(Params: pzval_array);
var
  i : integer;
begin
  {$IFDEF PHP7}
  if Params.value.arr.nNumOfElements>0 then
    for i := 0 to Params.value.arr.nNumOfElements-1 do
      Freemem(zend_hash_index_findZval(Params,i));
  {$ELSE}
  if Length(Params)>0 then
  for i := 0 to High(Params) do
    FreeMem(Params[i]);
  {$ENDIF}
  Params := nil;
end;

{ EPHP4DelphiException }

constructor EPHP4DelphiException.Create(const Msg: zend_ustr);
begin
  inherited Create('Unable to link '+ Msg+' function');
end;

{procedure zenderror(Error : zend_pchar);
begin
  zend_error(E_PARSE, Error);
end;}


{$IFNDEF QUIET_LOAD}
procedure CheckZendErrors;
begin
  if @zend_disable_function = nil then raise EPHP4DelphiException.Create('zend_disable_function');
  if @zend_disable_class = nil then raise EPHP4DelphiException.Create('zend_disable_class');
  if @zend_register_list_destructors_ex = nil then raise EPHP4DelphiException.Create('zend_register_list_destructors_ex');
  if @zend_register_resource = nil then raise EPHP4DelphiException.Create('zend_register_resource');
  if @zend_fetch_resource =    nil then raise EPHP4DelphiException.Create('zend_fetch_resource');
  if @zend_list_insert =       nil then raise EPHP4DelphiException.Create('zend_list_insert');
  {$IFNDEF PHP7}
  if @_zend_list_addref =      nil then raise EPHP4DelphiException.Create('zend_list_addref');
  if @_zend_list_delete =      nil then raise EPHP4DelphiException.Create('zend_list_delete');
  if @_zend_list_find =        nil then raise EPHP4DelphiException.Create('_zend_list_find');
  {$ENDIF}
  if @zend_rsrc_list_get_rsrc_type =  nil then raise EPHP4DelphiException.Create('zend_rsrc_list_get_rsrc_type');
  if @zend_fetch_list_dtor_id =       nil then raise EPHP4DelphiException.Create('zend_fetch_list_dtor_id');
  if @zend_get_compiled_filename = nil then raise EPHP4DelphiException.Create('zend_get_compiled_filename');
  if @zend_get_compiled_lineno = nil then raise EPHP4DelphiException.Create('zend_get_compiled_lineno');
  if @tsrm_startup = nil then raise EPHP4DelphiException.Create('tsrm_startup');
  if @ts_allocate_id = nil then raise EPHP4DelphiException.Create('ts_allocate_id');
  if @ts_free_id = nil then raise EPHP4DelphiException.Create('ts_free_id');
  if @zend_strndup = nil then raise EPHP4DelphiException.Create('zend_strndup');

  if @_emalloc = nil then raise EPHP4DelphiException.Create('_emalloc');
  if @_efree = nil then raise EPHP4DelphiException.Create('_efree');
  if @_ecalloc = nil then raise EPHP4DelphiException.Create('_ecalloc');
  if @_erealloc = nil then raise EPHP4DelphiException.Create('_erealloc');
  if @_estrdup = nil then raise EPHP4DelphiException.Create('_estrdup');
  if @_estrndup = nil then raise EPHP4DelphiException.Create('_estrndup');
  if @zend_set_memory_limit = nil then raise EPHP4DelphiException.Create('zend_set_memory_limit');
  if @start_memory_manager = nil then raise EPHP4DelphiException.Create('start_memory_manager');
  if @shutdown_memory_manager = nil then raise EPHP4DelphiException.Create('shutdown_memory_manager');
  {$IFDEF PHP4}
  if @zend_hash_init = nil then raise EPHP4DelphiException.Create('zend_hash_init');
  if @zend_hash_init_ex = nil then raise EPHP4DelphiException.Create('zend_hash_init_ex');
  if @zend_hash_add_or_update = nil then raise EPHP4DelphiException.Create('zend_hash_add_or_update');
  if @zend_hash_quick_add_or_update = nil then raise EPHP4DelphiException.Create('zend_hash_quick_add_or_update');
  if @zend_hash_index_update_or_next_insert = nil then raise EPHP4DelphiException.Create('zend_hash_index_update_or_next_insert');
  if @zend_hash_merge = nil then raise EPHP4DelphiException.Create('zend_hash_merge');
  {$ENDIF}

  {$IFDEF PHP5}
  if @_zend_hash_add_or_update = nil then raise EPHP4DelphiException.Create('_zend_hash_add_or_update');
  {$ENDIF}

  if @zend_hash_destroy = nil then raise EPHP4DelphiException.Create('zend_hash_destroy');
  if @zend_hash_clean = nil then raise EPHP4DelphiException.Create('zend_hash_clean');
  if @zend_hash_add_empty_element = nil then raise EPHP4DelphiException.Create('zend_hash_add_empty_element');
  if @zend_hash_graceful_destroy = nil then raise EPHP4DelphiException.Create('zend_hash_graceful_destroy');
  if @zend_hash_graceful_reverse_destroy = nil then raise EPHP4DelphiException.Create('zend_hash_graceful_reverse_destroy');
  if @zend_hash_apply = nil then raise EPHP4DelphiException.Create('zend_hash_apply');
  if @zend_hash_apply_with_argument = nil then raise EPHP4DelphiException.Create('zend_hash_apply_with_argument');
  if @zend_hash_reverse_apply = nil then raise EPHP4DelphiException.Create('zend_hash_reverse_apply');
  if @zend_hash_del_key_or_index = nil then raise EPHP4DelphiException.Create('zend_hash_del_key_or_index');
  if @zend_get_hash_value = nil then raise EPHP4DelphiException.Create('zend_get_hash_value');
  if @zend_hash_find = nil then raise EPHP4DelphiException.Create('zend_hash_find');
  if @zend_hash_quick_find = nil then raise EPHP4DelphiException.Create('zend_hash_quick_find');
  if @zend_hash_index_find = nil then raise EPHP4DelphiException.Create('zend_hash_index_find');
  if @zend_hash_exists = nil then raise EPHP4DelphiException.Create('zend_hash_exists');
  if @zend_hash_index_exists = nil then raise EPHP4DelphiException.Create('zend_hash_index_exists');
  {$IFDEF PHP7}
  if @_zend_hash_add = nil then raise EPHP4DelphiException.Create('_zend_hash_add');
  if @_zend_hash_add_or_update = nil then raise EPHP4DelphiException.Create('_zend_hash_add_or_update');

  if @zend_hash_index_findZval = nil then raise EPHP4DelphiException.Create('zend_hash_index_findZval');
  if @zend_symtable_findTest = nil then raise EPHP4DelphiException.Create('zend_symtable_findTest');
  if @zend_hash_index_existsZval = nil then raise EPHP4DelphiException.Create('zend_hash_index_existsZval');

  {$ENDIF}
  {$IFNDEF PHP7}
  if @zend_hash_next_free_element = nil then raise EPHP4DelphiException.Create('zend_hash_next_free_element');
  {$ENDIF}
  if @zend_hash_move_forward_ex = nil then raise EPHP4DelphiException.Create('zend_hash_move_forward_ex');
  if @zend_hash_move_backwards_ex = nil then raise EPHP4DelphiException.Create('zend_hash_move_backwards_ex');
  if @zend_hash_get_current_key_ex = nil then raise EPHP4DelphiException.Create('zend_hash_get_current_key_ex');
  if @zend_hash_get_current_key_type_ex = nil then raise EPHP4DelphiException.Create('zend_hash_get_current_key_type_ex');
  if @zend_hash_get_current_data_ex = nil then raise EPHP4DelphiException.Create('zend_hash_get_current_data_ex');
  if @zend_hash_internal_pointer_reset_ex = nil then raise EPHP4DelphiException.Create('zend_hash_internal_pointer_reset_ex');
  if @zend_hash_internal_pointer_end_ex = nil then raise EPHP4DelphiException.Create('zend_hash_internal_pointer_end_ex');
  if @zend_hash_copy = nil then raise EPHP4DelphiException.Create('zend_hash_copy');
  if @zend_hash_sort = nil then raise EPHP4DelphiException.Create('zend_hash_sort');
  if @zend_hash_compare = nil then raise EPHP4DelphiException.Create('zend_hash_compare');
  if @zend_hash_minmax = nil then raise EPHP4DelphiException.Create('zend_hash_minmax');
  if @zend_hash_num_elements = nil then raise EPHP4DelphiException.Create('zend_hash_num_elements');
  if @zend_hash_rehash = nil then raise EPHP4DelphiException.Create('zend_hash_rehash');
  if @zend_hash_func = nil then raise EPHP4DelphiException.Create('zend_hash_func');
  if @zend_get_constant = nil then raise EPHP4DelphiException.Create('zend_get_constant');
  if @zend_register_long_constant = nil then raise EPHP4DelphiException.Create('zend_register_long_constant');
  if @zend_register_double_constant = nil then raise EPHP4DelphiException.Create('zend_register_double_constant');
  if @zend_register_string_constant = nil then raise EPHP4DelphiException.Create('zend_register_string_constant');
  if @zend_register_stringl_constant = nil then raise EPHP4DelphiException.Create('zend_register_stringl_constant');
  if @zend_register_constant = nil then raise EPHP4DelphiException.Create('zend_register_constant');
  if @tsrm_shutdown = nil then raise EPHP4DelphiException.Create('tsrm_shutdown');
  if @ts_resource_ex = nil then raise EPHP4DelphiException.Create('ts_resource_ex');
  if @ts_free_thread = nil then raise EPHP4DelphiException.Create('ts_free_thread');
  if @zend_error = nil then raise EPHP4DelphiException.Create('zend_error');
  if @zend_error_cb = nil then raise EPHP4DelphiException.Create('zend_error_cb');
  if @zend_eval_string = nil then raise EPHP4DelphiException.Create('zend_eval_string');
  if @zend_make_compiled_string_description = nil then raise EPHP4DelphiException.Create('zend_make_compiled_string_description');

  {$IFDEF PHP4}
  if @_zval_dtor = nil then raise EPHP4DelphiException.Create('_zval_dtor');
  if @_zval_copy_ctor = nil then raise EPHP4DelphiException.Create('_zval_copy_ctor');
  {$ELSE}
  if @_zval_dtor_func = nil then raise EPHP4DelphiException.Create('_zval_dtor_func');
  if @_zval_copy_ctor_func = nil then raise EPHP4DelphiException.Create('_zval_copy_ctor_func');
 {$ENDIF}

  if @zend_print_variable = nil then raise EPHP4DelphiException.Create('zend_print_variable');
  if @zend_stack_init = nil then raise EPHP4DelphiException.Create('zend_stack_init');
  if @zend_stack_push = nil then raise EPHP4DelphiException.Create('zend_stack_push');
  if @zend_stack_top = nil then raise EPHP4DelphiException.Create('zend_stack_top');
  if @zend_stack_del_top = nil then raise EPHP4DelphiException.Create('zend_stack_del_top');
  if @zend_stack_int_top = nil then raise EPHP4DelphiException.Create('zend_stack_int_top');
  if @zend_stack_is_empty = nil then raise EPHP4DelphiException.Create('zend_stack_is_empty');
  if @zend_stack_destroy = nil then raise EPHP4DelphiException.Create('zend_stack_destroy');
  if @zend_stack_base = nil then raise EPHP4DelphiException.Create('zend_stack_base');
  if @zend_stack_count = nil then raise EPHP4DelphiException.Create('zend_stack_count');
  if @zend_stack_apply = nil then raise EPHP4DelphiException.Create('zend_stack_apply');
  if @zend_stack_apply_with_argument = nil then raise EPHP4DelphiException.Create('zend_stack_apply_with_argument');
  if @_convert_to_string = nil then raise EPHP4DelphiException.Create('_convert_to_string');
  if @add_function = nil then raise EPHP4DelphiException.Create('add_function');
  if @sub_function = nil then raise EPHP4DelphiException.Create('sub_function');
  if @mul_function = nil then raise EPHP4DelphiException.Create('mul_function');
  if @div_function = nil then raise EPHP4DelphiException.Create('div_function');
  if @mod_function = nil then raise EPHP4DelphiException.Create('mod_function');
  if @boolean_xor_function = nil then raise EPHP4DelphiException.Create('boolean_xor_function');
  if @boolean_not_function = nil then raise EPHP4DelphiException.Create('boolean_not_function');
  if @bitwise_not_function = nil then raise EPHP4DelphiException.Create('bitwise_not_function');
  if @bitwise_or_function = nil then raise EPHP4DelphiException.Create('bitwise_or_function');
  if @bitwise_and_function = nil then raise EPHP4DelphiException.Create('bitwise_and_function');
  if @bitwise_xor_function = nil then raise EPHP4DelphiException.Create('bitwise_xor_function');
  if @shift_left_function = nil then raise EPHP4DelphiException.Create('shift_left_function');
  if @shift_right_function = nil then raise EPHP4DelphiException.Create('shift_right_function');
  if @concat_function = nil then raise EPHP4DelphiException.Create('concat_function');
  if @is_equal_function = nil then raise EPHP4DelphiException.Create('is_equal_function');
  if @is_identical_function = nil then raise EPHP4DelphiException.Create('is_identical_function');
  if @is_not_identical_function = nil then raise EPHP4DelphiException.Create('is_not_identical_function');
  if @is_not_equal_function = nil then raise EPHP4DelphiException.Create('is_not_equal_function');
  if @is_smaller_function = nil then raise EPHP4DelphiException.Create('is_smaller_function');
  if @is_smaller_or_equal_function = nil then raise EPHP4DelphiException.Create('is_smaller_or_equal_function');
  if @increment_function = nil then raise EPHP4DelphiException.Create('increment_function');
  if @decrement_function = nil then raise EPHP4DelphiException.Create('decrement_function');
  if @convert_scalar_to_number = nil then raise EPHP4DelphiException.Create('convert_scalar_to_number');
  if @convert_to_long = nil then raise EPHP4DelphiException.Create('convert_to_long');
  if @convert_to_double = nil then raise EPHP4DelphiException.Create('convert_to_double');
  if @convert_to_long_base = nil then raise EPHP4DelphiException.Create('convert_to_long_base');
  if @convert_to_null = nil then raise EPHP4DelphiException.Create('convert_to_null');
  if @convert_to_boolean = nil then raise EPHP4DelphiException.Create('convert_to_boolean');
  if @convert_to_array = nil then raise EPHP4DelphiException.Create('convert_to_array');
  if @convert_to_object = nil then raise EPHP4DelphiException.Create('convert_to_object');
  if @add_char_to_string = nil then raise EPHP4DelphiException.Create('add_char_to_string');
  if @add_string_to_string = nil then raise EPHP4DelphiException.Create('add_string_to_string');
  if @zend_string_to_double = nil then raise EPHP4DelphiException.Create('zend_string_to_double');
  if @zval_is_true = nil then raise EPHP4DelphiException.Create('zval_is_true');
  if @compare_function = nil then raise EPHP4DelphiException.Create('compare_function');
  if @numeric_compare_function = nil then raise EPHP4DelphiException.Create('numeric_compare_function');
  if @string_compare_function = nil then raise EPHP4DelphiException.Create('string_compare_function');
  if @zend_str_tolower = nil then raise EPHP4DelphiException.Create('zend_str_tolower');
  if @zend_binary_zval_strcmp = nil then raise EPHP4DelphiException.Create('zend_binary_zval_strcmp');
  if @zend_binary_zval_strncmp = nil then raise EPHP4DelphiException.Create('zend_binary_zval_strncmp');
  if @zend_binary_zval_strcasecmp = nil then raise EPHP4DelphiException.Create('zend_binary_zval_strcasecmp');
  if @zend_binary_zval_strncasecmp = nil then raise EPHP4DelphiException.Create('zend_binary_zval_strncasecmp');
  if @zend_binary_strcmp = nil then raise EPHP4DelphiException.Create('zend_binary_strcmp');
  if @zend_binary_strncmp = nil then raise EPHP4DelphiException.Create('zend_binary_strncmp');
  if @zend_binary_strcasecmp = nil then raise EPHP4DelphiException.Create('zend_binary_strcasecmp');
  if @zend_binary_strncasecmp = nil then raise EPHP4DelphiException.Create('zend_binary_strncasecmp');
  if @zendi_smart_strcmp = nil then raise EPHP4DelphiException.Create('zendi_smart_strcmp');
  if @zend_compare_symbol_tables = nil then raise EPHP4DelphiException.Create('zend_compare_symbol_tables');
  if @zend_compare_arrays = nil then raise EPHP4DelphiException.Create('zend_compare_arrays');
  if @zend_compare_objects = nil then raise EPHP4DelphiException.Create('zend_compare_objects');
  if @zend_atoi = nil then raise EPHP4DelphiException.Create('zend_atoi');
  if @get_active_function_name = nil then raise EPHP4DelphiException.Create('get_active_function_name');
  if @zend_get_executed_filename = nil then raise EPHP4DelphiException.Create('zend_get_executed_filename');
  if @zend_set_timeout = nil then raise EPHP4DelphiException.Create('zend_set_timeout');
  if @zend_unset_timeout = nil then raise EPHP4DelphiException.Create('zend_unset_timeout');
  if @zend_timeout = nil then raise EPHP4DelphiException.Create('zend_timeout');
  if @zend_highlight = nil then raise EPHP4DelphiException.Create('zend_highlight');
  if @zend_strip = nil then raise EPHP4DelphiException.Create('zend_strip');
  if @highlight_file = nil then raise EPHP4DelphiException.Create('highlight_file');
  if @highlight_string = nil then raise EPHP4DelphiException.Create('highlight_string');
  if @zend_html_putc = nil then raise EPHP4DelphiException.Create('zend_html_putc');
  if @zend_html_puts = nil then raise EPHP4DelphiException.Create('zend_html_puts');
  {$IFDEF PHP7}
  if @zend_parse_parameters_throw = nil then EPHP4DelphiException.Create('zend_parse_parameters_throw');
  if @ZvalGetArgs = nil then EPHP4DelphiException.Create('ZvalGetArgs');
  if @_zend_get_parameters_array_ex = nil then EPHP4DelphiException.Create('_zend_get_parameters_array_ex');
  {$ELSE}
  if @zend_indent = nil then raise EPHP4DelphiException.Create('zend_indent');
  {$ENDIF}
  if @_zend_get_parameters_array_ex = nil then raise EPHP4DelphiException.Create('_zend_get_parameters_array_ex');
  if @zend_ini_refresh_caches = nil then raise EPHP4DelphiException.Create('zend_ini_refresh_caches');
  if @zend_alter_ini_entry = nil then raise EPHP4DelphiException.Create('zend_alter_ini_entry');
  if @zend_restore_ini_entry = nil then raise EPHP4DelphiException.Create('zend_restore_ini_entry');
  if @zend_ini_long = nil then raise EPHP4DelphiException.Create('zend_ini_long');
  if @zend_ini_double = nil then raise EPHP4DelphiException.Create('zend_ini_double');
  if @zend_ini_string = nil then raise EPHP4DelphiException.Create('zend_ini_string');
  if @compile_string = nil then raise EPHP4DelphiException.Create('compile_string');
  if @execute = nil then raise EPHP4DelphiException.Create('execute');
  if @zend_wrong_param_count = nil then raise EPHP4DelphiException.Create('zend_wrong_param_count');
  if @add_property_long_ex = nil then raise EPHP4DelphiException.Create('add_property_long_ex');
  if @add_property_null_ex = nil then raise EPHP4DelphiException.Create('add_property_null_ex');
  if @add_property_bool_ex = nil then raise EPHP4DelphiException.Create('add_property_bool_ex');
  if @add_property_resource_ex = nil then raise EPHP4DelphiException.Create('add_property_resource_ex');
  if @add_property_double_ex = nil then raise EPHP4DelphiException.Create('add_property_double_ex');
  if @add_property_string_ex = nil then raise EPHP4DelphiException.Create('add_property_string_ex');
  if @add_property_stringl_ex = nil then raise EPHP4DelphiException.Create('add_property_stringl_ex');
  if @add_property_zval_ex = nil then raise EPHP4DelphiException.Create('add_property_zval_ex');
  if @call_user_function = nil then raise EPHP4DelphiException.Create('call_user_function');
  {$IFNDEF P_CUT}
  if @call_user_function_ex = nil then raise EPHP4DelphiException.Create('call_user_function_ex');
  {$ENDIF}
  if @add_assoc_long_ex = nil then raise EPHP4DelphiException.Create('add_assoc_long_ex');
  if @add_assoc_null_ex = nil then raise EPHP4DelphiException.Create('add_assoc_null_ex');
  if @add_assoc_bool_ex = nil then raise EPHP4DelphiException.Create('add_assoc_bool_ex');
  if @add_assoc_resource_ex = nil then raise EPHP4DelphiException.Create('add_assoc_resource_ex');
  if @add_assoc_double_ex = nil then raise EPHP4DelphiException.Create('add_assoc_double_ex');
  if @add_assoc_string_ex = nil then raise EPHP4DelphiException.Create('add_assoc_string_ex');
  if @add_assoc_stringl_ex = nil then raise EPHP4DelphiException.Create('add_assoc_stringl_ex');
  if @add_assoc_zval_ex = nil then raise EPHP4DelphiException.Create('add_assoc_zval_ex');
  if @add_index_long = nil then raise EPHP4DelphiException.Create('add_index_long');
  if @add_index_null = nil then raise EPHP4DelphiException.Create('add_index_null');
  if @add_index_bool = nil then raise EPHP4DelphiException.Create('add_index_bool');
  if @add_index_resource = nil then raise EPHP4DelphiException.Create('add_index_resource');
  if @add_index_double = nil then raise EPHP4DelphiException.Create('add_index_double');
  if @add_index_string = nil then raise EPHP4DelphiException.Create('add_index_string');
  if @add_index_stringl = nil then raise EPHP4DelphiException.Create('add_index_stringl');
  if @add_index_zval = nil then raise EPHP4DelphiException.Create('add_index_zval');
  if @add_next_index_long = nil then raise EPHP4DelphiException.Create('add_next_index_long');
  if @add_next_index_null = nil then raise EPHP4DelphiException.Create('add_next_index_null');
  if @add_next_index_bool = nil then raise EPHP4DelphiException.Create('add_next_index_bool');
  if @add_next_index_resource = nil then raise EPHP4DelphiException.Create('add_next_index_resource');
  if @add_next_index_double = nil then raise EPHP4DelphiException.Create('add_next_index_double');
  if @add_next_index_string = nil then raise EPHP4DelphiException.Create('add_next_index_string');
  if @add_next_index_stringl = nil then raise EPHP4DelphiException.Create('add_next_index_stringl');
  if @add_next_index_zval = nil then raise EPHP4DelphiException.Create('add_next_index_zval');
  if @add_get_assoc_string_ex = nil then raise EPHP4DelphiException.Create('add_get_assoc_string_ex');
  if @add_get_assoc_stringl_ex = nil then raise EPHP4DelphiException.Create('add_get_assoc_stringl_ex');
  if @add_get_index_long = nil then raise EPHP4DelphiException.Create('add_get_index_long');
  if @add_get_index_double = nil then raise EPHP4DelphiException.Create('add_get_index_double');
  if @add_get_index_string = nil then raise EPHP4DelphiException.Create('add_get_index_string');
  if @add_get_index_stringl = nil then raise EPHP4DelphiException.Create('add_get_index_stringl');
  if @_array_init = nil then raise EPHP4DelphiException.Create('_array_init');
  if @_object_init = nil then raise EPHP4DelphiException.Create('_object_init');
  if @_object_init_ex = nil then raise EPHP4DelphiException.Create('_object_init_ex');
  if @_object_and_properties_init = nil then raise EPHP4DelphiException.Create('_object_and_properties_init');
  if @zend_register_internal_class = nil then raise EPHP4DelphiException.Create('zend_register_internal_class');
  if @zend_register_internal_class_ex = nil then raise EPHP4DelphiException.Create('zend_register_internal_class_ex');
  if @zend_startup_module = nil then raise EPHP4DelphiException.Create('zend_startup_module');
  if @zend_startup_module_ex = nil then raise EPHP4DelphiException.Create('zend_startup_module_ex');
  if @zend_register_module_ex = nil then raise EPHP4DelphiException.Create('zend_register_module_ex');
  if @zend_register_internal_module = nil then raise EPHP4DelphiException.Create('zend_register_internal_module');
  if @zend_startup_modules = nil then raise EPHP4DelphiException.Create('zend_startup_modules');
  if @zend_collect_module_handlers = nil then raise EPHP4DelphiException.Create('zend_collect_module_handlers');

  if @get_zend_version = nil then raise EPHP4DelphiException.Create('get_zend_version');
  if @zend_make_printable_zval = nil then raise EPHP4DelphiException.Create('zend_make_printable_zval');
  if @zend_print_zval = nil then raise EPHP4DelphiException.Create('zend_print_zval');
  if @zend_print_zval_r = nil then raise EPHP4DelphiException.Create('zend_print_zval_r');
  if @zend_output_debug_string = nil then raise EPHP4DelphiException.Create('zend_output_debug_string');
  if @ZendGetParameters = nil then raise EPHP4DelphiException.Create('zend_get_parameters');
end;
{$ENDIF}

function zend_hash_get_current_data(ht:  {$IFDEF PHP7} Pzend_array {$ELSE} PHashTable{$ENDIF}; pData: Pointer): Integer; cdecl;
begin
  result := zend_hash_get_current_data_ex(ht, pData, cardinal(nil));
end;

procedure zend_hash_internal_pointer_reset(ht:  {$IFDEF PHP7} Pzend_array {$ELSE} PHashTable{$ENDIF}); cdecl;
begin
  zend_hash_internal_pointer_reset_ex(ht, cardinal(nil));
end;

function ts_resource(id : integer) : pointer;
begin
  result := ts_resource_ex(id, nil);
end;

function tsrmls_fetch : pointer;
begin
  result := ts_resource_ex(0, nil);
end;

{$IFDEF PHP4}
function zval_copy_ctor(val : pzval) : integer;
begin
  result := _zval_copy_ctor(val, nil, 0);
end;
{$ENDIF}

function zend_unregister_functions(functions : {$IFDEF PHP7}P_zend_function_entry{$ELSE}pzend_function_entry{$ENDIF}; count : integer; function_table :  {$IFDEF PHP7} Pzend_array {$ELSE} PHashTable{$ENDIF}; TSRMLS_DC : pointer) : integer;
var
 i : integer;
 {$IFDEF PHP7}
 pzs: pzend_string;
 {$ENDIF}
 ptr : {$IFDEF PHP7}P_zend_function_entry{$ELSE}pzend_function_entry{$ENDIF};
begin
  Result := SUCCESS;
  i := 0;
  ptr := functions;
  if ptr = nil then
   Exit;
  while ptr.fname <> nil do
   begin
     if ( count <> -1 ) and (i >= count) then
      break;
      {$IFDEF PHP7}
      pzs^.len := strlen(ptr.fname);
      pzs^.val := estrdup(ptr.fname);
      zend_hash_del_key_or_index(function_table, pzs);
      {$ELSE}
      zend_hash_del_key_or_index(function_table, ptr.fname, strlen(ptr.fname) +1, 0, HASH_DEL_KEY);
      {$ENDIF}
      inc(ptr);
      inc(i);
   end;
end;

// registers all functions in *library_functions in the function hash

function zend_register_functions(functions : {$IFDEF PHP7}P_zend_function_entry{$ELSE}pzend_function_entry{$ENDIF};  function_table :  {$IFDEF PHP7} Pzend_array {$ELSE} PHashTable{$ENDIF}; _type: integer;  TSRMLS_DC : pointer) : integer;
var
 ptr : {$IFDEF PHP7}P_zend_function_entry{$ELSE}pzend_function_entry{$ENDIF};
 _function : {$IFDEF PHP7} _zend_function{$ELSE}zend_function{$ENDIF};
 internal_function :{$IFDEF PHP7}P_zend_internal_function{$ELSE}PzendInternalFunction{$ENDIF};
  count : integer;
  unload : integer;
  target_function_table :  {$IFDEF PHP7} Pzend_array {$ELSE} PHashTable{$ENDIF};
  error_type : integer;

begin
 Result := FAILURE;
 if functions = nil then
  Exit;
  ptr := functions;
  count := 0;
  unload := 0;
  if _type = MODULE_PERSISTENT then
   error_type := E_CORE_WARNING
    else
      error_type := E_WARNING;

  internal_function := @_function;
  target_function_table  := function_table;

  if (target_function_table = nil) then
    target_function_table :=  GetCompilerGlobals.function_table;


  internal_function._type := ZEND_INTERNAL_FUNCTION;

  while (ptr.fname <> nil) do
    begin
      internal_function.handler := ptr.handler;
      {$IFDEF PHP7}
      internal_function.function_name.val := ptr.fname;
      {$ELSE}
      internal_function.function_name := ptr.fname;
      {$ENDIF}
      if not Assigned(internal_function.handler) then begin
     	zend_error(error_type, 'Null function defined as active function');
	zend_unregister_functions(functions, count, target_function_table, TSRMLS_DC);
	Result := FAILURE;
        Exit;
       end;

     if (zend_hash_add_or_update(target_function_table, ptr.fname, strlen(ptr.fname)+1, @_function, sizeof(zend_function), nil, HASH_ADD) = FAILURE) then
       begin
         unload:=1;
         break;
       end;
      inc(ptr);
      inc(count);
     end;


     if (unload = 1) then begin  // before unloading, display all remaining bad function in the module */
	while (ptr.fname<> nil) do begin
          if (zend_hash_exists(target_function_table, ptr.fname, strlen(ptr.fname)+1)) = 1 then
          begin
            zend_error(error_type, zend_pchar(Format('Function registration failed - duplicate name - %s', [ptr.fname])));
	  end;
	   inc(ptr);
	 end;
	 zend_unregister_functions(functions, count, target_function_table, TSRMLS_DC);
         result := FAILURE;
         Exit;
      end;
    Result := SUCCESS;

end;



function GetGlobalResource(resource_name: AnsiString) : pointer;
var
 global_id : pointer;
 global_value : integer;
 global_ptr   : pointer;
 tsrmls_dc : pointer;
begin
  Result := nil;
  try
    global_id := GetProcAddress(PHPLib, zend_pchar(resource_name));
    if Assigned(global_id) then
     begin
       tsrmls_dc := tsrmls_fetch;
       global_value := integer(global_id^);
       asm
         mov ecx, global_value
         mov edx, dword ptr tsrmls_dc
         mov eax, dword ptr [edx]
         mov ecx, dword ptr [eax+ecx*4-4]
         mov global_ptr, ecx
       end;
       Result := global_ptr;
     end;
  except
    Result := nil;
  end;
end;


function GetCompilerGlobals : Pzend_compiler_globals;
begin
  result := GetGlobalResource('compiler_globals_id');
end;

function GetExecutorGlobals : pzend_executor_globals;
begin
  result := GetGlobalResource('executor_globals_id');
end;

function GetAllocGlobals : pointer;
begin
  result := GetGlobalResource('alloc_globals_id');
end;

{$IFDEF PHP5}

procedure zend_addref_p;
begin
    Inc({$IFDEF PHP7}z.value.counted.gc.refcount{$ELSE}z.refcount{$ENDIF});
end;

procedure my_class_add_ref;
begin
    Inc(aclass^^.refcount,1);
end;

procedure copy_zend_constant(C: PZendConstant); cdecl;
  var
  I: Integer;
begin
    C^.name := zend_strndup(C^.name, C^.name_len - 1);
    I := c^.flags and CONST_PERSISTENT;
    if I > 0 then
        _zval_copy_ctor(@c.value, nil, 0);
end;

function object_init(arg: pzval; ce: pzend_class_entry; TSRMLS_DC : pointer) : integer; cdecl; assembler;
asm
  mov eax, [esp + 16]
  mov ecx, [esp + 12]
  mov edx, [esp + 8]
  pop ebp
  push eax
  push ecx
  push edx
  call _object_init_ex
  add esp, $0c
  ret
end;


function Z_LVAL(z : pzval) : longint;
begin
  if z = nil then
  begin
      Result := 0;
      exit;
  end;

  if {$IFDEF PHP7}z.u1.v._type{$ELSE}z._type{$ENDIF} = IS_LONG then
  Result := z.value.lval
  else
    case {$IFDEF PHP7}z.u1.v._type{$ELSE}z._type{$ENDIF} of
       IS_DOUBLE: Result := Trunc(z.value.dval);
       IS_BOOL  : Result := z.value.lval;
       IS_STRING: Result := StrToIntDef( Z_STRVAL(z), 0 );
       else
          Result := 0;
    end;
end;

function Z_BVAL(z : pzval) : boolean;
begin
  if z = nil then
  begin
      Result := false;
      exit;
  end;

  if {$IFDEF PHP7}z.u1.v._type{$ELSE}z._type{$ENDIF} = IS_BOOL then
     Result := boolean(zend_bool(z.value.lval))
  else
    case {$IFDEF PHP7}z.u1.v._type{$ELSE}z._type{$ENDIF} of
       IS_DOUBLE: if Trunc(z.value.dval) = 0 then Result := false else Result := true;
       IS_LONG  : if z.value.lval = 0 then Result := false else Result := true;
       IS_STRING: if Z_STRVAL(z) = '' then Result := False else Result := True;
       else
          Result := False;
    end;
  //Result := zend_bool(z.value.lval);
end;

function Z_DVAL(z : pzval) : double;
begin
  if z = nil then
  begin
      Result := 0;
      exit;
  end;

  if {$IFDEF PHP7}z.u1.v._type{$ELSE}z._type{$ENDIF} = IS_DOUBLE then
     Result := z.value.dval
  else
    case {$IFDEF PHP7}z.u1.v._type{$ELSE}z._type{$ENDIF} of
       IS_LONG, IS_BOOL:  Result := z.value.lval;
       IS_STRING: Result := StrToFloatDef( Z_STRVAL(z), 0 );
       else
          Result := 0;
    end;
end;

function Z_VARREC(z: pzval): TVarRec;
  Var
  P: zend_ustr;
begin
  if z = nil then
  begin
      Result.VType := vtBoolean;
      Result.VBoolean := false;
      exit;
  end;

    case {$IFDEF PHP7}z.u1.v._type{$ELSE}z._type{$ENDIF} of
        IS_BOOL: begin
            Result.VType := vtBoolean;
            Result.VBoolean := Boolean(z.value.lval);
        end;
        IS_LONG: begin
            Result.VType := vtInteger;
            Result.VInteger := z.value.lval;
        end;
        IS_DOUBLE: begin
            Result.VType := vtExtended;
            New(Result.VExtended);
            Result.VExtended^ := z.value.dval;
        end;
        IS_STRING: begin
            Result.VType := {$IFDEF PHP_UNICE}vtString{$ELSE}vtAnsiString{$ENDIF};

            SetLength(P, z.value.str.len);
            Move(z.value.str.val^, P[1], z.value.str.len);

            {$IFDEF PHP_UNICE}
              Result.VUnicodeString := Pointer(p);
            {$ELSE}
              Result.VAnsiString := Pointer(P);
            {$ENDIF}
        end;
        else
        begin
            Result.VType := vtPointer;
            Result.VPointer := nil;
        end;
    end;
end;

function Z_STRUVAL(z : pzval) : UTF8String;
begin
  if z = nil then
  begin
      Result := '';
      exit;
  end;

  if {$IFDEF PHP7}z.u1.v._type{$ELSE}z._type{$ENDIF} = IS_STRING then
  begin
     SetLength(Result, z.value.str.len);
     Move(z.value.str.val^, Result[1], z.value.str.len);
  end else
    case {$IFDEF PHP7}z.u1.v._type{$ELSE}z._type{$ENDIF} of
       IS_LONG: Result := IntToStr(z.value.lval);
       IS_DOUBLE: Result := FloatToStr(z.value.dval);
       IS_BOOL: if z.value.lval = 0 then Result := '' else Result := '1';
       else
        Result := '';
    end;
end;

function Z_STRVAL(z : pzval) : zend_ustr;
begin
  if z = nil then
  begin
      Result := '';
      exit;
  end;

  if {$IFDEF PHP7}z.u1.v._type{$ELSE}z._type{$ENDIF} = IS_STRING then
  begin
     SetLength(Result, z.value.str.len);
     Move(z.value.str.val^, Result[1], z.value.str.len);
  end else
    case {$IFDEF PHP7}z.u1.v._type{$ELSE}z._type{$ENDIF} of
       IS_LONG: Result := IntToStr(z.value.lval);
       IS_DOUBLE: Result := FloatToStr(z.value.dval);
       IS_BOOL: if z.value.lval = 0 then Result := '' else Result := '1';
       else
        Result := '';
    end;
end;

function Z_STRWVAL(z : pzval) : String;
begin
  if z = nil then
  begin
      Result := '';
      exit;
  end;

  if {$IFDEF PHP7}z.u1.v._type{$ELSE}z._type{$ENDIF} = IS_STRING then
  begin
     SetLength(Result, z.value.str.len);
     Move(z.value.str.val^, Result[1], z.value.str.len);
  end else
    case {$IFDEF PHP7}z.u1.v._type{$ELSE}z._type{$ENDIF} of
       IS_LONG: Result := IntToStr(z.value.lval);
       IS_DOUBLE: Result := FloatToStr(z.value.dval);
       IS_BOOL: if z.value.lval = 0 then Result := '' else Result := '1';
       else
        Result := '';
    end;
end;

function Z_STRLEN(z : pzval) : longint;
begin
  Result := Length(Z_STRVAL(z));
end;

function Z_ARRVAL(z : pzval ) : {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF};
begin
  Result := {$IFDEF PHP7} z.value.arr {$ELSE}z.value.ht{$ENDIF};
end;

function Z_OBJ_HANDLE(z :pzval) : {$IFDEF PHP7} P_zend_object_handlers {$ELSE} zend_object_handle{$ENDIF};
begin
  Result := {$IFDEF PHP7}z.value.obj.handlers{$ELSE}z.value.obj.handle{$ENDIF};
end;

function Z_OBJ_HT(z : pzval) : {$IFDEF PHP7}hzend_types.P_zend_object_handlers{$ELSE}pzend_object_handlers{$ENDIF};
begin
  Result := z.value.obj.handlers;
end;

function Z_OBJPROP(z : pzval) : {$IFDEF PHP7}hzend_types.PHashTable{$ELSE}PHashTable{$ENDIF};
{$IFDEF PHP7}
begin
  Result := Z_OBJ_HT(z)^.get_properties(z);
end;
{$ELSE}
var
 TSRMLS_DC : pointer;
begin
  TSRMLS_DC := ts_resource_ex(0, nil);
  Result := Z_OBJ_HT(z)^.get_properties(@z, TSRMLS_DC);
end;
{$ENDIF}


{$ENDIF}

{$IFDEF PHP5}
procedure  _zval_copy_ctor (val: pzval; __zend_filename: zend_pchar; __zend_lineno: uint);
begin
  if {$IFDEF PHP7}val^.u1.v._type{$ELSE}val^._type{$ENDIF} <= IS_BOOL then
   Exit
    else
      _zval_copy_ctor_func(val, __zend_filename, __zend_lineno);
end;

procedure _zval_dtor(val: pzval; __zend_filename: zend_pchar; __zend_lineno: uint);
begin
  if {$IFDEF PHP7}val^.u1.v._type{$ELSE}val^._type{$ENDIF} <= IS_BOOL then
   Exit
     else
       _zval_dtor_func(val, __zend_filename, __zend_lineno);
end;

function zend_hash_init (ht : {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; nSize : uint; pHashFunction : pointer; pDestructor : pointer; persistent: zend_bool) : integer;
begin
  Result := _zend_hash_init(ht, nSize, pHashFunction, pDestructor, persistent, nil, 0);
end;

function zend_hash_add_or_update(ht : {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF}; arKey : zend_pchar;
    nKeyLength : uint; pData : {$IFDEF PHP7}pzval{$ELSE}pointer{$ENDIF}; nDataSize : uint; pDes : pointer;
    flag : integer) : integer;
{$IFDEF PHP7}
var pz: Pzend_string;
{$ENDIF}
begin
  {$IFDEF PHP7}
    pz^.len := strlen(arKey);
    pz^.val := estrdup(arKey);
   if Assigned(_zend_hash_add_or_update) then
   Result := _zend_hash_add_or_update(ht, pz, pData, flag, '', 0).u2.fe_iter_idx
  {$ELSE}
  if Assigned(_zend_hash_add_or_update) then
   Result := _zend_hash_add_or_update(ht, arKey, nKeyLength, pData, nDataSize, pDes, flag, nil, 0)
  {$ENDIF}
     else
       Result := FAILURE;
end;

function zend_hash_init_ex (ht : {$IFDEF PHP7}Pzend_array{$ELSE}PHashTable{$ENDIF};  nSize : uint; pHashFunction : pointer;
 pDestructor : pointer;  persistent : zend_bool;  bApplyProtection : zend_bool): integer;
begin
  Result := _zend_hash_init_ex(ht, nSize, pHashFunction, pDestructor, persistent, bApplyProtection, nil, 0);
end;

{$ENDIF}

{$IFNDEF PHP_UNICE}
function AnsiFormat(const Format: AnsiString; const Args: array of const): AnsiString;
begin
   Result := Sysutils.Format(Format, Args);
end;
{$ENDIF}
{$IFDEF COMPILER_VC9}
function  DupStr(strSource : zend_pchar) : zend_pchar; cdecl;
var
  P : zend_pchar;
begin

  if (strSource = nil) then
     P := nil
       else
         begin
           P := StrNew(strSource);
         end;
  Result := P;
end;
{$ENDIF}

initialization
{$IFDEF PHP4DELPHI_AUTOLOAD}
  LoadZEND;
{$ENDIF}

finalization
{$IFDEF PHP4DELPHI_AUTOUNLOAD}
  UnloadZEND;
{$ENDIF}

end.


