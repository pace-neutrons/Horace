	subroutine IFL_integrate_2d_y_points (ierr, nx, ny, y, s, e, my, yout, sout, eout)
	use type_definitions
	use maths, only: integrate_2d_y_points
!-----------------------------------------------------------------------------------------------------------------------------------
! Interface to Fortran 90 library routines
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		August 2011     First release
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	integer(i4b) ierr, nx, ny, my
	real(dp) y(ny), s(nx,ny), e(nx,ny), yout(my), sout(nx,my-1), eout(nx,my-1)

	call integrate_2d_y_points (ierr, y, s, e, yout, sout, eout)

	return
	end
