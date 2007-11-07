C-----------------------------------------------------------------------
C     MEX-file for MATLAB to load an ASCII Tobyfit par file
C
C     Syntax:
C     >> par = load_par_fortran (filename)
C
C     filename            name of par file
C
C     par(5,ndet)         contents of array
C
C		1st column		sample-detector distance
C         2nd  "          scattering angle (deg)
C         3rd  "			azimuthal angle (deg)
C                     (west bank = 0 deg, north bank = -90 deg etc.)
C					(Note the reversed sign convention cf .phx files)
C         4th  "			width (m)
C         5th  "			height (m)
C
C
C-----------------------------------------------------------------------
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      implicit none
C declare input/output variables of the mexFunction
      integer plhs(*), prhs(*), nrhs, nlhs
C declare pointers to output variables  
      integer par_pr
C declare external calling functions
      integer mxGetString, mxCreateDoubleMatrix, mxGetM, mxGetN, mxGetPr
      integer mxIsString
C declare local operating variables of the interface funnction
      integer ndet, strlen, status
      character*255 filename

C     Check for proper number of MATLAB input and output arguments 
      if (nrhs .ne. 1) then
          call mexErrMsgTxt('One input <filename> required.')
      elseif (nlhs .ne. 1) then
          call mexErrMsgTxt
     +        ('One output (par) required.')
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

C     Read ndet values
      call load_par_header(ndet,filename)
      if (ndet .lt. 1) then
          call mexErrMsgTxt 
     +        ('File not found or error encountered during reading.')
      end if 

C     Create matrices for the return arguments, double precision real*8
      plhs(1)=mxCreateDoubleMatrix(5,ndet,0)      
      par_pr=mxGetPr(plhs(1))

C     Call load_par routine, pass pointers
      call load_par(ndet,%val(par_pr),filename)

      if (ndet .lt. 1) then
          call mexErrMsgTxt 
     +        ('Error encountered during reading the par file.')
      end if 

      return
      end

C-----------------------------------------------------------------------
C Read header of par file, get number of detectors(ndet) 
      subroutine load_par_header(ndet,filename)
      implicit none
      integer ndet
      character*(*) filename
      open(unit=1,file=filename,READONLY,ERR=999)
      read(1,*,ERR=999) ndet 
      close(unit=1)  
      return  
  999 ndet=0    ! convention for error reading file
      close(unit=1)
      return 
      end    

C-----------------------------------------------------------------------
C Read par data 
      subroutine load_par(ndet,par,filename)
      implicit none     
      integer ndet,i,idet,dum
C     Define pointers to arrays
      double precision par(5,ndet)
      character*(*) filename
C Skip over the first lines with ndet     
      open(unit=1,file=filename,READONLY,ERR=999)
      read(1,*,ERR=999) dum   
C read intensities + errors
      do idet=1,ndet
          read(1,*,ERR=999) (par(i,idet),i=1,5)
      enddo
      close(unit=1)
      return
 999  ndet=0    ! convention for error reading file
      close(unit=1)
      return
      end
