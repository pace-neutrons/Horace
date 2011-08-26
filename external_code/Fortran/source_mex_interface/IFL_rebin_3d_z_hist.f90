	subroutine IFL_rebin_3d_z_hist (ierr, nx, ny, nz, z, s, e, mz, zout, sout, eout)
	use type_definitions
	use maths, only: rebin_3d_z_hist
!-----------------------------------------------------------------------------------------------------------------------------------
! Interface to Fortran 90 library routines
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		August 2011     First release
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	integer(i4b) ierr, nx, ny, nz, mz
	real(dp) z(nz), s(nx,ny,nz-1), e(nx,ny,nz-1), zout(mz), sout(nx,ny,mz-1), eout(nx,ny,mz-1)

	call rebin_3d_z_hist (ierr, z, s, e, zout, sout, eout)

	return
	end
