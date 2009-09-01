#include "fintrf.h"
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
C         1st column      sample-detector distance
C         2nd  "          scattering angle (deg)
C         3rd  "			azimuthal angle (deg)
C                     (west bank = 0 deg, north bank = -90 deg etc.)
C                     (Note the reversed sign convention cf .phx files)
C         4th  "			width (m)
C         5th  "			height (m)
C
C
C-----------------------------------------------------------------------
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      implicit none
C declare input/output variables of the mexFunction
      integer nlhs, nrhs, mxIsNumeric
C declare pointers to output variables  
      mwpointer plhs(*), prhs(*)
      mwpointer par_pr
C declare external calling functions
      mwpointer mxGetString, mxCreateDoubleMatrix, mxGetPr
      integer mxIsChar
cc    integer mxIsString
cc
cc warning!!! mxisstring is OBSOLETE -> Use mxIsChar rather than mxIsString.
cc integer*4 mxIsChar(pm)
cc mwPointer pm
cc 
      mwsize mxGetM, mxGetN
C declare local operating variables of the interface funnction
      mwsize ndet, strlen, status
      character*255 filename

C     Check for proper number of MATLAB input and output arguments 
      if (nrhs .ne. 1) then
          call mexErrMsgTxt('One input <filename> required.')
      elseif (nlhs .ne. 1) then
          call mexErrMsgTxt
     +        ('One output (par) required.')
cc      elseif (mxIsString(prhs(1)) .ne. 1) then
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

