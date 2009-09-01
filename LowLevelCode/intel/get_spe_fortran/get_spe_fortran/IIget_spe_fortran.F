#include "fintrf.h"
C $Revision: 261 $ $Date: 2009-08-19 19:52:16 +0100 (Wed, 19 Aug 2009) $
C-----------------------------------------------------------------------
C Read header of spe file, get number of detectors(ndet)
C and number of energy bins (ne)
      subroutine load_spe_header(ndet,ne,filename)
      implicit none
      mwsize ndet,ne
      character*(*) filename

      open(unit=1,file=filename,STATUS='OLD',ERR=999)
      read(1,*,ERR=999) ndet,ne
      close(unit=1)
      return

  999 ndet=0    ! convention for error reading file
      close(unit=1)
      return
      end

C-----------------------------------------------------------------------
C Read spe data
      subroutine load_spe(ndet,ne,data_S,data_ERR,data_en,filename)
      implicit none
      mwsize ndet,ne
      mwindex idet, ien
C     Define pointers to arrays
      REAL*8 data_S(ne,ndet),data_ERR(ne,ndet),data_en(ne+1)
      REAL*8 dum(ndet+1)
      character*(*) filename
c     local variables
      character*80 message
C Skip over the first two lines with ndet, ne and some text ###
      open(unit=1,file=filename,STATUS='OLD',ERR=999)
      read(1,*,ERR=999) dum(1),dum(2)
      read(1,*,ERR=999) message
      read(1,'(8F10.0)',ERR=999) (dum(idet),idet=1,ndet+1)
      read(1,*,ERR=999) message
C energy bins
      read(1,'(8F10.0)',ERR=999) (data_en(ien),ien=1,ne+1)
C read intensities + errors
      do idet=1,ndet
          read(1,*,ERR=999) message
          read(1,'(8F10.0)',ERR=999) (data_S(ien,idet),ien=1,ne)
          read(1,*,ERR=999) message
          read(1,'(8F10.0)',ERR=999)(data_ERR(ien,idet),ien=1,ne)
      enddo
      close(unit=1)
      return

 999  ndet=0    ! convention for error reading file
      close(unit=1)
      return
      end

