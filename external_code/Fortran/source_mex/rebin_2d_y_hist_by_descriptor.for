#include "fintrf.h"
!===========================================================================================================
! Rebin 2D dataset with histogram data slong y-axis according to a descriptor of the bin boundaries.
! Assumes data form a distribution.
!
!   >> [yout, sout, eout] = rebin_2d_y_hist_by_desriptor (y, s, e, ybounds)
!
! Input:
! ---------
!   y(ny)           input bin boundaries (row)
!   s(nx,ny-1)      input signal values
!   e(nx,ny-1)      input error bars
!   ybounds(nb)     Descriptor of array of bin boundaries onto which the data is to be rebinned (row)
!
! Output:
! -------
!   yout(my)        output bin boundaries (row)
!   sout(nx,my-1)   output signal values
!   eout(nx,my-1)   output error bars
!
!===========================================================================================================
!	T.G. Perring		2011-07-31      Based on rebin_1d_hist
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
      mwPointer y_pr, s_pr, e_pr, ybounds_pr
      mwPointer yout_pr, sout_pr, eout_pr
      mwSize nx, ny, nb, my
      
! Arguments for computational routine, or purely internal
      integer ierr, nx_pass, ny_pass, nb_pass, my_pass
      character*10 ch_num
      character*80 mess


! Check for proper number of MATLAB input and output arguments 
      if (nrhs .ne. 4) then
          call mexErrMsgTxt 
     +    ('Four inputs (y, s, e, ybounds) required.')
      endif
      if (nlhs .ne. 3) then
          call mexErrMsgTxt('Three outputs (xout,sout,eout) required.')
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
      nx = mxGetM(prhs(2))+1
      ny = mxGetN(prhs(2))
      nb = mxGetN(prhs(4))

! Get pointers to input data
      y_pr = mxGetPr (prhs(1))
      s_pr = mxGetPr (prhs(2))
      e_pr = mxGetPr (prhs(3))
      ybounds_pr = mxGetPr (prhs(4))

! Get number of bin boundaries for output:
      nb_pass=nb
      ny_pass=ny
      call IFL_bin_boundaries_get_marr (ierr, nb_pass, %val(ybounds_pr),
     +    ny_pass, %val(y_pr), my_pass)
      my=my_pass
      if (ierr .gt. 0) then
          write (ch_num, '(i6)') ierr
          mess = 'Problem creating bin bndries (IERR = '//ch_num//')'
          call mexErrMsgTxt(mess)
      endif

! Create pointers for the return arguments
      plhs(1) = mxCreateDoubleMatrix (1, my, 0)
      plhs(2) = mxCreateDoubleMatrix (nx, my-1, 0)
      plhs(3) = mxCreateDoubleMatrix (nx, my-1, 0)
      yout_pr = mxGetPr (plhs(1))
      sout_pr = mxGetPr (plhs(2))
      eout_pr = mxGetPr (plhs(3))

! Create output bin boundaries:
      call IFL_bin_boundaries_get_xarr (ierr, nb_pass, %val(ybounds_pr),
     +    ny_pass, %val(y_pr), my_pass, %val(yout_pr))
      if (ierr .gt. 0) then
          write (ch_num, '(i6)') ierr
          mess = 'Problem creating bin bndries (IERR = '//ch_num//')'
          call mexErrMsgTxt(mess)
      endif

! Perform rebinning:
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
