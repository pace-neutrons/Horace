function conf=hor_config()
% the constructor describing horace-memory and some other defaults configuration and providing singleton
% behaviour.
%
% Do not inherit your configuration classes from this class; 
% Inherit from the basic class 'config' instead
%
%
% $Revision$ ($Date$)
%
global configurations;

%this_class_name=mfilename('class');
this_class_name='hor_config';

% this is generig code which has to be copied to any consrucor, inheriting
% from the class "config"
[is_in_memory,n_this_class,child_structure] = build_child(config,@horace_defaults,this_class_name);
if is_in_memory
    conf=configurations{n_this_class};
else
    conf = class(child_structure,this_class_name,configurations{1});
    configurations{n_this_class}=conf;
end

function horace_defaults=horace_defaults()
% functuion builds the structure, which describes default parameters used
% in HORACE;
% This structure is used if no previous configuration has been defined on
% this machine,e.g. configuration file does not exist. 
% Ths function also can define the fields which will always have default
% values specifying their names in the field:
% fields_sealed

horace_defaults = ...
     struct('mem_chunk_size',10000000,...  % maximum length of buffer array in which to accumulate points from the input file
            'pixel_length',9,...           % number of words in a pixel
            'threads',1, ...               % how many computational threads to use in mex files and by Matlab
            'ignore_nan',1,...      % by default, ignore NaN values found in 
            'ignore_inf',0,...      % do not ignore inf values;
            'transformSPE2HDF',1,... % if this parameter is enabled, and spe file is processed using class speData, SPE will be rewritten as hdf file for future usage.
            'horace_info_level',1) ;   % see horace_info_level method   
    

% configure memory and processors 
    n_processors = getenv('NUMBER_OF_PROCESSORS');
    Matlab_Version=matlab_version_num();
    if(isempty(n_processors))
        n_processors=1;  % not good for linux
    else
        n_processors=str2double(n_processors);
    end
    if(Matlab_Version>7.07) % Matlab supports settings of the threads from command line
        n_processors = maxNumCompThreads();
    end
    horace_defaults.threads = n_processors;
    horace_defaults.fields_sealed={'fields_sealed','pixel_length'}; % specify the fields which values
    %can not be changed by user;







