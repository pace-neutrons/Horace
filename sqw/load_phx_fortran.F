#include "fintrf.h"
C-----------------------------------------------------------------------
C     MEX-file for MATLAB to load an ASCII phx file
C
C     Syntax:
C     >> phx = load_phx_fortran (filename)
C
C     filename            name of phx file
C
C     phx(7,ndet)         contents of array
C
C     Recall that only the 3,4,5,6 columns in the file (rows in the
C     output of this routine) contain useful information
C         3rd column      scattering angle (deg)
C         4th  "			azimuthal angle (deg)
C                     (west bank = 0 deg, north bank = 90 deg etc.)
C         5th  "			angular width (deg)
C         6th  "			angular height (deg)
C
C
C-----------------------------------------------------------------------
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      implicit none
C declare input/output variables of the mexFunction
      mwpointer plhs(*), prhs(*)
      integer nrhs, nlhs
C declare pointers to output variables  
      mwpointer phx_pr
C declare external calling functions
      mwpointer mxCreateDoubleMatrix, mxGetPr
      mwsize mxGetM, mxGetN
      integer mxIsChar
      integer mxGetString
C declare local operating variables of the interface funnction
      mwsize ndet, strlen, status
      character*255 filename
cc
cc warning!!! mxisstring is OBSOLETE -> Use mxIsChar rather than mxIsString.
cc integer*4 mxIsChar(pm)
cc mwPointer pm
cc 

C     Check for proper number of MATLAB input and output arguments 
      if (nrhs .ne. 1) then
          call mexErrMsgTxt('One input <filename> required.')
      elseif (nlhs .ne. 1) then
          call mexErrMsgTxt
     +        ('One output (phx) required.')
      elseif (mxIsChar(prhs(1)) .ne. 1) then
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
      call load_phx_header(ndet,filename)
      if (ndet .lt. 1) then
          call mexErrMsgTxt 
     +        ('File not found or error encountered during reading.')
      end if 

C     Create matrices for the return arguments, double precision real*8
      plhs(1)=mxCreateDoubleMatrix(7,ndet,0)      
      phx_pr=mxGetPr(plhs(1))

C     Call load_phx routine, pass pointers
      call load_phx(ndet,%val(phx_pr),filename)

      if (ndet .lt. 1) then
          call mexErrMsgTxt 
     +        ('Error encountered during reading the phx file.')
      end if 
      return
      end

