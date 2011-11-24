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
        libisis_off;
    catch
    end
    herbert_on();    
    rmpath(fullfile(hor_root,'libisis'));
    addpath(fullfile(hor_root,'herbert'));
    
    clear classes
    set(hor_config,'use_herbert',1);
    set(hor_config,'use_her_graph',1)    
elseif (nargin == 1 && strncmpi(on_off,'off',2))
    try
        herbert_off;    
    catch
    end
    libisis_on();

    rmpath(fullfile(hor_root,'herbert'));
    addpath(fullfile(hor_root,'libisis'));
    clear classes
    
    set(hor_config,'use_herbert',0);   
    set(hor_config,'use_her_graph',0)        
else
    error('USE_HERBERT:invalid_arguments',['call use_herbert() to switch it on ',....
       'or user_herbert(''off'') to disable it' ])
end



