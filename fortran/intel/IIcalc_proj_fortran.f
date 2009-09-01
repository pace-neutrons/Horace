#include "fintrf.h"
C-----------------------------------------------------------------------
C Calculate projections
      subroutine calc_qproj(npix, c, q, u)
      implicit none
      mwsize npix 
      mwindex i
      double precision c(3,3),q(4,npix),u(4,npix)

      do i=1,npix
          u(1,i)=c(1,1)*q(1,i)+c(1,2)*q(2,i)+c(1,3)*q(3,i)
          u(2,i)=c(2,1)*q(1,i)+c(2,2)*q(2,i)+c(2,3)*q(3,i)
          u(3,i)=c(3,1)*q(1,i)+c(3,2)*q(2,i)+c(3,3)*q(3,i)
          u(4,i)=q(4,i)
      end do

      return
      end
