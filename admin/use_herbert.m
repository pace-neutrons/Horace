function use_herbert(on_off)
% utility to switch between herbert and libisis package to use in Horace
%
%Usage:
%>> use_herbert(['on'/'off'])
%
%
%>>use_herbert('off') or 
%>>use_herbert off 
%    switches herbert off and initates libisis, reinitiates Horace
%>>use_herbert on    
%>>use_herbert('on')
%>>use_herbert
%   switches libisis off and initates herbert, reinitiates Horace
%
% works only when packages were registered into toolbox area using
% install_isis('Package_name') script or in other sityations 
% when libisis_on and herebrt_on
% utilites are registered to be always on the path. 
%
%
% $Revision: 1853 $  ($Date: 2009-10-01 16:02:29 +0100 (Thu, 01 Oct 2009) $)
%

hor_root=fileparts(which('horace_init.m'));
if nargin == 0 || (nargin == 1 && strncmpi(on_off,'on',2))
    try
        libisis_off();
    catch
    end
	try
		herbert_on();    
	catch
		error('use_herbert:wrong_arguments',...
             'this function relies on herbert_on function to be permanently availible on path and apparently it is not');
	end
    rmpath(fullfile(hor_root,'libisis'));
    addpath(fullfile(hor_root,'herbert'));
    
elseif (nargin == 1 && strncmpi(on_off,'off',2))

    try
        herbert_off;    
    catch
    end
	try
		libisis_on();
	catch
		error('use_herbert:wrong_arguments','this function relies on libisis_on function to be permanently availible on path and apparently it is not');
	end	

    rmpath(fullfile(hor_root,'herbert'));
    addpath(fullfile(hor_root,'libisis'));
    
else
    error('USE_HERBERT:invalid_arguments',['call use_herbert() to switch it on ',....
       'or user_herbert(''off'') to disable it' ])
end
try
    horace_on();
catch
  error('use_herbert:wrong_arguments','this function relies on horace_on function to be availible and apparently it is not');    
end



