====================================================================================
Organisation of Fortran 
====================================================================================

Alteration history
------------------
30 may 2011		T.G.Perring:
First creation


====================================================================================
Description
====================================================================================

The organisation of the source code is into several folders as follows:

- projects:
	Visual Studio projects 

- source:
    Folders with source code for various groups of related functions and subroutines
    e.g. maths   maths related routines (rebin, array manipulations etc.), 
	     tools   various utility routines for use in Fortran code (finding an unused
		         unit number, raising or lowering case of a string
  
- source_mex_interface:
	Folder with wrappers for some of these functions that will be called by mex functions.
    This is needed because Fortran 90 features e.g. assumes size arrays are not 
    recognised by the matlab mex command (or at least were not when I first started
    mexing bak in about 2002). These interface routines get around this.
  
- source_mex:
	Folder with mex routines
