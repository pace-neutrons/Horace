	subroutine single_integrate_1d_points (x, s, e, xmin, xmax, ml, mu, val, errbar)
	use type_definitions

!-----------------------------------------------------------------------------------------------------------------------------------
! Integrate point data between two limits.
! The method is a simple trapezoidal rule, with the ordinates at the points being linearly interpolated between
! the values in the array s.
!
! It is assumed that checks have been made to ensure that (1) xmin < xmax, and that (2) there is an overlap between the
! input x array and the interval [xmin,xmax] i.e. xmin =< x(ml) and x(mu) =< xmax for ml, mu in the range 1 to size(x)
!
!-----------------------------------------------------------------------------------------------------------------------------------
! [Optional arguments are marked with * below]
!
! INPUT:
!	x(:)	real		x-coordinates of points
!	s(:)	real		Signal
!	e(:)	real		Error bars on signal
!   xmin	real		Lower integration limit
!   xmax	real		Upper integration limit
!   ml      integer     Smallest ml such that xmin =< x(ml)
!   mu      integer     Largest  mu such that x(mu)=< xmax
!
! OUTPUT:
!	val     real        Integral
!   errbar     real        Standard deviation on val
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		2011-07-17		First release. Based very closely on INTEGRATE_1D_POINT in mgenie.
!
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

    integer(i4b), intent(in) :: ml, mu
	real(dp), intent(in) :: x(:), s(:), e(:), xmin, xmax
	real(dp), intent(out) :: val, errbar

	integer(i4b) nx, ilo, ihi
	real(dp) x1eff, xneff, s1eff, sneff, e1eff, eneff

! Perform integration:
! ----------------------
    nx = size(x)

	if (mu<ml) then
!	special case of no data points in the integration range
		ilo = max(ml-1,1)	! x(1) is end point if ml=1
		ihi = min(mu+1,nx)	! x(nx) is end point if mu=nx
		val = 0.5_dp * ((xmax-xmin)/(x(ihi)-x(ilo))) * &
			&( s(ihi)*((xmax-x(ilo))+(xmin-x(ilo))) + s(ilo)*((x(ihi)-xmax)+(x(ihi)-xmin)) )
		errbar = 0.5_dp * ((xmax-xmin)/(x(ihi)-x(ilo))) * &
			& sqrt( (e(ihi)*((xmax-x(ilo))+(xmin-x(ilo))))**2 + (e(ilo)*((x(ihi)-xmax)+(x(ihi)-xmin)))**2 )
	else
!	xmin and xmax are separated by at least one data point in x(:)

!	Set up effective end points:
		if (ml>1) then	! x(1) is end point if ml=1
			x1eff = (xmin*(xmin-x(ml-1)) + x(ml-1)*(x(ml)-xmin))/(x(ml)-x(ml-1))
			s1eff = s(ml-1)*(x(ml)-xmin)/((x(ml)-x(ml-1)) + (xmin-x(ml-1)))
			e1eff = e(ml-1)*(x(ml)-xmin)/((x(ml)-x(ml-1)) + (xmin-x(ml-1)))
		else
			x1eff = x(ml)
			s1eff = 0.0_dp
			e1eff = 0.0_dp
		endif
		if (mu<nx) then	! x(mu) is end point if mu=nx
			xneff = (xmax*(x(mu+1)-xmax) + x(mu+1)*(xmax-x(mu)))/(x(mu+1)-x(mu))
			sneff = s(mu+1)*(xmax-x(mu))/((x(mu+1)-x(mu)) + (x(mu+1)-xmax))
			eneff = e(mu+1)*(xmax-x(mu))/((x(mu+1)-x(mu)) + (x(mu+1)-xmax))
		else
			xneff = x(nx)
			sneff = 0.0_dp
			eneff = 0.0_dp
		endif

!	xmin to x(ml):
		val = (x(ml)-x1eff)*(s(ml)+s1eff)
		errbar = (e1eff*(x(ml)-x1eff))**2

!	x(ml) to x(mu):
		if (mu==ml) then		! one data point, no complete intervals
			errbar = errbar + (e(ml)*(xneff-x1eff))**2
		elseif (mu==ml+1) then	! one complete interval
			val = val + (s(mu)+s(ml))*(x(mu)-x(ml))
			errbar = errbar + (e(ml)*(x(ml+1)-x1eff))**2 + (e(mu)*(xneff-x(mu-1)))**2
		else
			val = val + sum((s(ml+1:mu)+s(ml:mu-1))*(x(ml+1:mu)-x(ml:mu-1)))
			errbar = errbar + (e(ml)*(x(ml+1)-x1eff))**2 + (e(mu)*(xneff-x(mu-1)))**2 &
						& + sum((e(ml+1:mu-1)*(x(ml+2:mu)-x(ml:mu-2)))**2)
		endif

!	x(mu) to xmax:
		val = val + (xneff-x(mu))*(s(mu)+sneff)
		errbar = errbar + (eneff*(xneff-x(mu)))**2

		val = 0.5_dp*val
		errbar = 0.5_dp*sqrt(errbar)
	endif

	return
	end
