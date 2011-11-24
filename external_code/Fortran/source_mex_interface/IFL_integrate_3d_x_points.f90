	subroutine IFL_integrate_3d_x_points (ierr, nx, ny, nz, x, s, e, mx, xout, sout, eout)
	use type_definitions
	use maths, only: integrate_3d_x_points
!-----------------------------------------------------------------------------------------------------------------------------------
! Interface to Fortran 90 library routines
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		August 2011     First release
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	integer(i4b) ierr, nx, ny, nz, mx
	real(dp) x(nx), s(nx,ny,nz), e(nx,ny,nz), xout(mx), sout(mx-1,ny,nz), eout(mx-1,ny,nz)

	call integrate_3d_x_points (ierr, x, s, e, xout, sout, eout)

	return
	end
