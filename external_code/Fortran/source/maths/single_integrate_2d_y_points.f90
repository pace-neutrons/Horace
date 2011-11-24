	subroutine single_integrate_2d_y_points (y, s, e, ymin, ymax, ml, mu, val, errbar)
	use type_definitions

!-----------------------------------------------------------------------------------------------------------------------------------
! Integrate y-axis over a 2D data set with point character along the y-axis between two limits.
! The method is a simple trapezoidal rule, with the ordinates at the points being linearly interpolated between
! the values in the array s.
!
! It is assumed that checks have been made to ensure that (1) ymin < ymax, and that (2) there is an overlap between the
! input y array and the interval [ymin,ymax] i.e. ymin =< y(ml) and y(mu) =< ymax for ml, mu in the range 1 to size(y)
!
!-----------------------------------------------------------------------------------------------------------------------------------
! [Optional arguments are marked with * below]
!
! INPUT:
!	s(:,:)	real		Signal
!	e(:,:)	real		Error bars on signal
!   ymin	real		Lower integration limit
!   ymax	real		Upper integration limit
!   ml      integer     Smallest ml such that ymin =< y(ml)
!   mu      integer     Largest  mu such that y(mu)=< ymax
!
! OUTPUT:
!	val(:)  real        Integral
!   errbar(:)  real     Standard deviation on val
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		August 2011     First release
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

    integer(i4b), intent(in) :: ml, mu
	real(dp), intent(in) :: y(:), s(:,:), e(:,:), ymin, ymax
	real(dp), intent(out) :: val(:), errbar(:)

	integer(i4b) ny, ilo, ihi, i
	real(dp) y1eff, yneff
	real(dp), dimension(size(s,1)) :: s1eff, sneff, e1eff, eneff

! Perform integration:
! ----------------------
    ny = size(y)

	if (mu<ml) then
!	special case of no data points in the integration range
		ilo = max(ml-1,1)	! y(1) is end point if ml=1
		ihi = min(mu+1,ny)	! y(ny) is end point if mu=ny
		val = 0.5_dp * ((ymax-ymin)/(y(ihi)-y(ilo))) * &
			&( s(:,ihi)*((ymax-y(ilo))+(ymin-y(ilo))) + s(:,ilo)*((y(ihi)-ymax)+(y(ihi)-ymin)) )
		errbar = 0.5_dp * ((ymax-ymin)/(y(ihi)-y(ilo))) * &
			& sqrt( (e(:,ihi)*((ymax-y(ilo))+(ymin-y(ilo))))**2 + (e(:,ilo)*((y(ihi)-ymax)+(y(ihi)-ymin)))**2 )
	else
!	ymin and ymax are separated by at least one data point in y(:)

!	Set up effective end points:
		if (ml>1) then	! y(1) is end point if ml=1
			y1eff = (ymin*(ymin-y(ml-1)) + y(ml-1)*(y(ml)-ymin))/(y(ml)-y(ml-1))
			s1eff = s(:,ml-1)*(y(ml)-ymin)/((y(ml)-y(ml-1)) + (ymin-y(ml-1)))
			e1eff = e(:,ml-1)*(y(ml)-ymin)/((y(ml)-y(ml-1)) + (ymin-y(ml-1)))
		else
			y1eff = y(ml)
			s1eff = 0.0_dp
			e1eff = 0.0_dp
		endif
		if (mu<ny) then	! y(mu) is end point if mu=ny
			yneff = (ymax*(y(mu+1)-ymax) + y(mu+1)*(ymax-y(mu)))/(y(mu+1)-y(mu))
			sneff = s(:,mu+1)*(ymax-y(mu))/((y(mu+1)-y(mu)) + (y(mu+1)-ymax))
			eneff = e(:,mu+1)*(ymax-y(mu))/((y(mu+1)-y(mu)) + (y(mu+1)-ymax))
		else
			yneff = y(ny)
			sneff = 0.0_dp
			eneff = 0.0_dp
		endif

!	ymin to y(ml):
		val = (y(ml)-y1eff)*(s(:,ml)+s1eff)
		errbar = (e1eff*(y(ml)-y1eff))**2

!	y(ml) to y(mu):
		if (mu==ml) then		! one data point, no complete intervals
			errbar = errbar + (e(:,ml)*(yneff-y1eff))**2
		elseif (mu==ml+1) then	! one complete interval
			val = val + (s(:,mu)+s(:,ml))*(y(mu)-y(ml))
			errbar = errbar + (e(:,ml)*(y(ml+1)-y1eff))**2 + (e(:,mu)*(yneff-y(mu-1)))**2
		else
		    val = val + (s(:,ml+1)+s(:,ml))*(y(ml+1)-y(ml))
		    errbar = errbar + (e(:,ml)*(y(ml+1)-y1eff))**2 + (e(:,mu)*(yneff-y(mu-1)))**2
		    do i=ml+1,mu-1
			    val = val + (s(:,i+1)+s(:,i))*(y(i+1)-y(i))
			    errbar = errbar + (e(:,i)*(y(i+1)-y(i-1)))**2
		    end do
		endif

!	y(mu) to ymax:
		val = val + (yneff-y(mu))*(s(:,mu)+sneff)
		errbar = errbar + (eneff*(yneff-y(mu)))**2

		val = 0.5_dp*val
		errbar = 0.5_dp*sqrt(errbar)
	endif

	return
	end
