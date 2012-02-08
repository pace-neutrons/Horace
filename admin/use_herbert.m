function use_herbert(on_off)
% utility to switch herbert package off or on
%
%>> use_herbert(['on'/'off'])
%switches herbert on if used without arguments
%>> use_herbert('off') 
%switches herbert off and initates libisis
%
%works only when packages were registered into toolbox area using
%install_isis('Package_name') script
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
		error('use_herbert:wrong_arguments','this function relies on herbert_on function to be permanently availible on path and apparently it is not');
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



