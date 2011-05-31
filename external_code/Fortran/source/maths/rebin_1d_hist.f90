	subroutine rebin_1d_hist (ierr, xin, yin, ein, xout, yout, eout)
	use type_definitions
	use tools_parameters
	use maths, only : upper_index

!-----------------------------------------------------------------------------------------------------------------------------------
! Rebins histogram data.
! Assumes that the intensity and error are for a distribution (i.e. signal per unit x axis)
!
!-----------------------------------------------------------------------------------------------------------------------------------
! INPUT (mandatory):
!	xin(:)	real		Input histogram bin boundaries (run from 1 to MX+1)
!	yin(:)	real		Input signal (runs from 1 to MX)
!	ein(:)	real		Input error bars on signal (runs from 1 to MX)
!	xout(:)	real		Output histogram bin boundaries (run from 1 to NX+1)
!
! OUTPUT (mandatory):
!	ierr	integer		Error flag = OK all fine, or ERR if either MX or NX < 2 or other array length problems
!	yout(:)	real		Output signal (runs from 1 to NX)
!	eout(:)	real		Output error bars on signal (runs from 1 to NX)
!
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		2002-08-15		First formal release	
!
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	real(dp), intent(in) :: xin(:), yin(:), ein(:)
	real(dp), intent(out) :: xout(:), yout(:), eout(:)
	integer(i4b), intent(out) :: ierr

	integer(i4b) mx, nx, iin, iout

! Perform checks on input parameters:
! ---------------------------------------
	mx = size(yin)
	if ((mx < 1) .or. (size(xin) /= mx+1) .or. (size(ein) /= mx)) then
		call remark ('Check sizes of input arrays (rebin_1d_hist)')
		ierr = ERR
		return
	endif

	nx = size(yout)
	if ((nx < 1) .or. (size(xout) /= nx+1) .or. (size(eout) /= nx)) then
		call remark ('Check sizes of output arrays (rebin_1d_hist)')
		ierr = ERR
		return
	endif

! Get integration ranges:
! --------------------------
	yout = 0.0_dp
	eout = 0.0_dp
	ierr = OK

	iin = max(1, upper_index(xin, xout(1)))
	iout= max(1, upper_index(xout, xin(1)))
	if ((iin == mx+1) .or. (iout == nx+1)) return	! guarantees that there is an overlap between XIN and XOUT

 10	yout(iout) = yout(iout) + (min(xout(iout+1),xin(iin+1)) - max(xout(iout),xin(iin))) * yin(iin)
	eout(iout) = eout(iout) + ((min(xout(iout+1),xin(iin+1)) - max(xout(iout),xin(iin))) * ein(iin))**2
	if (xout(iout+1) >= xin(iin+1)) then
		if (iin < mx) then
			iin = iin + 1
			goto 10
		endif
		yout(iout) = yout(iout) / (xout(iout+1)-xout(iout))		! end of input array reached
		eout(iout) = sqrt(eout(iout)) / (xout(iout+1)-xout(iout))
	else
		yout(iout) = yout(iout) / (xout(iout+1)-xout(iout))
		eout(iout) = sqrt(eout(iout)) / (xout(iout+1)-xout(iout))
		if (iout < nx) then
			iout = iout + 1
			goto 10
		endif
	endif

	return
	end
