	subroutine IFL_integrate_3d_y_points (ierr, nx, ny, nz, y, s, e, my, yout, sout, eout)
	use type_definitions
	use maths, only: integrate_3d_y_points
!-----------------------------------------------------------------------------------------------------------------------------------
! Interface to Fortran 90 library routines
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		August 2011     First release
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	integer(i4b) ierr, nx, ny, nz, my
	real(dp) y(ny), s(nx,ny,nz), e(nx,ny,nz), yout(my), sout(nx,my-1,nz), eout(nx,my-1,nz)

	call integrate_3d_y_points (ierr, y, s, e, yout, sout, eout)

	return
	end
