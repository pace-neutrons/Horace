!-----------------------------------------------------------------------------------------------------------------------------------
! Parameter definitions for tools library.
!
!-----------------------------------------------------------------------------------------------------------------------------------
module	tools_parameters
	use type_definitions
	integer(i4b), parameter :: stdin=-5_i4b, stdout=-6_i4b

	integer(i4b), parameter :: ok=0_i4b, warn=-1_i4b, err=-100_i4b, eof=-101_i4b

	integer(i4b), parameter :: read=1001_i4b, readwr=1002_i4b

	integer(i4b), parameter :: old=1101_i4b, new=1102_i4b, oldnew=1103_i4b
end module tools_parameters
