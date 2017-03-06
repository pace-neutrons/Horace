#include "fintrf.h"
!=======================================================================
!     MEX-file for MATLAB to write an ASCII spe file
!
!     Syntax:
!     >> ierr = put_spe_fortran (filename,data_S,data_E,en)
!
!     filename            name of spe file
!     data_S(ne,ndet)     here ndet=no. detectors, ne=no. energy bins
!     data_ERR(ne,ndet)       "
!     en(ne+1)            energy bin boundaries (column)
!
!     ierr                =0 all OK, =1 otherwise
!
!
!     T.G.Perring            ???: original version
!                 September 2011: modified to use fintrf.h
!
!=======================================================================
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      
      implicit none
      mwPointer plhs(*), prhs(*)
      integer*4 nrhs, nlhs

! mx routine declarations
      mwPointer mxCreateDoubleMatrix, mxGetPr
      mwSize mxGetM, mxGetN
      integer*4 mxIsChar, mxIsNumeric, mxGetString
            
! Declare pointers to output variables  
      mwPointer data_S_pr, data_ERR_pr, data_en_pr, ierr_pr
      
! Declare local operating variables of the interface funnction
      mwSize strlen_mwSize, ndet_mwSize, ne_mwSize
      mwSize one_mwSize
      integer*4 status, ndet, ne
      integer*4 complex_flag
      character*255 filename

! Check for proper number of MATLAB input and output arguments 
      if (nrhs .ne. 4) then
          call mexErrMsgTxt('Four inputs (file,S,ERR,en) required.')
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

! Check to see if the other inputs are numeric
      if (mxIsNumeric(prhs(2)) .ne. 1) then
          call mexErrMsgTxt('Input #2 is not a numeric array.')
      else if (mxIsNumeric(prhs(3)) .ne. 1) then
          call mexErrMsgTxt('Input #3 is not a numeric array.')
      else if (mxIsNumeric(prhs(4)) .ne. 1) then
          call mexErrMsgTxt('Input #4 is not a numeric array.')
      endif

! Get ndet and ne values 
      ne_mwSize=mxGetM(prhs(2))
      ndet_mwSize=mxGetN(prhs(2))

! Get pointers to input data
      data_S_pr = mxGetPr (prhs(2))
      data_ERR_pr = mxGetPr (prhs(3))
      data_en_pr = mxGetPr (prhs(4)) 

! Create scalar for the return argument
      plhs(1)=mxCreateDoubleMatrix(one_mwSize,one_mwSize,complex_flag)
      ierr_pr = mxGetPr (plhs(1))

! Call load_spe routine, pass pointers
      ndet=ndet_mwSize
      ne=ne_mwSize
      call write_spe(ndet,ne,%val(data_S_pr), 
     +       %val(data_ERR_pr),%val(data_en_pr),filename,%val(ierr_pr))

      return
      end
   

!-----------------------------------------------------------------------
! Write spe data 
      subroutine write_spe(ndet,ne,data_S,data_ERR,data_en,
     +                                            filename,err)
      implicit none      
      integer*4 ndet,ne,k,idet
      real*8 data_S(ne,ndet),data_ERR(ne,ndet),data_en(ne+1),err
      character*(*) filename

      err=0.0d0
! Skip over the first two lines with ndet, ne and some text ###        
      open(unit=1,file=filename,status='REPLACE',ERR=999)
      write(1,'(2i8)',ERR=999) ndet,ne
! angles (not used)
      write (1,'(a)',ERR=999) '### Phi Grid'
      write (1,100,ERR=999) (dble(k)-0.5d0,k=1,ndet+1)
! energy bins
      write (1,'(a)',ERR=999) '### Energy Grid'
      write (1,100,ERR=999) (data_en(k),k=1,ne+1)    
! read intensities + errors
      do idet = 1, ndet
          write (1,'(a)',ERR=999) '### S(Phi,w)'
          write (1,100,ERR=999) (data_S(k,idet), k=1,ne)
          write (1,'(a)',ERR=999) '### Errors'
          write (1,100,ERR=999) (data_ERR(k,idet), k=1,ne)      
      end do
 100  format(1p,8e10.3)
      close(unit=1)
      return

 999  err=1.0d0    ! convention for error writing file
      close(unit=1)
      return
      end
