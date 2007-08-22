function horace()
% Horace startup script
%
% insures that all elements are in place in order for Horace to run
% correctly. Must be run before Horace in all instances.
%
% Horace requires Libisis and Mgenie in order to work properly. Insure
% these are installed before 

error_flag = false;

try
    libisis_init('message off');
    IXG_ST_HORACE= struct('surface_name','Horace surface plot','area_name','Horace area plot','stem_name','Horace stem plot','oned_name','Horace one dimensional plot',...
    'multiplot_name','Horace multiplot','points_name','Horace 2d marker plot','contour_name','Horace contour plot','tag','Horace');
ixf_default_properties('set','IXG_ST_HORACE',IXG_ST_HORACE);
catch
    warning('Libisis is not installed. Please refer to the libisis documentation for further information')
    error_flag = true;
end



if exist('mslice') ~= 2
    warning('Mslice was not found')
    error_flag = true;
end

if error_flag 
    error('One or more required components do not exist. Horace was not activated')
end


    display('-----------------------------------')
    display('     Horace started successfuly    ')
    display('-----------------------------------')
    display('    for help and support contact:  ')
    display('         T.G.Perring@rl.ac.uk      ')
    display('-----------------------------------')
    display('    for libisis support go to :    ')
    display('           www.libisis.org         ')
    display('-----------------------------------')