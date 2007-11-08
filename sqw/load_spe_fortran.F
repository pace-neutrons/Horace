#include "fintrf.h"
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
      mwpointer plhs(*),prhs(*)
      integer  nrhs, nlhs, a
C declare external calling functions
      mwpointer mxCreateDoubleMatrix,mxGetPr 
	  mwpointer data_S_pr,data_ERR_pr,data_en_pr
	  mwsize	 mxGetM, mxGetN,strlen
      integer mxGetString
      integer mxIsChar
      integer mexPrintf
      character*80 mensage
cc    integer mxIsString
cc
cc warning!!! mxisstring is OBSOLETE -> Use mxIsChar rather than mxIsString.
cc integer*4 mxIsChar(pm)
cc mwPointer pm
cc 
C declare local operating variables of the interface funnction
      mwsize ndet, ne, status
      character*255 filename

C     Check for proper number of MATLAB input and output arguments
      if (nrhs .ne. 1) then
          call mexErrMsgTxt('One input <filename> required.')
      elseif (nlhs .ne. 3) then
          call mexErrMsgTxt
     +        ('Three outputs (data_S,data_ERR,data_en) required.')
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

C     Read ndet and ne values 
      call load_spe_header(ndet,ne,filename)
	  write(*,*)'mex',ndet,ne      
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
c--------       
c        write(mensage,*)'## before load_spe',ndet,ne,'\n'
c        a = mexPrintf(mensage)       
c--------
C     Call load_spe routine, pass pointers
      call load_spe(ndet,ne,%val(data_S_pr), 
     +              %val(data_ERR_pr),%val(data_en_pr),filename)
c--------
c        write(mensage,*)'## after load_spe',ndet,ne,'\n'
c        a = mexPrintf(mensage)
c--------
c      a = mexPrintf('%i',ndet);    
c      call mexPrintf('\nThere are %d right-hand-side argument(s).', nrhs);
      if (ndet .lt. 1) then
         call mexErrMsgTxt 
     +        ('Error encountered during reading the spe file.')
      end if 

      return
      end
