	subroutine integrate_2d_y_points (ierr, y, s, e, yout, sout, eout)
	use type_definitions
	use tools_parameters
	use maths, only : upper_index, lower_index, single_integrate_2d_y_points

!-----------------------------------------------------------------------------------------------------------------------------------
! Integration along the y-axis over a 2D data set with point character along the y-axis
!
! The method is a simple trapezoidal rule, with the ordinates at the points being linearly interpolated between
! the values in the array s.
!
!-----------------------------------------------------------------------------------------------------------------------------------
! [Optional arguments are marked with * below]
!
! INPUT:
!	y(ny)	    real		Point y coordinates
!	s(nx,ny)	real		Signal
!	e(nx,ny)	real		Error bars on signal
!	yout(nb+1)	real		Output integration range bin boundaries along y-axis
!
! OUTPUT:
!	ierr	    integer		Error flag: = OK all fine; =WARN if informational messages =ERR if a problem
!	sout(nx,nb)	real		Output signal
!	eout(nx,nb)	real		Output error bars on signal
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		2011-07-26		First release. Almost identical to integrate_1d_points
!                                       Virtually same as integrate_2d_x_points
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	real(dp), intent(in) :: y(:), s(:,:), e(:,:)
	real(dp), intent(out) :: yout(:), sout(:,:), eout(:,:)
	integer(i4b), intent(out) :: ierr
	
	integer(i4b) nx, ny, nb, ml, mu, ib

	sout = 0.0_dp
	eout = 0.0_dp
	ierr = OK

! Perform checks on input parameters:
! ---------------------------------------
	nx = size(s,1)
	ny = size(s,2)
	if (size(y) /= ny) then
		call remark ('Sizes of y and signal arrays do not correspond (integrate_2d_y_points)')
		ierr = ERR
		return
	endif
	if (size(s) /= size(e)) then
		call remark ('Sizes of signal and error arrays do not correspond (integrate_2d_y_points)')
		ierr = ERR
		return
	endif
	if (ny <= 1) then
		call remark ('Must have at least two data points to perform integration (integrate_2d_y_points)')
		ierr = ERR
		return
	endif

	nb = size(yout)-1
	if (nb<1) then
		call remark ('Size of output integration limits array too small (integrate_2d_y_points)')
		ierr = ERR
		return
	endif

! Get integration ranges:
! --------------------------

    ! Check that there is an overlap between the integration range and the points
    if (y(ny)<=yout(1) .or. yout(nb+1)<=y(1)) then
        return
    endif

    ! Get to starting output bin and input data point
    if (yout(1)>=y(1)) then
        ml=lower_index(y,yout(1))       ! yout(1) <= y(ml)
        ib=1;
    else
        ml=1;
        ib=upper_index(yout,y(1))       ! yout(ib) <= y(1)
    endif

    ! At this point, we have yout(ib)<=y(ml) for the first output bin, index ib, that overlaps with input data range
    ! Now get mu s.t. y(mu)<=yout(ib+1)
    do 
        if (ib>nb) return
        mu=ml-1;    ! can have mu=ml-1 if there are no data points in the interval [yout(ib),yout(ib+1)]
        do
            if (mu>=ny) exit
            if (y(mu+1)>yout(ib+1)) exit    ! Can you believe it: the stupid Intel compiler evaluates BOTH in (mu>=ny .or. y(mu+1)>yout(ib+1)
            mu=mu+1;
        end do
        ! Gets here if (1) y(mu+1)>yout(ib+1), or (2) mu=ny in which case the last y point is in output bin index ib
        call single_integrate_2d_y_points(y,s,e,yout(ib),yout(ib+1),ml,mu,sout(:,ib),eout(:,ib));
        ! Update ml for next output bin
        if (mu==ny .or. ib==nb) then
            return  ! no more output bins in the range [y(1),y(end)], or completed last output bin
        endif
        ib=ib+1;
        if (y(mu)<yout(ib)) then
            ml=mu+1;
        else
            ml=mu;
        endif
    end do

    end
