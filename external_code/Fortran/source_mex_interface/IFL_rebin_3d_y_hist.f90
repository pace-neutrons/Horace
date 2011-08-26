	subroutine IFL_rebin_3d_y_hist (ierr, nx, ny, nz, y, s, e, my, yout, sout, eout)
	use type_definitions
	use maths, only: rebin_3d_y_hist
!-----------------------------------------------------------------------------------------------------------------------------------
! Interface to Fortran 90 library routines
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		August 2011     First release
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	integer(i4b) ierr, nx, ny, nz, my
	real(dp) y(ny), s(nx,ny-1,nz), e(nx,ny-1,nz), yout(my), sout(nx,my-1,nz), eout(nx,my-1,nz)

	call rebin_3d_y_hist (ierr, y, s, e, yout, sout, eout)

	return
	end
