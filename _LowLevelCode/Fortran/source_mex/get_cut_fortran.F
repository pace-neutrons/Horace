#include "fintrf.h"
!=======================================================================
!     MEX-file for MATLAB to load an ASCII cut file produced by
!     mslice
!
!     Syntax:
!     >> [x,y,e,npix,pix,footer] = get_cut_fortran (filename)
!
!     filename            name of cut file
!
!     x       x-values of the n points in the cut (column)
!     y       y-values (column)
!     e       Errors (column)
!     npix    Number of pixels for each point
!     pix     (6 x n) array of det number, energy, energy bin, x, y, e
!             for each individual pixel
!     footer  Character array containing footer lines
!
!
!     T.G.Perring     March 2008: original version
!                 September 2011: modified to use fintrf.h
!
!     NOTES: At present will read a maximum length of footer i.e. cannot
!     read an arbitrary footer.
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
      mwPointer x_pr, y_pr, e_pr, npix_pr, pix_pr, footer_pr
            
! Declare local operating variables of the interface funnction
      mwSize strlen_mwSize, np_mwSize, npixtot_mwSize, nfooter_mwSize
      mwSize one_mwSize, six_mwSize
      integer*4 status, np, npixtot, nfooter
      integer*4 complex_flag
      character*255 filename
      integer*4 line_len_max, nfooter_max
      parameter (line_len_max=255, nfooter_max=100)
      character*(line_len_max) footer(nfooter_max)

! Check for proper number of MATLAB input and output arguments 
      if (nrhs .ne. 1) then
          call mexErrMsgTxt('One input filename required.')
      elseif (nlhs .ne. 6) then
          call mexErrMsgTxt('Six outputs required.')
      elseif (mxIsChar(prhs(1)) .ne. 1) then
          call mexErrMsgTxt('Input filename must be a string.')
      elseif (mxGetM(prhs(1)) .ne. 1) then
          call mexErrMsgTxt('Input filename must be a row vector.')
      end if

! Fill some constants
      one_mwSize=1
      six_mwSize=6
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
      call load_cut_header(filename,np)
      if (np .lt. 1) then
          call mexErrMsgTxt 
     +        ('File not found or error encountered during reading.')
      end if 

! Create matrices for the return arguments, double precision real*8
      np_mwSize=np
      plhs(1)=mxCreateDoubleMatrix(np_mwSize,one_mwSize,complex_flag)
      x_pr=mxGetPr(plhs(1))
      plhs(2)=mxCreateDoubleMatrix(np_mwSize,one_mwSize,complex_flag)
      y_pr=mxGetPr(plhs(2))
      plhs(3)=mxCreateDoubleMatrix(np_mwSize,one_mwSize,complex_flag)
      e_pr=mxGetPr(plhs(3))
      plhs(4)=mxCreateDoubleMatrix(np_mwSize,one_mwSize,complex_flag)
      npix_pr=mxGetPr(plhs(4))

! Call load_cut routine
      call load_cut(filename,np,%val(x_pr),%val(y_pr),%val(e_pr),
     +              %val(npix_pr),npixtot,nfooter)
      if (npixtot .lt. 0) then
          call mexErrMsgTxt 
     +        ('Error encountered during reading of the cut file.')
      end if 

! Get the individual pixel information
! For a cut there will at least one pixel
      npixtot_mwSize=npixtot
      plhs(5)=mxCreateDoubleMatrix(six_mwSize,npixtot_mwSize,0)      
      pix_pr=mxGetPr(plhs(5))
      call load_cut_pixels (npixtot,%val(pix_pr))
      
! Get the footer information
      if (nfooter .ge. 1) then
!         transfer footer to temporary storage
          nfooter=min(nfooter,nfooter_max)
          call load_cut_footer (nfooter,footer)
          nfooter_mwSize=nfooter
          plhs(6)=mxCreateCharMatrixFromStrings(nfooter_mwSize, footer)
      else
          plhs(6)=mxCreateString('')
      end if 

      end
