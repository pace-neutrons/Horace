	subroutine IFL_rebin_2d_x_hist (ierr, nx, ny, x, s, e, mx, xout, sout, eout)
	use type_definitions
	use maths, only: rebin_2d_x_hist
!-----------------------------------------------------------------------------------------------------------------------------------
! Interface to Fortran 90 library routines
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		2011-05-30		Essentially a copy of mgenie subroutine spectrum_rebin
!
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	integer(i4b) ierr, nx, ny, mx
	real(dp) x(nx), s(nx-1,ny), e(nx-1,ny), xout(mx), sout(mx-1,ny), eout(mx-1,ny)

	call rebin_2d_x_hist (ierr, x, s, e, xout, sout, eout)

	return
	end
