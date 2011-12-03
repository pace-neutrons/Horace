#include "fintrf.h"
!=======================================================================
!     MEX-file for MATLAB to write an ASCII cut file produced by
!     mslice
!
!     >> ierr = put_cut_fortran(filename,header,x,y,c,e,...
!                              npix,pix,footer,line_len)
!
!     filename    Name of cut file
!     x           x-values of the n points in the cut (column)
!     y           y-values (column)
!     e           Errors (column)
!     npix        Number of pixels for each point (column)
!     pix         (6 x n) array of det number,energy,energy bin,x,y,e
!                 for each individual pixel
!     footer      Character array containing footer lines
!
!     ierr                =0 all OK, =1 otherwise
!
!
!     T.G.Perring     March 2008: original version
!                 September 2011: modified to use fintrf.h
!
!     NOTES: At present will write a maximum length of footer i.e. cannot
!     read an arbitrary footer.
!
!=======================================================================
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      
      implicit none
      mwPointer plhs(*), prhs(*)
      integer*4 nrhs, nlhs
      
! mx routine declarations
      mwPointer mxCreateDoubleMatrix, mxGetPr, mxGetData
      mwSize mxGetM, mxGetN
      integer*4 mxIsChar, mxIsNumeric, mxGetString
      
! Declare pointers to output variables  
      mwPointer header_pr, x_pr, y_pr, c_pr
      mwPointer e_pr, npix_pr, pix_pr, footer_pr, ierr_pr
   
! Declare local operating variables of the interface funnction
      mwSize strlen_mwSize, np_mwSize, npixtot_mwSize, footer_len_mwSize
      mwSize footer_len_ceil_mwSize
      mwSize one_mwSize
      integer*4 status, np, npixtot, nfooter, footer_len, line_len
      integer*4 complex_flag
      real*8 tmp(1)
      character*255 filename
      integer*4 line_len_max, nfooter_max
      parameter (line_len_max=255, nfooter_max=100)
      character*(line_len_max*nfooter_max) footer

! Check for proper number of MATLAB input and output arguments 
      if (nrhs .ne. 10) then
          call mexErrMsgTxt('Ten inputs required.')
      elseif (nlhs .ne. 1) then
          call mexErrMsgTxt('One output (ierr) required.')
      elseif (mxIsChar(prhs(1)) .ne. 1) then
          call mexErrMsgTxt('Input filename must be a string.')
      elseif (mxGetM(prhs(1)) .ne. 1) then
          call mexErrMsgTxt('Input filename must be a row vector.')
      end if
      
! Fill some constants
      one_mwSize=1
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

! Check to see if the other inputs are correct type
      if (mxIsNumeric(prhs(2)) .ne. 1) then
          call mexErrMsgTxt('Input #2 is not a numeric array.')
      else if (mxIsNumeric(prhs(3)) .ne. 1) then
          call mexErrMsgTxt('Input #3 is not a numeric array.')
      else if (mxIsNumeric(prhs(4)) .ne. 1) then
          call mexErrMsgTxt('Input #4 is not a numeric array.')
      else if (mxIsNumeric(prhs(5)) .ne. 1) then
          call mexErrMsgTxt('Input #5 is not a numeric array.')
      else if (mxIsNumeric(prhs(6)) .ne. 1) then
          call mexErrMsgTxt('Input #6 is not a numeric array.')
      else if (mxIsNumeric(prhs(7)) .ne. 1) then
          call mexErrMsgTxt('Input #7 is not a numeric array.')
      else if (mxIsNumeric(prhs(8)) .ne. 1) then
          call mexErrMsgTxt('Input #8 is not a numeric array.')
      else if (mxIsChar(prhs(9)) .ne. 1) then
          call mexErrMsgTxt('Input #9 is not a string.')
      else if (mxIsNumeric(prhs(10)) .ne. 1) then
          call mexErrMsgTxt('Input #10 is not a numeric array.')
      endif

! Get no. points and no. pixels 
      np_mwSize=mxGetM(prhs(3))
      npixtot_mwSize=mxGetN(prhs(8))

! Get pointers to input data
      header_pr = mxGetPr (prhs(2))
      x_pr = mxGetPr (prhs(3))
      y_pr = mxGetPr (prhs(4))
      c_pr = mxGetPr (prhs(5)) 
      e_pr = mxGetPr (prhs(6)) 
      npix_pr = mxGetPr (prhs(7))
      pix_pr  = mxGetPr (prhs(8)) 
      
! Copy data to footer, if there is one 
      footer_len_mwSize=mxGetN(prhs(9))
      footer_len=footer_len_mwSize
      if (footer_len .gt. 0) then
          if (footer_len .gt. line_len_max*nfooter_max) then
              call mexWarnMsgTxt('Footer fields truncated')
          endif
          call mxCopyPtrToReal8(mxGetData(prhs(10)),tmp,one_mwSize)
          line_len=nint(tmp(1))
          nfooter=min(footer_len,line_len_max*nfooter_max)/line_len
          if (nfooter .eq. 0) then
              footer=' '
          else
              footer_len_ceil_mwSize=line_len*nfooter
              status=mxGetString(prhs(9),footer,footer_len_ceil_mwSize)
          endif
      else
          footer = ' '
          line_len = 0
          nfooter = 0
      endif    
         
! Create scalar for the return argument
      plhs(1)=mxCreateDoubleMatrix(one_mwSize,one_mwSize,complex_flag)
      ierr_pr = mxGetPr (plhs(1))

! Call write_cut routine, pass pointers
      np=np_mwSize
      npixtot=npixtot_mwSize
      call write_slice(np,npixtot,%val(header_pr),
     +       %val(x_pr),%val(y_pr),%val(c_pr),%val(e_pr), 
     +       %val(npix_pr),%val(pix_pr),line_len,nfooter,
     +       footer,filename,%val(ierr_pr))

      return
      end
   

!-----------------------------------------------------------------------
! Write slice data 
      subroutine write_slice(np, npixtot, header, x, y, c, e, npix, pix,
     &               line_len, nfooter, footer, filename, err)
      implicit none      
      integer*4 np, npixtot, line_len, nfooter
      real*8 header(6), x(np), y(np), c(np), e(np),
     +                 npix(np), pix(7,npixtot), err
      character*(*) footer, filename

      integer*4 nx, ny, i, j, npix_end, ib, ie
      real*8 xorig, yorig, dx, dy

      err=0.0d0
      
      nx=nint(header(1))
      ny=nint(header(2))
      xorig=header(3)
      yorig=header(4)
      dx=header(5)
      dy=header(6)

      open(unit=1,file=filename,status='REPLACE',ERR=999)
      write(1,'(2i8,4g17.5)',ERR=999) nx,ny,xorig,yorig,dx,dy
      npix_end=0
      do i=1,np
          write (1,'(4g17.5,i8)',ERR=999) 
     +                     x(i),y(i),c(i),e(i),nint(npix(i))
          do j=npix_end+1,npix_end+npix(i)
              write (1,'(i8,6g17.5)',ERR=999) nint(pix(1,j)),pix(2,j),
     +          pix(3,j),pix(4,j),pix(5,j),pix(6,j),pix(7,j)
          end do
          npix_end=npix_end+npix(i)
      end do
      if (nfooter .ne. 0) then
          do i=1,nfooter
              ie=line_len*i
              ib=ie-line_len+1
              write(1,'(a)') footer(ib:ie)
          end do
      end if

      close(unit=1)
      return

 999  err=1.0d0    ! convention for error writing file
      close(unit=1)
      return
      end
