/*----------------------------------------------------------------------------*
*
*  heapstdproc.c  -  io: heap procedures
*
*-----------------------------------------------------------------------------*
*
*  Copyright � 2012 Hanspeter Winkler
*
*  This software is distributed under the terms of the GNU General Public
*  License version 3 as published by the Free Software Foundation.
*
*----------------------------------------------------------------------------*/

#include "heapproccommon.h"
#include "exception.h"
#include "macros.h"


/* functions */

static Status HeapStdRead
              (void *heapdata,
               Offset offset,
               Size size,
               void *buf)

{
  HeapData *data = heapdata;
  Status status;

  if ( argcheck( data == NULL ) ) return exception( E_ARGVAL );
  if ( argcheck( buf  == NULL ) ) return exception( E_ARGVAL );
  if ( argcheck( offset < 0 ) ) return exception( E_ARGVAL );

  if ( runcheck && ( data->handle == NULL ) ) return exception( E_HEAPPROC );

  if ( size ) {

    if ( size > (Size)OffsetMaxSize ) return exception( E_HEAPPROC_OFF );

    if ( data->size > 0 ) {
      if ( size > (Size)data->size ) return exception( E_HEAPPROC_OFF );
    }

    if ( data->offs > 0 ) {
      if ( OFFSETADDOVFL( offset, data->offs ) ) return exception( E_INTOVFL );
      offset += data->offs;
    }

    status = FileioReadStd( data->handle, offset, size, buf );
    if ( exception( status ) ) return status;

  }

  return E_NONE;

}


static Status HeapStdWrite
              (void *heapdata,
               Offset offset,
               Size size,
               const void *buf)

{
  HeapData *data = heapdata;
  Status status;

  if ( argcheck( data == NULL ) ) return exception( E_ARGVAL );
  if ( argcheck( buf  == NULL ) ) return exception( E_ARGVAL );
  if ( argcheck( offset < 0 ) ) return exception( E_ARGVAL );

  if ( runcheck && ( data->handle == NULL ) ) return exception( E_HEAPPROC );

  if ( size ) {

    if ( size > (Size)OffsetMaxSize ) return exception( E_HEAPPROC_OFF );

    if ( data->size > 0 ) {
      if ( size > (Size)data->size ) return exception( E_HEAPPROC_OFF );
    }

    if ( data->offs > 0 ) {
      if ( OFFSETADDOVFL( offset, data->offs ) ) return exception( E_INTOVFL );
      offset += data->offs;
    }

    status = FileioWriteStd( data->handle, offset, size, buf );
    if ( exception( status ) ) return status;

  }

  return E_NONE;

}


extern const HeapProc *HeapProcGetStd
                       (const HeapFileProc *proc)

{
  static const HeapProc HeapProcStd = {
    NULL,
    NULL,
    HeapStdRead,
    HeapStdWrite,
    HeapFileResize,
    NULL,
    NULL,
    HeapFileSync,
    HeapFileFinal,
  };

  return ( proc == NULL ) ? &HeapProcStd : ( proc->std == NULL ) ? HeapProcNull : proc->std;

}
