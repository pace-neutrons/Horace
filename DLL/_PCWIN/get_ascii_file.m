% The function loads into the memory an ASCII file of a specific format
%%
%  usage:
%
%  [result] = get_ascii_file(fileName,[file_type])
%
%%
%  input arguments:
% 	file_name -- a string which specifies the name of the input data file.
%                The file has to be an ascii file of one of formats
%                specified below
% 	file_type -- optional string, defining the file format
% 	             three values for this string are currently possible:
% 				 spe, par or  phx. It can also be omitted.
% 				 If omitted, the program tries to identify the file type  
%                from the file format.
% 				 If the file type option is specified and the file format differs 
% 				 from the requested, the error is thrown
%%
% output parameters:    three forms are possible:
%% ------------------------------------------------------------------------
% 1) an ASCII Tobyfit par file
%      Syntax:
%      >> par = get_ascii_file(filename,'par')
%
%      filename            name of par file
%
%      par(5,ndet)         contents of array
%
%          1st column      sample-detector distance
%          2nd  "          scattering angle (deg)
%          3rd  "          azimuthal angle (deg)
%                      (west bank = 0 deg, north bank = -90 deg etc.)
%                      (Note the reversed sign convention cf .phx files)
%          4th  "          width (m)
%          5th  "          height (m)
%% -----------------------------------------------------------------------
% 2) load an ASCII phx file
%      Syntax:
%      >> phx = get_ascii_file(filename,'phx')
%
%      filename            name of phx file
%
%      phx(7,ndet)         contents of array
%
%      Recall that only the 3,4,5,6 columns in the file (rows in the
%      output of this routine) contain useful information but all has to be
%      present in the file for function to recognize the file format
%          3rd column      scattering angle (deg)
%          4th  "          azimuthal angle (deg)
%                      (west bank = 0 deg, north bank = 90 deg etc.)
%          5th  "          angular width (deg)
%          6th  "          angular height (deg)
%% -----------------------------------------------------------------------
% 3) an ASCII spe file produced by homer/2d on VMS
%
%      Syntax:
%      >> [data_S, data_E, en] = get_ascii_file(filename,'spe')
%
%      filename            name of spe file
%                          here ndet=no. detectors, ne=no. energy bins
%      data_S(ne,ndet)     Signal array
%      data_ERR(ne,ndet)   Error array
%      en(ne+1,1)          energy bin boundaries
%
%
%% -----------------------------------------------------------------------
% Help file:   $Revision: $ ($Date: $)
%