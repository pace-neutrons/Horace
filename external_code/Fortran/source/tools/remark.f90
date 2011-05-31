	subroutine remark (string)
	use type_definitions
	implicit none
!-----------------------------------------------------------------------------------------------------------------------------------
! Prints a message to the matlab command window
!
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		2011-05-30		Copied from tools library c. 2002
!
!
!-----------------------------------------------------------------------------------------------------------------------------------

! Input:
	character(*), intent(IN) :: string

	call mexPrintF (string)

	end subroutine remark
