	subroutine integrate_3d_z_points (ierr, z, s, e, zout, sout, eout)
	use type_definitions
	use tools_parameters
	use maths, only : upper_index, lower_index, single_integrate_3d_z_points

!-----------------------------------------------------------------------------------------------------------------------------------
! Integration along the z-axis over a 2D data set with point character along the z-axis
!
! The method is a simple trapezoidal rule, with the ordinates at the points being linearly interpolated between
! the values in the array s.
!
!-----------------------------------------------------------------------------------------------------------------------------------
! [Optional arguments are marked with * below]
!
! INPUT:
!	z(nz)	        real		Point z coordinates
!	s(nx,ny,nz)	    real		Signal
!	e(nx,ny,nz)	    real		Error bars on signal
!	zout(nb+1)	    real		Output integration range bin boundaries along z-axis
!
! OUTPUT:
!	ierr	        integer		Error flag: = OK all fine; =WARN if informational messages =ERR if a problem
!	sout(nx,ny,nb)	real		Output signal
!	eout(nx,ny,nb)	real		Output error bars on signal
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		August 2011     First release
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	real(dp), intent(in) :: z(:), s(:,:,:), e(:,:,:)
	real(dp), intent(out) :: zout(:), sout(:,:,:), eout(:,:,:)
	integer(i4b), intent(out) :: ierr
	
	integer(i4b) nx, ny, nz, nb, ml, mu, ib

	sout = 0.0_dp
	eout = 0.0_dp
	ierr = OK

! Perform checks on input parameters:
! ---------------------------------------
	nx = size(s,1)
	ny = size(s,2)
	nz = size(s,3)
	if (size(z) /= nz) then
		call remark ('Sizes of z and signal arrays do not correspond (integrate_3d_z_points)')
		ierr = ERR
		return
	endif
	if (size(s) /= size(e)) then
		call remark ('Sizes of signal and error arrays do not correspond (integrate_3d_z_points)')
		ierr = ERR
		return
	endif
	if (nz <= 1) then
		call remark ('Must have at least two data points to perform integration (integrate_3d_z_points)')
		ierr = ERR
		return
	endif

	nb = size(zout)-1
	if (nb<1) then
		call remark ('Size of output integration limits array too small (integrate_3d_z_points)')
		ierr = ERR
		return
	endif

! Get integration ranges:
! --------------------------

    ! Check that there is an overlap between the integration range and the points
    if (z(nz)<=zout(1) .or. zout(nb+1)<=z(1)) then
        return
    endif

    ! Get to starting output bin and input data point
    if (zout(1)>=z(1)) then
        ml=lower_index(z,zout(1))       ! zout(1) <= z(ml)
        ib=1;
    else
        ml=1;
        ib=upper_index(zout,z(1))       ! zout(ib) <= z(1)
    endif

    ! At this point, we have zout(ib)<=z(ml) for the first output bin, index ib, that overlaps with input data range
    ! Now get mu s.t. z(mu)<=zout(ib+1)
    do 
        if (ib>nb) return
        mu=ml-1;    ! can have mu=ml-1 if there are no data points in the interval [zout(ib),zout(ib+1)]
        do
            if (mu>=nz) exit
            if (z(mu+1)>zout(ib+1)) exit    ! Can you believe it: the stupid Intel compiler evaluates BOTH in (mu>=nz .or. z(mu+1)>zout(ib+1)
            mu=mu+1;
        end do
        ! Gets here if (1) z(mu+1)>zout(ib+1), or (2) mu=nz in which case the last z point is in output bin index ib
        call single_integrate_3d_z_points(z,s,e,zout(ib),zout(ib+1),ml,mu,sout(:,:,ib),eout(:,:,ib));
        ! Update ml for next output bin
        if (mu==nz .or. ib==nb) then
            return  ! no more output bins in the range [z(1),z(end)], or completed last output bin
        endif
        ib=ib+1;
        if (z(mu)<zout(ib)) then
            ml=mu+1;
        else
            ml=mu;
        endif
    end do

    end
