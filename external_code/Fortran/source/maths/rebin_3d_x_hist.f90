	subroutine rebin_3d_x_hist (ierr, x, s, e, xout, sout, eout)
	use type_definitions
	use tools_parameters
	use maths, only : upper_index

!-----------------------------------------------------------------------------------------------------------------------------------
! Rebins histogram data along the x-axis of a 3D dataset.
!
! Assumes that the intensity and error are for a distribution (i.e. signal per unit x axis)
! Assumes that input x and xout are strictly monotonic increasing
!
!-----------------------------------------------------------------------------------------------------------------------------------
!
! INPUT:
!	x(mx+1)	        real		Histogram boundaries along x axis
!	s(mx,:,:)	    real		Signal
!	e(mx,:,:)	    real		Error bars on signal
!	xout(nx+1)	    real		Output integration range bin boundaries
!
! OUTPUT:
!	ierr	        integer		Error flag: = OK all fine; =WARN if informational messages =ERR if a problem
!	sout(nx,:,:)	real		Output signal
!	eout(nx,:,:)	real		Output error bars on signal
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		2011-07-29		Virtually identical to rebin_1d_hist
!
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	real(dp), intent(in) :: x(:), s(:,:,:), e(:,:,:)
	real(dp), intent(out) :: xout(:), sout(:,:,:), eout(:,:,:)
	integer(i4b), intent(out) :: ierr

	integer(i4b) mx, nx, iin, iout

! Perform checks on input parameters:
! ---------------------------------------
	mx = size(s,1)
	if ((mx < 1) .or. (size(x) /= mx+1) .or. (size(e,1) /= mx)) then
		call remark ('Check sizes of input arrays (rebin_3d_x_hist)')
		ierr = ERR
		return
	endif

	nx = size(sout,1)
	if ((nx < 1) .or. (size(xout) /= nx+1) .or. (size(eout,1) /= nx)) then
		call remark ('Check sizes of output arrays (rebin_3d_x_hist)')
		ierr = ERR
		return
	endif

! Get integration ranges:
! --------------------------
	sout = 0.0_dp
	eout = 0.0_dp
	ierr = OK

	iin = max(1, upper_index(x, xout(1)))
	iout= max(1, upper_index(xout, x(1)))
	if ((iin == mx+1) .or. (iout == nx+1)) return	! guarantees that there is an overlap between x and XOUT

 10	sout(iout,:,:) = sout(iout,:,:) + (min(xout(iout+1),x(iin+1)) - max(xout(iout),x(iin))) * s(iin,:,:)
	eout(iout,:,:) = eout(iout,:,:) + ((min(xout(iout+1),x(iin+1)) - max(xout(iout),x(iin))) * e(iin,:,:))**2
	if (xout(iout+1) >= x(iin+1)) then
		if (iin < mx) then
			iin = iin + 1
			goto 10
		endif
		sout(iout,:,:) = sout(iout,:,:) / (xout(iout+1)-xout(iout))		! end of input array reached
		eout(iout,:,:) = sqrt(eout(iout,:,:)) / (xout(iout+1)-xout(iout))
	else
		sout(iout,:,:) = sout(iout,:,:) / (xout(iout+1)-xout(iout))
		eout(iout,:,:) = sqrt(eout(iout,:,:)) / (xout(iout+1)-xout(iout))
		if (iout < nx) then
			iout = iout + 1
			goto 10
		endif
	endif

	return
	end
