C-----------------------------------------------------------------------
C     MEX-file for MATLAB to convert Q from spectrometer coordinates
C     to components along momentum projection axes
C
C     Syntax:
C     >> u = calc_proj_fortran (c, q)
C
C     c(3,3)          Matrix to convert components from
C                        spectrometer frame to projection axes
C     q(4,npix)       Coordinates of momentum  & energy transfer 
C                    in spectrometer frame
C
C     u1(4,npix)      Coordinates along projection axes
C
C-----------------------------------------------------------------------
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      implicit none
C declare input/output variables of the mexFunction
      integer plhs(*), prhs(*), nrhs, nlhs
C declare pointers to output variables  
      integer c_pr, q_pr, u_pr
C declare external calling functions
      integer mxCreateDoubleMatrix, mxGetM, mxGetN, mxGetPr
C declare local operating variables of the interface funnction
      integer npix

C     Check for proper number of MATLAB input and output arguments 
      if (nrhs .ne. 2) then
         call mexErrMsgTxt('Two inputs (cryst, qspec) required.')
      elseif (nlhs .ne. 1) then
         call mexErrMsgTxt
     c ('One output (u) required.')
      end if

C     Pointers to input arguments
      c_pr=mxGetPr(prhs(1))
      q_pr=mxGetPr(prhs(2))

C     Get the number of pixels
      npix=mxGetN(prhs(2))

C     Create matrices for the return arguments, double precision real*8
      plhs(1)=mxCreateDoubleMatrix(4,npix,0)
      u_pr=mxGetPr(plhs(1))

C     Call load_spe routine, pass pointers
      call calc_qproj(npix, %val(c_pr), %val(q_pr), %val(u_pr))

      return
      end

C-----------------------------------------------------------------------
C Calculate projections
      subroutine calc_qproj(npix, c, q, u)
      implicit none     
      integer npix, i
      double precision c(3,3),q(4,npix),u(4,npix)

      do i=1,npix
          u(1,i)=c(1,1)*q(1,i)+c(1,2)*q(2,i)+c(1,3)*q(3,i)
          u(2,i)=c(2,1)*q(1,i)+c(2,2)*q(2,i)+c(2,3)*q(3,i)
          u(3,i)=c(3,1)*q(1,i)+c(3,2)*q(2,i)+c(3,3)*q(3,i)
          u(4,i)=q(4,i)
      end do

      return
      end
