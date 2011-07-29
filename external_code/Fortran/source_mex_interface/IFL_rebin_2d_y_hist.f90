	subroutine IFL_rebin_2d_y_hist (ierr, nx, ny, y, s, e, my, yout, sout, eout)
	use type_definitions
	use maths, only: rebin_2d_y_hist
!-----------------------------------------------------------------------------------------------------------------------------------
! Interface to Fortran 90 library routines
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		2011-05-30		Essentially a copy of mgenie subroutine spectrum_rebin
!
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	integer(i4b) ierr, nx, ny, my
	real(dp) y(nx), s(nx,ny-1), e(nx,ny-1), yout(my), sout(nx,my-1), eout(nx,my-1)

	call rebin_2d_y_hist (ierr, y, s, e, yout, sout, eout)

	return
	end
