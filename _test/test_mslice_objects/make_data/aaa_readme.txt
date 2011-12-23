Test spe files for creating test data for mslice classes and tests of mslice cf Horace
--------------------------------------------------------------------------------------
Contains two zip files, one of spe files and one of cuts and slices for use when testing
mslice classes, and also Horace.

Data files for tests
---------------------
spe_files.zip 					Test spe files, par file and phx file

cut_slice_files.zip 			Cut and slice files created by the m-file below. Have to manually copy 
								from the work area into this folder. Should not need to be run
								unless the test files need to be recreated.
								
make_cuts_and_slices.m 			Create a few cuts and slices from the above and put is a zip file.
								Uses mslice; assumes that mslice is working correctly.
								Must run from the this folder; it unzips the above file into a
								work area where it also creates the cuts and slices before
								creating the zip file.

unpack_files.m 					Unpack the two zip files above into a chosen work area (default c:\temp)


Functions for testing mslice objects
------------------------------------
