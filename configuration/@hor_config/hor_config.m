function this=hor_config()
% Create the Horace configuration that sets memory options and some other defaults.
%
% To see the list of current configuration option values:
%   >> hor_config
%
% To set values:
%   >> set(hor_config,'name1',val1,'name2',val2,...)
%
% To fetch values:
%   >> [val1,val2,...]=get(hor_config,'name1''name2',...)
%
%
% Fields are:
% -----------
%   mem_chunk_size      Maximum number of pixels that are processed at one go during cuts
%   threads             Number of threads to use in mex files
%   ignore_nan          Ignore NaN data when making cuts
%   ignore_inf          Ignore Inf data when making cuts
%   horace_info_level   Set verbosity of informational output
%                           -1  No information messges printed
%                            0  Major information messges printed
%                            1  Minor information messges printed in addition
%                                   :
%                       The larger the value, the more information is printed
%   use_mex             Use mex files for time-consuming operation, if available
%   delete_tmp          Delete temporary sqw files generated while building sqw files
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
    'threads',1, ...                % how many computational threads to use in mex files and by Matlab
    'ignore_nan',1,...              % ignore NaN values
    'ignore_inf',0,...              % ignore inf values;
    'horace_info_level',1,... ;     % set horace_info_level method
    'use_mex',true, ...             % use mex-code for time-consuming operations
    'delete_tmp',true ...           % delete temporary files which were generated while building sqw file after sqw has been build successfully
    );

Matlab_Version=matlab_version_num();


% Configure memory
% ----------------
% Should be able to estimate the memory that can be used?


% Configure the number of threads
% -------------------------------
% let's try to identify the number of processors to use in OMP
n_processors = getenv('OMP_NUM_THREADS');
if(isempty(n_processors))
    % *** > this have to be modified in a future to work on UNIX with Matlab higher than 7.10
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

horace_defaults.threads = n_processors;


% Configure mex useage
% --------------------
[dummy,n_errors]=check_horace_mex();
if n_errors>0
    horace_defaults.use_mex=false;
end
