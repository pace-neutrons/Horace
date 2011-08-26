#include "fintrf.h"
!===========================================================================================================
! Rebin 1D dataset according to a new set of bin boundaries. Assumes data form a distribution.
!
!   >> [sout, eout] = rebin_1d_hist (x, s, e, xout)
!
! Input:
! ---------
!   x(nx)       input bin boundaries (row)
!   s(nx-1)     input signal values (column)
!   e(nx-1)     input error bars (column)
!   xout(mx)    output bin boundaries (row)
!
! Output:
! -------
!   sout(mx-1)  output signal values (column)
!   eout(mx-1)  output error bars (column)
!
!===========================================================================================================
!	T.G. Perring		August 2011     First release
!	                                  Rename from mgenie function spectrum_rebin
!                                       Renamed the calls to routines that performs rebin
!
!===========================================================================================================
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)

      implicit none
      mwPointer plhs(*), prhs(*)
      integer nrhs, nlhs

! mx routine declarations
      mwPointer mxCreateDoubleMatrix, mxGetPr
      integer mxIsNumeric
      mwSize mxGetM, mxGetN

! Internal declations
      mwPointer x_pr, s_pr, e_pr, xout_pr
      mwPointer sout_pr, eout_pr
      mwSize nx, mx
      
! Arguments for computational routine, or purely internal
      integer ierr, nx_pass, mx_pass
      character*10 ch_num
      character*80 mess

! Check for proper number of MATLAB input and output arguments 
      if (nrhs .ne. 4) then
          call mexErrMsgTxt 
     +    ('Four inputs (x, s, e, xout) required.')
      endif
      if (nlhs .ne. 2) then
          call mexErrMsgTxt ('Two outputs (sout, eout) required.')
      endif

! Check to see if all inputs are numeric
      if (mxIsNumeric(prhs(1)) .ne. 1) then
          call mexErrMsgTxt('Input #1 is not a numeric array.')
      else if (mxIsNumeric(prhs(2)) .ne. 1) then
          call mexErrMsgTxt('Input #2 is not a numeric array.')
      else if (mxIsNumeric(prhs(3)) .ne. 1) then
          call mexErrMsgTxt('Input #3 is not a numeric array.')
      else if (mxIsNumeric(prhs(4)) .ne. 1) then
          call mexErrMsgTxt('Input #4 is not a numeric array.')
      endif

! Get sizes of input arguments
      nx = mxGetN(prhs(1))
      mx = mxGetN(prhs(4))

! Get pointers to input data
      x_pr = mxGetPr (prhs(1))
      s_pr = mxGetPr (prhs(2))
      e_pr = mxGetPr (prhs(3))
      xout_pr = mxGetPr (prhs(4))

! Create pointers for the return arguments
      plhs(1) = mxCreateDoubleMatrix (mx-1, 1, 0)
      plhs(2) = mxCreateDoubleMatrix (mx-1, 1, 0)
      sout_pr = mxGetPr (plhs(1))
      eout_pr = mxGetPr (plhs(2))

! Perform rebinning:
      nx_pass=nx
      mx_pass=mx
      call IFL_rebin_1d_hist (ierr, nx_pass,
     +     %val(x_pr), %val(s_pr), %val(e_pr),
     +     mx_pass, %val(xout_pr), %val(sout_pr), %val(eout_pr))

      if (ierr .gt. 0) then
          write (ch_num, '(i6)') ierr
          mess = 'Problems rebinning (IERR = '//ch_num//')'
          call mexErrMsgTxt(mess)
      endif

      return
      end
