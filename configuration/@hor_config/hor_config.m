function this=hor_config()
% Create the Horace configuration that sets memory options and some other defaults.
%
%   >> this = hor_config
%
% Type >> hor_config  to see the list of current configuration option values.

% $Revision$ ($Date$)
%
%--------------------------------------------------------------------------------------------------
%  ***  Alter only the contents of the subfunction at the bottom of this file called     ***
%  ***  default_config, and the help section above, which describes the contents of the  ***
%  ***  configuration structure.                                                         ***
%--------------------------------------------------------------------------------------------------
% This block contains generic code. Do not alter. Alter only the sub-function default_config below

config_name=mfilename('class');
build_configuration(config,@horace_defaults,config_name);
this=class(struct([]),config_name,config);


%--------------------------------------------------------------------------------------------------
%  Alter only the contents of the following subfunction, and the help section of the main function
%
%  This subfunction sets the field names, their defaults, and which ones are sealed against change
%  by the 'set' method.
%
%  The sealed fields must be a cell array of field names, or can be empty. The matlab function
%  struct that can be used has confusing syntax for this purpose: suppose we have fields
%  called 'v1', 'v2', 'v3',...  then we might have:
%   - if no sealed fields:  ...,sealed_fields,{{''}},...
%   - if one sealed field   ...,sealed_fields,{{'v1'}},...
%   - if two sealed fields  ...,sealed_fields,{{'v1','v2'}},...
%
%--------------------------------------------------------------------------------------------------
function horace_defaults=horace_defaults()

horace_defaults = ...
    struct('mem_chunk_size',10000000,...  % maximum length of buffer array in which to accumulate points from the input file
    'pixel_length',9,...            % number of words in a pixel
    'threads',1, ...                % how many computational threads to use in mex files and by Matlab
    'ignore_nan',1,...              % by default, ignore NaN values found in
    'ignore_inf',0,...              % do not ignore inf values;
    'transformSPE2HDF',0,...        % if this parameter is enabled, and spe file is processed using class speData, SPE will be rewritten as hdf file for future usage.
    'horace_info_level',1,... ;     % see horace_info_level method
    'use_mex',true, ...             % user will use mex-code for time-consuming operations
    'delete_tmp',true, ...          % delete temporary files which were generated while building sqw file after sqw has been build successfully
    'use_par_from_nxspe',false, ... % if nxspe file is given as input file for gen_sqw procedure, the angular detector parameters would be loaded from nxspe. If this parameter is false, par file has to be located and data will be loaded from there.
    'use_herbert',false ...         % use Herbert as IO tools
    );

Matlab_Version=matlab_version_num();

% Configure memory and processors
% let's try to identify the number of processors to use in OMP
n_processors = getenv('OMP_NUM_THREADS');
if(isempty(n_processors))
    % *** > this have to be modified in a future to work on UNIX with Matlab higher then 7.10
    n_processors=1;  % not good for linux
else
    n_processors=str2double(n_processors);
end
% Matlab below should know better how many threads to use in calculations
if(Matlab_Version>7.07&&Matlab_Version<7.11) % Matlab supports settings of the threads from command line
    s=warning('off','MATLAB:maxNumCompThreads:Deprecated');
    n_processors = maxNumCompThreads();
    warning(s.state,'MATLAB:maxNumCompThreads:Deprecated');
end
% OMP in C++ does not scale well with higher number of CPU
% or at least has not been tested against it. Lets set it to 4
% *** > but have to modify if changed to extremly large datasets in memory or
%  much bigger amount of calculations in comparison with IO operations,
% *** > optimisation is possible.
if n_processors>4
    n_processors=4;
end

[dummy,n_errors]=check_horace_mex();
if n_errors>0
    horace_defaults.use_mex=false;
end

horace_defaults.threads = n_processors;
horace_defaults.sealed_fields={'sealed_fields','pixel_length'}; % fields whose values cannot be changed by user
