	subroutine IFL_bin_boundaries_get_marr (ierr, nb, xbounds, nx, x_in, mx)
	use type_definitions
	use maths, only: bin_boundaries_get_xarr
!-----------------------------------------------------------------------------------------------------------------------------------
! Interface to Fortran 90 library routines
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		2011-05-30		Essentially a copy of mgenie subroutine spectrum_rebin_get_marr
!
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	integer(i4b) ierr, nb, nx, mx
	real(dp) xbounds(nb), x_in(nx)

	call bin_boundaries_get_xarr (ierr, xbounds, x_in=x_in, n_out=mx)

	return
	end
