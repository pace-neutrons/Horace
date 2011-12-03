	subroutine rebin_3d_z_hist (ierr, z, s, e, zout, sout, eout)
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
!	z(mz+1)	        real		Histogram boundaries along z axis
!	s(:,:,mz)	    real		Signal
!	e(:,:,mz)	    real		Error bars on signal
!	zout(nz+1)	    real		Output integration range bin boundaries
!
! OUTPUT:
!	ierr	        integer		Error flag: = OK all fine; =WARN if informational messages =ERR if a problem
!	sout(:,:,nz)	real		Output signal
!	eout(:,:,nz)	real		Output error bars on signal
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		2011-07-29		Virtually identical to rebin_1d_hist
!
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	real(dp), intent(in) :: z(:), s(:,:,:), e(:,:,:)
	real(dp), intent(out) :: zout(:), sout(:,:,:), eout(:,:,:)
	integer(i4b), intent(out) :: ierr

	integer(i4b) mz, nz, iin, iout

! Perform checks on input parameters:
! ---------------------------------------
	mz = size(s,3)
	if ((mz < 1) .or. (size(z) /= mz+1) .or. (size(e,2) /= mz)) then
		call remark ('Check sizes of input arrays (rebin_3d_z_hist)')
		ierr = ERR
		return
	endif

	nz = size(sout,3)
	if ((nz < 1) .or. (size(zout) /= nz+1) .or. (size(eout,2) /= nz)) then
		call remark ('Check sizes of output arrays (rebin_3d_z_hist)')
		ierr = ERR
		return
	endif

! Get integration ranges:
! --------------------------
	sout = 0.0_dp
	eout = 0.0_dp
	ierr = OK

	iin = max(1, upper_index(z, zout(1)))
	iout= max(1, upper_index(zout, z(1)))
	if ((iin == mz+1) .or. (iout == nz+1)) return	! guarantees that there is an overlap between z and zOUT

 10	sout(:,:,iout) = sout(:,:,iout) + (min(zout(iout+1),z(iin+1)) - max(zout(iout),z(iin))) * s(:,:,iin)
	eout(:,:,iout) = eout(:,:,iout) + ((min(zout(iout+1),z(iin+1)) - max(zout(iout),z(iin))) * e(:,:,iin))**2
	if (zout(iout+1) >= z(iin+1)) then
		if (iin < mz) then
			iin = iin + 1
			goto 10
		endif
		sout(:,:,iout) = sout(:,:,iout) / (zout(iout+1)-zout(iout))		! end of input array reached
		eout(:,:,iout) = sqrt(eout(:,:,iout)) / (zout(iout+1)-zout(iout))
	else
		sout(:,:,iout) = sout(:,:,iout) / (zout(iout+1)-zout(iout))
		eout(:,:,iout) = sqrt(eout(:,:,iout)) / (zout(iout+1)-zout(iout))
		if (iout < nz) then
			iout = iout + 1
			goto 10
		endif
	endif

	return
	end
