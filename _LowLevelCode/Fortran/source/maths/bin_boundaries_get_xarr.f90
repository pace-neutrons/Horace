	subroutine bin_boundaries_get_xarr (ierr, xbounds, x_in, n_out, x_out)
	use tools_parameters
	use I_Index
	
!-----------------------------------------------------------------------------------------------------------------------------------
! Obtains the new bin boundaries for rebinning histogram data using the information in the array XBOUNDS.
! XBOUNDS is an array of boundaries and intervals. Linear or logarithmic rebinning can be accommodated
! by conventionally specifying the rebin interval as positive or negative respectively:
!
!   e.g. XBOUNDS = (2000,10,3000)  rebins from 2000 to 3000 in bins of 10
!
!   e.g. XBOUNDS = (5,-0.01,3000)  rebins from 5 to 3000 with logarithmically spaced bins i.e. with
!                                 width equal to 0.01 the previous bin boundary 
!
!  The conventions can be mixed on one line:
!
!   e.g. XBOUNDS = (5,-0.01,1000,20,4000,50,20000)
!
! If the original bins in an interval are required, then set the interval to zero:
!
!   e.g. XBOUNDS = (5,50,1000,0,4000,50,20000)
!      -----------------------^
!
! Where the original bins are required for at least one interval, those boundaries, XIN, are required
!
! The output bin boundaries are optional if it is desired only to get the number or new boundaries n_out. This
! is useful for allocating arrays of just the right length, and then the routine can be called again (e.g.
! when interfacing to MATLAB).
!
!-----------------------------------------------------------------------------------------------------------------------------------
!
! [Optional arguments are marked with * below]
!
! INPUT:
! ------
!	xbounds(:)	real	Histogram bin boundaries descriptor:
!						(x_1, del_1, x_2,del_2 ... x_n-1, del_n-1, x_n)
!						Bin from x_1 to x_2 in units of del_1 etc.
!						del > 0: linear bins
!						del < 0: logarithmic binning
!						del = 0: Use bins from input array
!						[If only two elements, then interpreted as lower and upper bounds, with DEL=0]
! * x_in(:)		real	Input x-array - only needed if DEL=0 for one of the rebin ranges
!
! OUTPUT:
! --------
!	ierr		integer Error flag: = 0 all OK; =ERR then a problem
! * n_out		integer	No. of bin boundaries in the rebin array x_out
!						Note: do NOT rely on being an error flag; always use IERR for this
! * x_out(:)	real	Bin boundaries for rebin array.
!
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		2002-06-21		First release
!						2002-08-15		Make IERR the first argument
!
!-----------------------------------------------------------------------------------------------------------------------------------

	implicit none

	real(dp), intent(in) :: xbounds(:)
	real(dp), intent(in), optional :: x_in(:)
	integer(i4b), intent(out) :: ierr
	integer(i4b), intent(out), optional :: n_out
	real(dp), intent(out), optional :: x_out(:)

	real(dp), parameter :: small=1.0e-10_dp

	integer(i4b) mx, m_in, m_out, i, j, n, ntot, imin, imax
	real(dp) xlo, del, xhi, logdel
	logical first_time
	character mess*132

! Perform checks on input parameters:
! ---------------------------------------
	mx = size(xbounds)
	if ((mx < 2) .or. (mx > 2 .and. mod(mx,2) /= 1)) then
		mess = 'ERROR: Check size of xbounds array (bin_boundaries_get_xarr)'
		goto 99
	endif
	if (present(x_in)) m_in = size(x_in)
	if (present(x_out)) m_out = size(x_out)

! Get integration ranges:
! --------------------------
	ntot = 1	! total number of bin boundaries in output array (accumulates during algorithm)
	first_time = .TRUE.
	do i = 1, mx/2
		if (mx /= 2) then
			xlo = xbounds(2*i-1)
			del = xbounds(2*i)
			xhi = xbounds(2*i+1)
		else
			xlo = xbounds(1)
			del = 0.0_dp
			xhi = xbounds(2)
		endif

		if (xhi <= xlo) then
			mess = 'ERROR: Check boundaries monotonically increasing (bin_boundaries_get_xarr)'
			goto 99
		endif

		if (del > 0.0_dp) then
			n = int((xhi-xlo)/del - small)
			if (xlo+real(n,dp)*del < xhi) n=n+1	! n = no. bin boundaries in addition to XLO (i.e. includes XHI)
			if (present(x_out)) then
				if (ntot+n > m_out) then
					mess = 'ERROR: Output bin boundary array too small (bin_boundaries_get_xarr)'
					goto 99
				endif
				x_out(ntot) = xlo
				if (n > 1) then
					do j = 1, n-1
						x_out(j+ntot) = xlo + real(j,dp)*del
					end do
				endif
			endif
			ntot = ntot + n
		else if (del < 0.0_dp) then
			if (xlo <= 0.0_dp) then
				mess = 'ERROR: Logarithmic bins starting with XLO <= 0 forbidden (bin_boundaries_get_xarr)'
				goto 99
			endif
			logdel = log(1.0_dp-del)
			n = int(log(xhi/xlo)/logdel - small)
			if (xlo*exp(real(n,dp)*logdel) < xhi) n=n+1
			if (present(x_out)) then
				if (ntot+n > m_out) then
					mess = 'ERROR: Output bin boundary array too small (bin_boundaries_get_xarr)'
					goto 99
				endif
				x_out(ntot) = xlo
				if (n > 1) then
					do j = 1, n-1
						x_out(j+ntot) = xlo*exp(real(j,dp)*logdel)
					end do
				endif
			endif
			ntot = ntot + n
		else
!  Check that input array is present and monotonically increasing:
			if (first_time) then
				if (.not. present(x_in)) then
					mess = 'ERROR: No input x array provided to supply bin boundaries (bin_boundaries_get_xarr)'
					goto 99
				endif
				first_time = .FALSE.
				if (m_in > 1) then
					if (minval(x_in(2:m_in)-x_in(1:m_in-1)) <= 0.0_dp) then
						mess = 'ERROR: Input x array is not strictly monotonic increasing'
						goto 99
					endif
				endif
			endif
!	Get lower and upper indicies of input array of bin boundaries such that xlo < x_in(imin) < x_in(imax) < xhi:
			imin = lower_index(x_in, xlo)
			imax = upper_index(x_in, xhi)
			if (imin <= m_in .and. imax >= 1) then
				if (x_in(imin)==xlo) imin = imin + 1
				if (x_in(imax)==xhi) imax = imax - 1
				n = imax - imin + 2	! n is the number of extra bin boundaries that will be added (including XHI)
			else
				n = 1
			endif
			if (present(x_out)) then
				if (ntot+n > m_out) then
					mess = 'ERROR: Output bin boundary array too small (bin_boundaries_get_xarr)'
					goto 99
				endif
				x_out(ntot) = xlo
				if (n > 1) x_out(ntot+1:ntot+n-1) = x_in(imin:imax)	! ntot+n => ntot+n-1 TGP (2003-12-05)
			endif
			ntot = ntot + n
		endif
	end do
	if (present(n_out)) n_out = ntot
	if (present(x_out)) then
		x_out(ntot) = xhi
		if (ntot < m_out) x_out(ntot+1:m_out) = 0.0_dp
	endif
	ierr = OK
	return


!-------------------------------------------------------------------------------------------
 99	call remark (mess)
	if (present(n_out)) n_out = 0_i4b	! don't set X_OUT=0.0_dp to avoid initialising a possibly long array
	ierr = ERR
	return

	end
