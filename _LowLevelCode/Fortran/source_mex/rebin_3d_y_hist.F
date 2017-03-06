#include "fintrf.h"
!===========================================================================================================
! Rebin 3D dataset along y-axis with histogram data along the y-axis. Assumes data form a distribution.
!
!   >> [sout, eout] = rebin_3d_y_hist (y, s, e, xout)
!
! Input:
! ---------
!   y(ny)               input bin boundaries (row)
!   s(nx,ny-1,nz)       input signal values
!   e(nx,ny-1,nz)       input error bars
!   yout(my)            output bin boundaries (row)
!
! Output:
! -------
!   sout(nx,my-1,nz)    output signal values
!   eout(nx,my-1,nz)    output error bars
!
!===========================================================================================================
!	T.G. Perring		August 2011     First release
!
!===========================================================================================================
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)

      implicit none
      mwPointer plhs(*), prhs(*)
      integer*4 nrhs, nlhs

! mx routine declarations
      mwPointer mxCreateNumericArray, mxGetPr, mxGetDimensions
      integer*4 mxIsNumeric, mxClassIDFromClassName
      mwSize mxGetN, mxGetNumberOfDimensions

! Pointer declations and declarations related to I/O arguments
      mwPointer y_pr, s_pr, e_pr, yout_pr
      mwPointer sout_pr, eout_pr
      mwSize ndim, dims(3), my
      integer*4 classid, complexflag
      
! Arguments for computational routine, or purely internal
      integer*4 ierr, dims_i4b(3), my_i4b
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
      ndim=mxGetNumberOfDimensions(prhs(2))
      call mxCopyPtrToInteger4(mxGetDimensions(prhs(2)),
     *                         dims_i4b,ndim)
      dims=dims_i4b
      my = mxGetN(prhs(4))
      my_i4b=my

! Get pointers to input data
      y_pr = mxGetPr (prhs(1))
      s_pr = mxGetPr (prhs(2))
      e_pr = mxGetPr (prhs(3))
      yout_pr = mxGetPr (prhs(4))

! Create pointers for the return arguments
      dims(2)=my-1
      classid=mxClassIDFromClassName('double')
      complexflag=0
      plhs(1) = mxCreateNumericArray (ndim,dims,classid,complexflag)
      plhs(2) = mxCreateNumericArray (ndim,dims,classid,complexflag)
      sout_pr = mxGetPr (plhs(1))
      eout_pr = mxGetPr (plhs(2))

! Perform rebinning:
      call IFL_rebin_3d_y_hist (ierr,
     +     dims_i4b(1), dims_i4b(2)+1, dims_i4b(3),
     +     %val(y_pr), %val(s_pr), %val(e_pr),
     +     my_i4b, %val(yout_pr), %val(sout_pr), %val(eout_pr))

      if (ierr .gt. 0) then
          write (ch_num, '(i6)') ierr
          mess = 'Problems rebinning (IERR = '//ch_num//')'
          call mexErrMsgTxt(mess)
      endif

      return
      end
