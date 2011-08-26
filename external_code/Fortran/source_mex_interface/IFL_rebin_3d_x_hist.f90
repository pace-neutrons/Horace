	subroutine IFL_rebin_3d_x_hist (ierr, nx, ny, nz, x, s, e, mx, xout, sout, eout)
	use type_definitions
	use maths, only: rebin_3d_x_hist
!-----------------------------------------------------------------------------------------------------------------------------------
! Interface to Fortran 90 library routines
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		August 2011     First release
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	integer(i4b) ierr, nx, ny, nz, mx
	real(dp) x(nx), s(nx-1,ny,nz), e(nx-1,ny,nz), xout(mx), sout(mx-1,ny,nz), eout(mx-1,ny,nz)

	call rebin_3d_x_hist (ierr, x, s, e, xout, sout, eout)

	return
	end
