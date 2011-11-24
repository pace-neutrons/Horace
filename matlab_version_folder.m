function [matlab_dirname,dll_extention,os_dirname]=matlab_version_folder(varargin)
% Return folder for mex dll files, dll extension and operating system directory.
%
%   >> [matlab_dirname,dll_extention,os_dirname]=matlab_version_folder
%
% This function returns the information needed to put correct dll folder on the path in 
% applications such as Horace.
%
%   matlab_dirname      Version folder name for dll files to be used (e.g. _R2009a)
%                       If operating system unsupported by this function, return ''
%   dll_extension       Extension of dll files (e.g. mexw64); defaults to .dll if enquiry fails.
%   os_dirname          Operating system folder name (e.g. _PCWIN)
%
% The convention for folder naming that has been adopted is that dll files are kept in
% ...\_PCWIN64\_R2009a\some_function.mexw64.
% The use of an underscore indicates that it is a service directory; it is treated differently
% to other folders containing .m files when a distribution is made from the subversion copy.


% Construct the current Matlab version folder name e.g. '_R2009a'
version_string = version();
version_folder=regexp(version_string ,'(\w*','match');
matlab_dirname=version_folder{1};
matlab_dirname(1)='_';

% Get the OS folder name.
if(nargin==0)
    os_dirname = ['_',computer];
else
    os_dirname = varargin{1};
end
version_number = matlab_version_num();

% Get default matlab directory name from which to use mex file dlls
if version_number<7.04
    % Alex has 7.04 as the cut-off; with query on 7.3. However, mexw32 came in with 7.1,
    % so shouldn't the cut-off be 7.1?
    % However, will 2007a compilations work with earlier versions
    warning(['This version of mex-files has not been tested with Matlab version %s \n',...
        'Trying to use the files tested with Matlab 7.4 (2007a) but they may not work'],...
        version_string);
    matlab_dirname='_R2007a';
    
elseif(version_number>7.12) % tested up to R2011a
    warning(['This subversion of mex-files has not been tested with Matlab version %s \n',...
        'Trying to use the files tested with Matlab 7.12 (2011a) but they may not work'],...
        version_string);
    matlab_dirname='_R2009a';
end

% Matlab extension types
try
    dll_extention = mexext;
catch
    dll_extention = 'dll';   % default to pre-7.1 extension
end

% Return the matlab directory name from which to use mex file dlls
if strcmp(os_dirname,'_PCWIN32') || strcmp(os_dirname,'_PCWIN64')
    % 32 and 64 bit windows; the following changes and dependencies have been identified;
    if(strcmp('_R2007b',matlab_dirname)||strcmp('_R2007a',matlab_dirname))
        matlab_dirname='_R2007a';
    else
        matlab_dirname='_R2009a';
    end
    
elseif strcmp(os_dirname,'_GLNX86')
    % linux 32 bit
    matlab_dirname='_R2009a';   % only this one has been tested at the moment
    
elseif strcmp(os_dirname,'_GLNXA64')
    % linux 64 bit
    if(strcmp('_R2007b',matlab_dirname)||strcmp('_R2007a',matlab_dirname))
        matlab_dirname='_R2007a';
    else
        matlab_dirname='_R2009a';
    end
    
else
    % OS which is not currently supported by this script
    matlab_dirname = '';
    
end
