#include "fintrf.h"
C-----------------------------------------------------------------------
C Read header of phx file, get number of detectors(ndet) 
      subroutine load_phx_header(ndet,filename)
      implicit none
      mwsize ndet
      character*(*) filename
c      open(unit=1,file=filename,READONLY,ERR=999)
      open(unit=1,file=filename,STATUS='OLD',ERR=999)
      read(1,*,ERR=999) ndet 
      close(unit=1)  
      return  
  999 ndet=0    ! convention for error reading file
      close(unit=1)
      return 
      end

C-----------------------------------------------------------------------
C Read phx data 
      subroutine load_phx(ndet,phx,filename)
      implicit none     
      mwsize ndet,dum
      mwindex i,idet
C     Define pointers to arrays
      double precision phx(7,ndet)
      character*(*) filename
C Skip over the first lines with ndet     
c      open(unit=1,file=filename,READONLY,ERR=999)
      open(unit=1,file=filename,STATUS='OLD',ERR=999)
      read(1,*,ERR=999) dum 
C Read detector information
      do idet=1,ndet
          read(1,*,ERR=999) (phx(i,idet),i=1,7)
      enddo
      close(unit=1)
      return
 999  ndet=0    ! convention for error reading file
      close(unit=1)
      return
      end
