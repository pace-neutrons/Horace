#include "fintrf.h"
!===========================================================================================================
! Integrate x-axis over a 3D data set with point character along the x-axis, for
! intervals in a set of bin boundaries.
!
!   >> [sout, eout] = integrate_3d_x_points (x, s, e, xout)
!
! Input:
! ---------
!   x(nx)               input x values (row)
!   s(nx,ny,nz)         input signal values
!   e(nx,ny,nz)         input error bars
!   xout(mx)            output bin boundaries
!
! Output:
! -------
!   sout(mx-1,ny,nz)    output signal values
!   eout(mx-1,ny,nz)    output error bars
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
      mwPointer x_pr, s_pr, e_pr, xout_pr
      mwPointer sout_pr, eout_pr
      mwSize ndim, dims(3), mx
      integer*4 classid, complexflag
      
! Arguments for computational routine, or purely internal
      integer*4 ierr, dims_i4b(3), mx_i4b
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
      ndim=mxGetNumberOfDimensions(prhs(2))
      call mxCopyPtrToInteger4(mxGetDimensions(prhs(2)),
     *                         dims_i4b,ndim)
      dims=dims_i4b
      mx = mxGetN(prhs(4))
      mx_i4b=mx

! Get pointers to input data
      x_pr = mxGetPr (prhs(1))
      s_pr = mxGetPr (prhs(2))
      e_pr = mxGetPr (prhs(3))
      xout_pr = mxGetPr (prhs(4))

! Create pointers for the return arguments
      dims(1)=mx-1
      classid=mxClassIDFromClassName('double')
      complexflag=0
      plhs(1) = mxCreateNumericArray (ndim,dims,classid,complexflag)
      plhs(2) = mxCreateNumericArray (ndim,dims,classid,complexflag)
      sout_pr = mxGetPr (plhs(1))
      eout_pr = mxGetPr (plhs(2))

! Perform rebinning:
      call IFL_integrate_3d_x_points (ierr,
     +     dims_i4b(1), dims_i4b(2), dims_i4b(3),
     +     %val(x_pr), %val(s_pr), %val(e_pr),
     +     mx_i4b, %val(xout_pr), %val(sout_pr), %val(eout_pr))

      if (ierr .gt. 0) then
          write (ch_num, '(i6)') ierr
          mess = 'Problems integrating (IERR = '//ch_num//')'
          call mexErrMsgTxt(mess)
      endif

      return
      end
