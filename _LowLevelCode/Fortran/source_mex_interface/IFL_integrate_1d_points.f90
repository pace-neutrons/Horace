	subroutine IFL_integrate_1d_points (ierr, nx, x, s, e, mx, xout, sout, eout)
	use type_definitions
	use maths, only: integrate_1d_points
!-----------------------------------------------------------------------------------------------------------------------------------
! Interface to Fortran 90 library routines
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		August 2011     First release
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	integer(i4b) ierr, nx, mx
	real(dp) x(nx), s(nx), e(nx), xout(mx), sout(mx-1), eout(mx-1)

	call integrate_1d_points (ierr, x, s, e, xout, sout, eout)

	return
	end
