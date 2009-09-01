#include "fintrf.h"
C-----------------------------------------------------------------------
C     MEX-file for MATLAB to convert Q from spectrometer coordinates
C     to components along momentum projection axes
C
C     Syntax:
C     >> u = calc_proj_fortran (c, q)
C
C     c(3,3)          Matrix to convert components from
C                        spectrometer frame to projection axes
C     q(4,npix)       Coordinates of momentum  & energy transfer 
C                    in spectrometer frame
C
C     u(4,npix)      Coordinates along projection axes
C
C-----------------------------------------------------------------------
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      implicit none
C declare input/output variables of the mexFunction
C     (pointer) Replace integer by integer*8 on 64-bit platforms
      mwpointer plhs(*), prhs(*)
      integer  nrhs, nlhs
C declare pointers to output variables
C     (pointer) Replace integer by integer*8 on 64-bit platforms  
      mwpointer c_pr, q_pr, u_pr
C declare external calling functions
C     (pointer) Replace integer by integer*8 on 64-bit platforms
      mwpointer mxCreateDoubleMatrix, mxGetPr
      mwsize   mxGetM, mxGetN
C declare local operating variables of the interface funnction
      mwsize npix
c      
C     Check for proper number of MATLAB input and output arguments 
      if (nrhs .ne. 2) then
         call mexErrMsgTxt('Two inputs (cryst, qspec) required.')
      elseif (nlhs .ne. 1) then
         call mexErrMsgTxt
     c ('One output (u) required.')
      end if

C     Pointers to input arguments
      c_pr=mxGetPr(prhs(1)) 
      q_pr=mxGetPr(prhs(2)) 

C     Get the number of pixels
      npix=mxGetN(prhs(2))

C     Create matrices for the return arguments, double precision real*8
      plhs(1)=mxCreateDoubleMatrix(4,npix,0)
      u_pr=mxGetPr(plhs(1))

C     Call load_spe routine, pass pointers
      call calc_qproj(npix, %val(c_pr), %val(q_pr), %val(u_pr))
      return
      end

