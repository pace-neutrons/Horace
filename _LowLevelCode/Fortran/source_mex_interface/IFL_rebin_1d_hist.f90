	subroutine IFL_rebin_1d_hist (ierr, nx, x, s, e, mx, xout, sout, eout)
	use type_definitions
	use maths, only: rebin_1d_hist
!-----------------------------------------------------------------------------------------------------------------------------------
! Interface to Fortran 90 library routines
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		August 2011     First release
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	integer(i4b) ierr, nx, mx
	real(dp) x(nx), s(nx-1), e(nx-1), xout(mx), sout(mx-1), eout(mx-1)

	call rebin_1d_hist (ierr, x, s, e, xout, sout, eout)

	return
	end
