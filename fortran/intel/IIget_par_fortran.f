#include "fintrf.h"
C-----------------------------------------------------------------------
C Read header of par file, get number of detectors(ndet) 
      subroutine load_par_header(ndet,filename)
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
C Read par data 
      subroutine load_par(ndet,par,filename)
      implicit none     
      mwsize ndet,i,idet,dum
C     Define pointers to arrays
      double precision par(5,ndet)
      character*(*) filename
C Skip over the first lines with ndet     
c      open(unit=1,file=filename,READONLY,ERR=999)
      open(unit=1,file=filename,STATUS='OLD',ERR=999)
      read(1,*,ERR=999) dum   
C Read detector information
      do idet=1,ndet
          read(1,*,ERR=999) (par(i,idet),i=1,5)
      enddo
      close(unit=1)
      return
 999  ndet=0    ! convention for error reading file
      close(unit=1)
      return
      end
