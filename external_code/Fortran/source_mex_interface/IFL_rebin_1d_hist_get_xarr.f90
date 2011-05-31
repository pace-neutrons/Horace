	subroutine IFL_rebin_1d_hist_get_xarr (ierr, nb, xbounds, nx, x_in, mx, x_out)
	use type_definitions
	use maths, only: rebin_1d_hist_get_xarr
!-----------------------------------------------------------------------------------------------------------------------------------
! Interface to Fortran 90 library routines
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		2011-05-30		Essentially a copy of mgenie subroutine spectrum_rebin_get_xarr
!
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	integer(i4b) ierr, nb, nx, mx
	real(dp) xbounds(nb), x_in(nx), x_out(mx)

	call rebin_1d_hist_get_xarr (ierr, xbounds, x_in=x_in, x_out=x_out)

	return
	end
