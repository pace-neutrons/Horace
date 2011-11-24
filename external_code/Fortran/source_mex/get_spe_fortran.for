#include "fintrf.h"
!=======================================================================
!    MEX-file for MATLAB to load an ASCII spe file
!
!     Syntax:
!     >> [data_S, data_E, en] = get_spe_fortran (filename)
!
!     filename            name of spe file
!
!     data_S(ne,ndet)     here ndet=no. detectors, ne=no. energy bins
!     data_ERR(ne,ndet)       "
!     en(ne+1)            energy bin boundaries (column)
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
      mwPointer mxCreateString
      mwSize mxGetM, mxGetN
      integer*4 mxIsChar, mxGetString
            
! Declare pointers to output variables  
      mwPointer data_S_pr, data_ERR_pr, data_en_pr
      
! Declare local operating variables of the interface funnction
      mwSize strlen_mwSize, ndet_mwSize, ne_mwSize
      mwSize one_mwSize
      integer*4 status, ndet, ne
      integer*4 complex_flag
      character*255 filename

! Check for proper number of MATLAB input and output arguments 
      if (nrhs .ne. 1) then
          call mexErrMsgTxt('One input filename required.')
      elseif (nlhs .ne. 3) then
          call mexErrMsgTxt
     +        ('Three outputs (data_S,data_ERR,data_en) required.')
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

! Read ndet and ne values 
      call load_spe_header(ndet,ne,filename)
      if (ndet .lt. 1) then
          call mexErrMsgTxt 
     +        ('File not found or error encountered during reading.')
      end if 

! Create matrices for the return arguments, double precision real*8
      ne_mwSize=ne
      ndet_mwSize=ndet
      plhs(1)=mxCreateDoubleMatrix(ne_mwSize,ndet_mwSize,complex_flag)
      data_S_pr=mxGetPr(plhs(1))
      plhs(2)=mxCreateDoubleMatrix(ne_mwSize,ndet_mwSize,complex_flag)
      data_ERR_pr=mxGetPr(plhs(2))
      plhs(3)=mxCreateDoubleMatrix(ne_mwSize+1,one_mwSize,complex_flag)
      data_en_pr=mxGetPr(plhs(3))

! Call load_spe routine, pass pointers
      call load_spe(ndet,ne,%val(data_S_pr), 
     +              %val(data_ERR_pr),%val(data_en_pr),filename)
      if (ndet .lt. 1) then
         call mexErrMsgTxt 
     +        ('Error encountered during reading the spe file.')
      end if 

      return
      end

!-----------------------------------------------------------------------
! Read header of spe file, get number of detectors(ndet) 
! and number of energy bins (ne)
      subroutine load_spe_header(ndet,ne,filename)
      implicit none
      integer*4 ndet,ne
      character*(*) filename

      open(unit=1,file=filename,READONLY,ERR=999)
      read(1,*,ERR=999) ndet,ne 
      close(unit=1)  
      return  

  999 ndet=0    ! convention for error reading file
      close(unit=1)
      return 
      end    

!-----------------------------------------------------------------------
! Read spe data 
      subroutine load_spe(ndet,ne,data_S,data_ERR,data_en,filename)
      implicit none
! Input/output     
      integer*4 ndet,ne
      real*8 data_S(ne,ndet),data_ERR(ne,ndet),data_en(ne+1)
      character*(*) filename
! Internal
      integer*4 idet,ien,idum(2)
      real*8 dum(ndet+1)

! Skip over the first two lines with ndet, ne and some text ###        
      open(unit=1,file=filename,READONLY,ERR=999)
      read(1,*,ERR=999) idum(1),idum(2)
      read(1,*,ERR=999)
! angles (not used)
      read(1,'(8F10.0)',ERR=999) (dum(idet),idet=1,ndet+1)
      read(1,*,ERR=999)
! energy bins
      read(1,'(8F10.0)',ERR=999) (data_en(ien),ien=1,ne+1)    
! read intensities + errors
      do idet=1,ndet
          read(1,*,ERR=999)
          read(1,'(8F10.0)',ERR=999) (data_S(ien,idet),ien=1,ne)
          read(1,*,ERR=999)
          read(1,'(8F10.0)',ERR=999)(data_ERR(ien,idet),ien=1,ne)
      enddo
      close(unit=1)
      return

 999  ndet=0    ! convention for error reading file
      close(unit=1)
      return
      end
