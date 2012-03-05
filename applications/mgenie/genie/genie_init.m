function genie_init(mgenie_setup_file)
% Set up global parameters for mgenie data access and invoke OpenGenie
%
%   >> genie_init

% disp('------------------------------------------------------------------')
% disp('  Mgenie - A collection of routines to mimic GENIE in Matlab')
% disp('------------------------------------------------------------------')

global mgenie_globalvars

% Clear mgenie global variables
mgenie_globalvars=struct;

% --------------------------------------------------------------------------------------------------------------
% Invoke OpenGenie
% --------------------------------------------------------------------------------------------------------------
try
    opengenie_handle=actxserver('OpenGENIE.Application'); % Get handle to open genie
catch
    opengenie_handle=[];
end

mgenie_globalvars.opengenie_handle=opengenie_handle;

mgenie_globalvars.isisraw=gget_init;    % initialise arrays with names of raw file fields for data access routines


% --------------------------------------------------------------------------------------------------------------
% Initialise genie data source global variables
% --------------------------------------------------------------------------------------------------------------
source.disk = '';
source.dir  = '';
source.inst = '';
source.ext = '';
source.run = [];
source.run_char = '';
source.filename='';

mgenie_globalvars.source=source;


% --------------------------------------------------------------------------------------------------------------
% Initialise units conversion parameters:
% --------------------------------------------------------------------------------------------------------------
unitconv.efix = 0;
unitconv.x1 = 1e-10;
unitconv.emode = 0;

mgenie_globalvars.unitconv=unitconv;


% --------------------------------------------------------------------------------------------------------------
% More specialised constants for analysis programs
% --------------------------------------------------------------------------------------------------------------

% Monitor normalisation parameters: set some sensible values to prevent programs from falling over:
analysis.mon_norm   = 0;        % Default monitor for normalisation
analysis.mon_tlo    = 0;        % Lower time integration limit
analysis.mon_thi    = 0;        % Upper time integration limit
analysis.mon_norm_constant = 0; % Normalisation constant.
                                        % Data will be normalised by monitor counts in units of mon_norm_constant
                                        % i.e. data is divided by (integral/mon_norm_constant)

mgenie_globalvars.analysis=analysis;


% --------------------------------------------------------------------------------------------------------------
% Run setup file, if exists
% --------------------------------------------------------------------------------------------------------------
if nargin>0 && ~isempty(mgenie_setup_file)
    if isstring(mgenie_setup_file)
        [filename,ok]=translate_read(mgenie_setup_file);
        if ok
            try
                if ~isempty(fileparts(filename))    % contains a directory in the name
                    run(filename);
                else
                    run(which(filename));          % run the m file script
                end
            catch
                disp(['WARNING: Unable to run mgenie setup script in ',mgenie_setup_file])
                disp('Error message:')
                disp(lasterr)
            end
        else
            disp (['WARNING: Mgenie setup file ',mgenie_setup_file,' not found'])
        end
    else
        disp('WARNING: The variable that should hold mgenie setup file is not a single character string')
    end
end
