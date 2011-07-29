	subroutine rebin_2d_y_hist (ierr, y, s, e, yout, sout, eout)
	use type_definitions
	use tools_parameters
	use maths, only : upper_index

!-----------------------------------------------------------------------------------------------------------------------------------
! Rebins histogram data along the x-axis of a 2D dataset.
!
! Assumes that the intensity and error are for a distribution (i.e. signal per unit x axis)
! Assumes that input x and xout are strictly monotonic increasing
!
!-----------------------------------------------------------------------------------------------------------------------------------
!
! INPUT:
!	y(my+1)	    real		Histogram boundaries along y axis
!	s(:,my)	    real		Signal
!	e(:,my)	    real		Error bars on signal
!	yout(ny+1)	real		Output integration range bin boundaries
!
! OUTPUT:
!	ierr	    integer		Error flag: = OK all fine; =WARN if informational messages =ERR if a problem
!	sout(:,ny)	real		Output signal
!	eout(:,ny)	real		Output error bars on signal
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		2011-07-29		Virtually identical to rebin_1d_hist
!
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	real(dp), intent(in) :: y(:), s(:,:), e(:,:)
	real(dp), intent(out) :: yout(:), sout(:,:), eout(:,:)
	integer(i4b), intent(out) :: ierr

	integer(i4b) my, ny, iin, iout

! Perform checks on input parameters:
! ---------------------------------------
	my = size(s,2)
	if ((my < 1) .or. (size(y) /= my+1) .or. (size(e,2) /= my)) then
		call remark ('Check sizes of input arrays (rebin_2d_y_hist)')
		ierr = ERR
		return
	endif

	ny = size(sout,2)
	if ((ny < 1) .or. (size(yout) /= ny+1) .or. (size(eout,2) /= ny)) then
		call remark ('Check sizes of output arrays (rebin_2d_y_hist)')
		ierr = ERR
		return
	endif

! Get integration ranges:
! --------------------------
	sout = 0.0_dp
	eout = 0.0_dp
	ierr = OK

	iin = max(1, upper_index(y, yout(1)))
	iout= max(1, upper_index(yout, y(1)))
	if ((iin == my+1) .or. (iout == ny+1)) return	! guarantees that there is an overlap between y and yOUT

 10	sout(:,iout) = sout(:,iout) + (min(yout(iout+1),y(iin+1)) - max(yout(iout),y(iin))) * s(:,iin)
	eout(:,iout) = eout(:,iout) + ((min(yout(iout+1),y(iin+1)) - max(yout(iout),y(iin))) * e(:,iin))**2
	if (yout(iout+1) >= y(iin+1)) then
		if (iin < my) then
			iin = iin + 1
			goto 10
		endif
		sout(:,iout) = sout(:,iout) / (yout(iout+1)-yout(iout))		! end of input array reached
		eout(:,iout) = sqrt(eout(:,iout)) / (yout(iout+1)-yout(iout))
	else
		sout(:,iout) = sout(:,iout) / (yout(iout+1)-yout(iout))
		eout(:,iout) = sqrt(eout(:,iout)) / (yout(iout+1)-yout(iout))
		if (iout < ny) then
			iout = iout + 1
			goto 10
		endif
	endif

	return
	end
