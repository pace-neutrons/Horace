#include "fintrf.h"
!===========================================================================================================
! Get new bin boundaries from a rebin descriptor.
!
!   >> xout = bin_boundaries_from_descriptor (xbounds, x)
!
! Input:
! ---------
!   xbounds(nb) Descriptor of array of bin boundaries onto which the data is to be rebinned (row)
!   x(nx)       input bin boundaries (row)
!
! Output:
! -------
!   xout(m+1)   output bin boundaries (row)
!
!===========================================================================================================
!	T.G. Perring		August 2011     First release
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
      mwPointer x_pr, xbounds_pr
      mwPointer xout_pr
      mwSize nx, nb, mx
      
! Arguments for computational routine, or purely internal
      integer ierr, nx_pass, nb_pass, mx_pass
      character*10 ch_num
      character*80 mess


! Check for proper number of MATLAB input and output arguments 
      if (nrhs .ne. 2) then
          call mexErrMsgTxt 
     +    ('Two inputs (x, xbounds) required.')
      endif
      if (nlhs .ne. 1) then
          call mexErrMsgTxt('One output (xout) required.')
      endif

! Check to see if all inputs are numeric
      if (mxIsNumeric(prhs(1)) .ne. 1) then
          call mexErrMsgTxt('Input #1 is not a numeric array.')
      elseif (mxIsNumeric(prhs(2)) .ne. 1) then
          call mexErrMsgTxt('Input #2 is not a numeric array.')
      endif

! Get sizes of input arguments
      nb = mxGetN(prhs(1))
      nx = mxGetN(prhs(2))

! Get pointers to input data
      xbounds_pr = mxGetPr (prhs(1))
      x_pr = mxGetPr (prhs(2))

! Get number of bin boundaries for output:
      nb_pass=nb
      nx_pass=nx
      call IFL_bin_boundaries_get_marr (ierr, nb_pass, %val(xbounds_pr),
     +    nx_pass, %val(x_pr), mx_pass)
      mx=mx_pass
      if (ierr .gt. 0) then
          write (ch_num, '(i6)') ierr
          mess = 'Problem creating bin bndries (IERR = '//ch_num//')'
          call mexErrMsgTxt(mess)
      endif

! Create pointers for the return arguments
      plhs(1) = mxCreateDoubleMatrix (1, mx, 0)
      xout_pr = mxGetPr (plhs(1))

! Create output bin boundaries:
      call IFL_bin_boundaries_get_xarr (ierr, nb_pass, %val(xbounds_pr),
     +    nx_pass, %val(x_pr), mx_pass, %val(xout_pr))
      if (ierr .gt. 0) then
          write (ch_num, '(i6)') ierr
          mess = 'Problem creating bin bndries (IERR = '//ch_num//')'
          call mexErrMsgTxt(mess)
      endif

      return
      end
