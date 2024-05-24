PHDRS
{
  text    PT_LOAD    ; # Contains our executable code and constants
  data    PT_LOAD    ; # Contains writable data
  dynamic PT_DYNAMIC ; # Used for dynamic linking at runtime
}

SECTIONS
{
  . = SIZEOF_HEADERS;
  .text    : { *(.text*)   } : text     # Executable code
  .rodata  : { *(.rodata*) } : text     # Read-only data
  .dynamic : { *(.dynamic) } : dynamic  # Dynamic linking information
  .dynsym  : { *(.dynsym)  } : data     # Dynamic linking symbol table
  /DISCARD/ : {
    *(.eh_frame*) # Exception handling frame information
    *(.gnu.hash*) # GNU-style hash tables
    *(.hash*)     # Any other type of hash tables
    *(.comment)   # Comments
    *(.symtab)    # Program symbol table
    *(.strtab)    # Program string table
  }
}

ENTRY (e) # Symbol name of our entrypoint