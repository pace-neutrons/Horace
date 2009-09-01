C-----------------------------------------------------------------------
C     MEX-file for MATLAB to load an ASCII spe file produced by
C     homer/2d on VMS
C
C     Syntax:
C     >> [data_S, data_E, en] = load_spe_fortran (filename)
C
C     filename            name of spe file
C
C     data_S(ne,ndet)     here ndet=no. detectors, ne=no. energy bins
C     data_ERR(ne,ndet)       "
C     en(ne+1,1)          energy bin boundaries
C
C
C-----------------------------------------------------------------------
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      implicit none
C declare input/output variables of the mexFunction
      integer plhs(*), prhs(*), nrhs, nlhs
C declare pointers to output variables  
      integer data_S_pr, data_ERR_pr, data_en_pr
C declare external calling functions
      integer mxGetString, mxCreateDoubleMatrix, mxGetM, mxGetN, mxGetPr
      integer mxIsString
C declare local operating variables of the interface funnction
      integer ndet, ne, strlen, status
      character*255 filename

C     Check for proper number of MATLAB input and output arguments 
      if (nrhs .ne. 1) then
          call mexErrMsgTxt('One input <filename> required.')
      elseif (nlhs .ne. 3) then
          call mexErrMsgTxt
     +        ('Three outputs (data_S,data_ERR,data_en) required.')
      elseif (mxIsString(prhs(1)) .ne. 1) then
          call mexErrMsgTxt('Input <filename> must be a string.')
      elseif (mxGetM(prhs(1)).ne.1) then
          call mexErrMsgTxt('Input <filename> must be a row vector.')
      end if

C     Get the length of the input string
      strlen=mxGetN(prhs(1))
      if (strlen .gt. 255) then 
          call mexErrMsgTxt 
     +        ('Input <filename> must be less than 255 chars long.')
      end if 
     
C     Get the string contents
      status=mxGetString(prhs(1),filename,strlen)
      if (status .ne. 0) then 
          call mexErrMsgTxt ('Error reading <filename> string.')
      end if 

C     Read ndet and ne values 
      call load_spe_header(ndet,ne,filename)
      if (ndet .lt. 1) then
          call mexErrMsgTxt 
     +        ('File not found or error encountered during reading.')
      end if 

C     Create matrices for the return arguments, double precision real*8
      plhs(1)=mxCreateDoubleMatrix(ne,ndet,0)
      data_S_pr=mxGetPr(plhs(1))
      plhs(2)=mxCreateDoubleMatrix(ne,ndet,0)      
      data_ERR_pr=mxGetPr(plhs(2))
      plhs(3)=mxCreateDoubleMatrix(ne+1,1,0)      
      data_en_pr=mxGetPr(plhs(3))

C     Call load_spe routine, pass pointers
      call load_spe(ndet,ne,%val(data_S_pr), 
     +              %val(data_ERR_pr),%val(data_en_pr),filename)
      if (ndet .lt. 1) then
         call mexErrMsgTxt 
     +        ('Error encountered during reading the spe file.')
      end if 

      return
      end

C-----------------------------------------------------------------------
C Read header of spe file, get number of detectors(ndet) 
C and number of energy bins (ne)
      subroutine load_spe_header(ndet,ne,filename)
      implicit none
      integer ndet,ne
      character*(*) filename

      open(unit=1,file=filename,READONLY,ERR=999)
      read(1,*,ERR=999) ndet,ne 
      close(unit=1)  
      return  

  999 ndet=0    ! convention for error reading file
      close(unit=1)
      return 
      end    

C-----------------------------------------------------------------------
C Read spe data 
      subroutine load_spe(ndet,ne,data_S,data_ERR,data_en,filename)
      implicit none      
      integer ndet,ne,idet,ien,dum(ndet+1)
C     Define pointers to arrays
      double precision data_S(ne,ndet),data_ERR(ne,ndet),data_en(ne+1)
      character*(*) filename

C Skip over the first two lines with ndet, ne and some text ###        
      open(unit=1,file=filename,READONLY,ERR=999)
      read(1,*,ERR=999) dum(1),dum(2)
      read(1,*,ERR=999)
C angles (not used)
      read(1,'(8F10.0)',ERR=999) (dum(idet),idet=1,ndet+1)
      read(1,*,ERR=999)
C energy bins
      read(1,'(8F10.0)',ERR=999) (data_en(ien),ien=1,ne+1)    
C read intensities + errors
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
