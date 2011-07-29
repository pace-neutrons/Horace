#include "fintrf.h"
!===========================================================================================================
! Rebin 2D dataset along x-axis with histogram data along the y-axis. Assumes data form a distribution.
!
!   >> [sout, eout] = rebin_2d_y_hist (y, s, e, xout)
!
! Input:
! ---------
!   y(ny)           input bin boundaries
!   s(nx,ny-1)      input signal values
!   e(nx,ny-1)      input error bars
!   yout(my)        output bin boundaries
!
! Output:
! -------
!   sout(nx,my-1)   output signal values
!   eout(nx,my-1)   output error bars
!
!===========================================================================================================
!	T.G. Perring		2011-07-29		Generalisation of rebin_1d_hist
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
      mwPointer y_pr, s_pr, e_pr, yout_pr
      mwPointer sout_pr, eout_pr
      mwSize nx, ny, my
      
! Arguments for computational routine, or purely internal
      integer ierr, nx_pass, ny_pass, my_pass
      character*10 ch_num
      character*80 mess

! Check for proper number of MATLAB input and output arguments 
      if (nrhs .ne. 4) then
          call mexErrMsgTxt 
     +    ('Four inputs (y, s, e, yout) required.')
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
      nx = mxGetM(prhs(2))
      ny = mxGetN(prhs(2))
      my = mxGetN(prhs(4))

! Get pointers to input data
      y_pr = mxGetPr (prhs(1))
      s_pr = mxGetPr (prhs(2))
      e_pr = mxGetPr (prhs(3))
      yout_pr = mxGetPr (prhs(4))

! Create pointers for the return arguments
      plhs(1) = mxCreateDoubleMatrix (nx, my-1, 0)
      plhs(2) = mxCreateDoubleMatrix (nx, my-1, 0)
      sout_pr = mxGetPr (plhs(1))
      eout_pr = mxGetPr (plhs(2))

! Perform rebinning:
      nx_pass=nx
      ny_pass=ny
      my_pass=my
      call IFL_rebin_2d_y_hist (ierr, nx_pass, ny_pass,
     +     %val(y_pr), %val(s_pr), %val(e_pr),
     +     my_pass, %val(yout_pr), %val(sout_pr), %val(eout_pr))

      if (ierr .gt. 0) then
          write (ch_num, '(i6)') ierr
          mess = 'Problems rebinning (IERR = '//ch_num//')'
          call mexErrMsgTxt(mess)
      endif

      return
      end
