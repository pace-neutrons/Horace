	subroutine IFL_integrate_3d_z_points (ierr, nx, ny, nz, z, s, e, mz, zout, sout, eout)
	use type_definitions
	use maths, only: integrate_3d_z_points
!-----------------------------------------------------------------------------------------------------------------------------------
! Interface to Fortran 90 library routines
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		August 2011     First release
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	integer(i4b) ierr, nx, ny, nz, mz
	real(dp) z(nz), s(nx,ny,nz), e(nx,ny,nz), zout(mz), sout(nx,ny,mz-1), eout(nx,ny,mz-1)

	call integrate_3d_z_points (ierr, z, s, e, zout, sout, eout)

	return
	end
