#include "fintrf.h"
!=======================================================================
!     MEX-file for MATLAB to load an ASCII slice file produced by
!     mslice
!
!     Syntax:
!     >> [header,x,y,c,e,npix,pix,footer] = get_slice_fortran (filename)
!
!     filename            name of slice file
!
!     header  nx,ny,xcentre(1,1),yvcentre(1,1),dx,dy (column)
!     x       x-values of the nx*ny points in the slice (column)
!     y       y-values (column)
!     c       Signal (column)
!     e       Errors (column)
!     npix    Number of pixels for each point (column)
!     pix    (7 x n) array of det number, energy, energy bin, x, y, c, e
!             for each individual pixel
!     footer  Character array containing footer lines
!
!
!     T.G.Perring     March 2008: original version
!                 September 2011: modified to use fintrf.h
!
!     NOTES: At present will read a maximum length of footer i.e. cannot
!     read an arbitrary size footer.
!
!=======================================================================
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      
      implicit none
      mwPointer plhs(*), prhs(*)
      integer*4 nrhs, nlhs

! mx routine declarations
      mwPointer mxCreateDoubleMatrix, mxGetPr
      mwPointer mxCreateCharMatrixFromStrings, mxCreateString
      mwSize mxGetM, mxGetN
      integer*4 mxIsChar, mxGetString
      
! Declare pointers to output variables  
      mwPointer header_pr,x_pr,y_pr,c_pr,e_pr,npix_pr,pix_pr,footer_pr

! Declare local operating variables of the interface funnction
      mwSize strlen_mwSize, np_mwSize, npixtot_mwSize, nfooter_mwSize
      mwSize one_mwSize, six_mwSize, seven_mwSize
      integer*4 nx, ny, status, np, npixtot, nfooter
      integer*4 complex_flag
      
      real*8 header(6)
      character*255 filename
      integer*4 line_len_max, nfooter_max
      parameter (line_len_max=255, nfooter_max=100)
      character*(line_len_max) footer(nfooter_max)

! Check for proper number of MATLAB input and output arguments 
      if (nrhs .ne. 1) then
          call mexErrMsgTxt('One input filename required.')
      elseif (nlhs .ne. 8) then
          call mexErrMsgTxt('Eight outputs required.')
      elseif (mxIsChar(prhs(1)) .ne. 1) then
          call mexErrMsgTxt('Input filename must be a string.')
      elseif (mxGetM(prhs(1)) .ne. 1) then
          call mexErrMsgTxt('Input filename must be a row vector.')
      end if

! Fill some constants
      one_mwSize=1
      six_mwSize=6
      seven_mwSize=7
      complex_flag=0
      
! Get the length of the input string
      strlen_mwSize=mxGetN(prhs(1))
      if (strlen_mwSize .gt. 255) then 
          call mexErrMsgTxt 
     +        ('Input filename must be less than 255 chars long.')
      end if 
     
! Get the string contents
      status=mxGetString(prhs(1),filename,strlen_mwSize)
      if (status .ne. 0) then 
          call mexErrMsgTxt ('Error reading filename string.')
      end if 

! Read number of pixels 
      plhs(1)=mxCreateDoubleMatrix(six_mwSize,one_mwSize,complex_flag)
      header_pr=mxGetPr(plhs(1))
      call load_slice_header(filename,%val(header_pr))
      call mxCopyPtrToReal8(header_pr,header,six_mwSize)
      nx=nint(header(1))
      ny=nint(header(2))
      if (nx .lt. 1) then
          call mexErrMsgTxt 
     +        ('File not found or error encountered during reading.')
      end if 

! Create matrices for the return arguments, double precision real*8
      np=nx*ny
      np_mwSize=np
      plhs(2)=mxCreateDoubleMatrix(np_mwSize,one_mwSize,complex_flag)
      x_pr=mxGetPr(plhs(2))
      plhs(3)=mxCreateDoubleMatrix(np_mwSize,one_mwSize,complex_flag)
      y_pr=mxGetPr(plhs(3))
      plhs(4)=mxCreateDoubleMatrix(np_mwSize,one_mwSize,complex_flag)
      c_pr=mxGetPr(plhs(4))
      plhs(5)=mxCreateDoubleMatrix(np_mwSize,one_mwSize,complex_flag)
      e_pr=mxGetPr(plhs(5))
      plhs(6)=mxCreateDoubleMatrix(np_mwSize,one_mwSize,complex_flag)
      npix_pr=mxGetPr(plhs(6))

C     Call load_slice routine
      call load_slice(filename,np,%val(x_pr),%val(y_pr),%val(c_pr),
     +              %val(e_pr),%val(npix_pr),npixtot,nfooter)
      if (npixtot .lt. 0) then
          call mexErrMsgTxt 
     +        ('Error encountered during reading of the slice file.')
      end if 

! Get the individual pixel information
! A slice may have no pixels
      npixtot_mwSize=npixtot
      plhs(7)=mxCreateDoubleMatrix(seven_mwSize,npixtot_mwSize,
     +                                                  complex_flag)
      pix_pr=mxGetPr(plhs(7))
      if (npixtot .gt. 0) then
          call load_slice_pixels (npixtot,%val(pix_pr))
      endif

! Get the footer information
      if (nfooter .ge. 1) then
!         transfer footer to temporary storage
          nfooter=min(nfooter,nfooter_max)
          call load_slice_footer (nfooter,footer)
          nfooter_mwSize=nfooter
          plhs(8)=mxCreateCharMatrixFromStrings(nfooter_mwSize, footer)
      else
          plhs(8)=mxcreatestring('')
      end if 

      end
