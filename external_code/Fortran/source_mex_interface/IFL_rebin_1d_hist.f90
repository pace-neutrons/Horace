	subroutine IFL_rebin_1d_hist (ierr, nx, x, y, e, mx, xout, yout, eout)
	use type_definitions
	use maths, only: rebin_1d_hist
!-----------------------------------------------------------------------------------------------------------------------------------
! Interface to Fortran 90 library routines
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		2011-05-30		Essentially a copy of mgenie subroutine spectrum_rebin
!
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	integer(i4b) ierr, nx, mx
	real(dp) x(nx), y(nx-1), e(nx-1), xout(mx), yout(mx-1), eout(mx-1)

	call rebin_1d_hist (ierr, x, y, e, xout, yout, eout)

	return
	end
