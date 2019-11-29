function [matlab_dirname,dll_extention,os_dirname]=matlab_version_folder(varargin)
% Return folder for mex dll files, dll extension and operating system directory.
% the OS directory is the one, which contains the files, suitable for and
% tested with the Matlab version which runs this script.
%
%   >> [matlab_dirname,dll_extention,os_dirname]=matlab_version_folder
%
% Enforce operating system folder for DLLs (*** TGP thinks this is redundant 5/12/11)
%   >> [matlab_dirname,dll_extention,os_dirname]=matlab_version_folder(os_dirname)
%
% This function returns the information needed to put correct dll folder on the path in 
% applications such as Horace.
%
%   matlab_dirname      Version folder name for dll files to be used (e.g. _R2009a)
%                       If operating system unsupported by this function, returns ''
%   dll_extension       Extension of dll files (e.g. mexw64); defaults to .dll if enquiry fails.
%   os_dirname          Operating system folder name (e.g. _PCWIN)
%
% The convention for folder naming that has been adopted is that dll files are kept in e.g.
% ...\_PCWIN64\_R2009a\some_function.mexw64.
% The use of an underscore indicates that it is a service directory; it is treated differently
% to other folders containing .m files when a distribution is made from the subversion copy.


% Construct the current Matlab version folder name e.g. '_R2009a'
%matlab_dirname=['_',matlab_release()];

% Get the OS folder name.
if(nargin==0)
    os_dirname = ['_',computer];
else
    os_dirname = varargin{1};
end
version_number = matlab_version_num();

% Get default matlab directory name from which to use mex file dlls
if version_number<8.05      % i.e. matlab version 8.4 i.e. R20014b
    matlab_dirname='_R2014b';    
elseif(version_number>9.07) % tested up to R2019b
    warning(['This subversion of mex-files has not been tested with Matlab version %s \n',...
        'Trying to use the files tested with Matlab 9.07 (2019b) but they may not work'],...
        version());
    matlab_dirname='_R2015a';
else
    matlab_dirname='_R2015a';    
end

if strcmp(os_dirname,'_MACI64')
     matlab_dirname='_R2015a';
end


% Matlab extension types 
% ----------------------
try
    dll_extention = mexext;
catch   % *** don't think this is necessary - have DLLs for 2007a at earliest, and these only are mexw32, mexw64 etc.
    dll_extention = 'dll';   % default to pre-7.1 extension
end
