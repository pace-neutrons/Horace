#include "fintrf.h"
!===========================================================================================================
! Integrate 1D point dataset for intervals in a set of bin boundaries.
!
!   >> [yout, eout] = integrate_1d_points (x, y, e, xout)
!
! Input:
! ---------
!   x(n)        input x values
!   y(n)        input y values
!   e(n)        input error bars
!   xout(m+1)   output bin boundaries
!
! Output:
! -------
!   yout(m)     output y values
!   eout(m)     output error bars
!
!===========================================================================================================
!	T.G. Perring		2011-07-19		First release
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
      mwPointer x_pr, y_pr, e_pr, xout_pr
      mwPointer yout_pr, eout_pr
      mwSize nx, mx
      
! Arguments for computational routine, or purely internal
      integer ierr, nx_pass, mx_pass
      character*10 ch_num
      character*80 mess

! Check for proper number of MATLAB input and output arguments 
      if (nrhs .ne. 4) then
          call mexErrMsgTxt 
     +    ('Four inputs (x, y, e, xout) required.')
      endif
      if (nlhs .ne. 2) then
          call mexErrMsgTxt ('Two outputs (yout, eout) required.')
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
      y_pr = mxGetPr (prhs(2))
      e_pr = mxGetPr (prhs(3))
      xout_pr = mxGetPr (prhs(4))

! Create pointers for the return arguments
      plhs(1) = mxCreateDoubleMatrix (1, mx-1, 0)
      plhs(2) = mxCreateDoubleMatrix (1, mx-1, 0)
      yout_pr = mxGetPr (plhs(1))
      eout_pr = mxGetPr (plhs(2))

! Perform rebinning:
      nx_pass=nx
      mx_pass=mx
      call IFL_integrate_1d_points (ierr, nx_pass,
     +     %val(x_pr), %val(y_pr), %val(e_pr),
     +     mx_pass, %val(xout_pr), %val(yout_pr), %val(eout_pr))

      if (ierr .gt. 0) then
          write (ch_num, '(i6)') ierr
          mess = 'Problems integrating (IERR = '//ch_num//')'
          call mexErrMsgTxt(mess)
      endif

      return
      end
