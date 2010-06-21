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
            'transformSPE2HDF',0,... % if this parameter is enabled, and spe file is processed using class speData, SPE will be rewritten as hdf file for future usage.
            'horace_info_level',1,... ;   % see horace_info_level method   
            'use_mex',true, ...  user will use mex-code for time-consuming operations 
            'delete_tmp',true ... % delete temporary files which were generated while building sqw file after sqw has been build successfully 
            );

    Matlab_Version=matlab_version_num();

% configure memory and processors    
% let's try to identify the number of processors to use in OMP
    n_processors = getenv('OMP_NUM_THREADS');    
    if(isempty(n_processors))
% *** > this have to be modified in a future to work on UNIX with Matlab
% higher then 7.10
        n_processors=1;  % not good for linux 
    else
        n_processors=str2double(n_processors);
    end
    % matlabs below should know better how many threads to use in
    % calculations
    if(Matlab_Version>7.07&&Matlab_Version<7.11) % Matlab supports settings of the threads from command line
        s=warning('off','MATLAB:maxNumCompThreads:Deprecated');
        n_processors = maxNumCompThreads();
        warning(s.state,'MATLAB:maxNumCompThreads:Deprecated');               
    end
    % OMP in C++ does not scales well with higher number of CPU
    % or at least have not been tested against it. Lets set it to 4 
    % *** > but have to modify if changed to extreamly large datasets in memory or
    %  much bigger amount of calculations in comparison with IO operations,
    % *** > optimisation is possuble.
    if n_processors>4
        n_processors=4;
    end    
    
    [mex_versions,n_errors]=check_horace_mex();
    if n_errors>0
        horace_defaults.use_mex=false;
    else
    end
   
    horace_defaults.threads = n_processors;
    horace_defaults.fields_sealed={'fields_sealed','pixel_length'}; % specify the fields which values
    %can not be changed by user;







