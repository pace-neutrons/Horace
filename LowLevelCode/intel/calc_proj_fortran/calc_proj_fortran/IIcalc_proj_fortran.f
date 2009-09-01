#include "fintrf.h"
C $Revision: 261 $ $Date: 2009-08-19 19:52:16 +0100 (Wed, 19 Aug 2009) $
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
