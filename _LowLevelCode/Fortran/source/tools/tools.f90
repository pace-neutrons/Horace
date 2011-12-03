!-----------------------------------------------------------------------------------------------------------------------------------
! Interface module for tools library.
!
!-----------------------------------------------------------------------------------------------------------------------------------
module tools

interface
	subroutine locase (string)
	use type_definitions
	character(*), intent(INOUT) :: string
	end subroutine locase
end interface

interface
	subroutine prompt (string)
	use type_definitions
	character(*), intent(IN) :: string
	end subroutine prompt
end interface

interface
	subroutine remark (string)
	use type_definitions
	character(*), intent(IN) :: string
	end subroutine remark
end interface

interface
	function shutfl (iunit)
	use type_definitions
	integer(i4b), intent(IN) :: iunit
	integer(i4b) :: shutfl
	end function shutfl
end interface

interface
	function sys_open (iunit, file, status, action)
	use type_definitions
	integer(i4b), intent(IN) :: iunit
	character(*), intent(IN) :: file, status, action
	integer(i4b) :: sys_open
	end function sys_open
end interface

interface
	subroutine unitno (iunit)
	use type_definitions
	integer(i4b), intent(OUT) :: iunit
	end subroutine unitno
end interface

interface
	subroutine upcase (string)
	use type_definitions
	character(*), intent(INOUT) :: string
	end subroutine upcase
end interface

end module tools
