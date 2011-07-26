	subroutine IFL_integrate_2d_x_points (ierr, nx, ny, x, s, e, mx, xout, sout, eout)
	use type_definitions
	use maths, only: integrate_2d_x_points
!-----------------------------------------------------------------------------------------------------------------------------------
! Interface to Fortran 90 library routines
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		2011-07-19		First release
!
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	integer(i4b) ierr, nx, ny, mx
	real(dp) x(nx), s(nx,ny), e(nx,ny), xout(mx), sout(mx-1,ny), eout(mx-1,ny)

	call integrate_2d_x_points (ierr, x, s, e, xout, sout, eout)

	return
	end
