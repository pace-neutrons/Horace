function this=rundata(varargin)
% The class describes single processed run used in Horace and Mslice
% It used as an interface to load processed run data from any file format
% supported and to verify that all data necessary for the run 
% are availible either from the file itself or from the parameters,
% supplied with the file. 
%
% If some parameters, which describe the run are missing from the 
% file format used, the user have to provide these parameters to the
% constructor, or set them later (e.g. rundata.efix=10); 
%
% The data availability is not verified by the class constructor 
% -- the class method % "get_rundata"
% used to verify if data are availible and to actually load data from the
% file.
%
% IF the data are not defined by the user, can not be found in the file and
% do not have default, the method get_rundata will fail
% 
%  
% $Revision$ ($Date$)
%

    %>>run=run_data(run_data,speFileName,key,value,key,value,....)
    %               where the 'key', 'value' are the pairs of keys and values from the list
    %               of the class field names and with corresponding values,
    %               described below
    %>>run=run_data(run_data,speFileName,data_structure)
    %               where the data structure has fields with values, equivalend to the 
    %               keys and values described above    
    %where:                            
    % speFileName  -- Full file name of ASCII spe file 
    % parFileName  -- Full file name of detector parameter file (Tobyfit format)
    
   %   The keys (names of the fields), which can be present in the list of the
   %   class parameters are:
   % %  Experiment parameters;
   %   S          % Array of signals        -- obtained from speFile or equivalent
   %   ERR        % Array of errors         -- obtained from speFile or equivalent
   %   efix       % input beam energy meV         -- has to be in file or supplied  as  parameters list     
   %                    % (has to be larger then maximal scattered energy max(en) 
   %   en         % list of transferred energies  -- obtained from speFile or equivalent
   %     
   % % Detectors parameters:
   %   n_detectors % number of detectors, used when dealing with masked detectors   -- will be derived    
   %   det_par      % array of par-values, describing detectors angular positions    -- usually obtained from parFile or equivalent ;   
   %
   %   % by default, the data are obtained for crystal, but powder can be
   %   % different and request different fields to be defined;
   %   is_crystal  
   % % Crystal parameters             
   %    alatt     % Lattice parameters (Ang^-1)   -- has to be in file or supplied  as  parameters list
   %    angldeg   % Lattice angles (deg)          -- has to be in file or supplied  as  parameters list
   %
   % % goniometer parameters
   %   psi       %  Angle of u w.r.t. ki (deg)                          --- default value 0      
   %   omega     %  Angle of axis of small goniometer arc w.r.t. notional u (deg) 
   %   dpsi      %  Correction to psi (deg)            
   %   gl        %  Large goniometer arc angle (deg) 
   %   gs        %  Small goniometer arc angle (deg)  
	%classdef rundata
	run=struct;
	% Experiment parameters;
	run.S         = [];  % Array of signals        -- obtained from speFile or equivalent
	run.ERR       = [];  % Array of errors         -- obtained from speFile or equivalent
	run.efix      = [];  % input beam energy meV   -- has to be in file or supplied  as  parameters list     
                    % (has to be larger then maximal scattered energy max(en) 
	run.en        = [];  % list of transferred energies  -- obtained from speFile or equivalent
	run.emode     = [];  % measurement mode, has default 1 (direct mode)
     
 % Detectors parameters:
	run.n_detectors = []; % number of detectors, used when dealing with masked detectors   -- will be derived    
	run.det_par     = []; % array of par-values, describing detectors angular positions    -- usually obtained from parFile or equivalent ;   
   % by default, the data are obtained for crystal, but powder can be
   % different and request different fields to be defined;
	run.is_crystal   = [];
 % Crystal parameters             
	run.alatt     =[];  % Lattice parameters (Ang^-1)   -- has to be in file or supplied  as  parameters list
	run.angldeg   =[];  % Lattice angles (deg)          -- has to be in file or supplied  as  parameters list
	% Crystal position wrt to input beam
	run.u         = [];
	run.v         = [];
	% goniometer parameters
	run.psi   = [];     %  Angle of u w.r.t. ki (deg)                          --- default value 0      
	run.omega = [];     %  Angle of axis of small goniometer arc w.r.t. notional u (deg) 
	run.dpsi  = [];     %  Correction to psi (deg)            
	run.gl    = [];     %  Large goniometer arc angle (deg) 
	run.gs    = [];     %  Small goniometer arc angle (deg)     
   %
   %%---  INTERNAL SERVICE PARAMETERS: (private read, private write in new
   %       Matlab versions)
   % this is the class which provides actual data loading from correspondent data format;
	run.loader = ''; 
   % the name of the file, where data have to be loaded from;   
	run.data_file_name='';  % service variable, needed by the program, as if it is not empty, the loader will be redefined
   % the name of the file, where detector parameters have to be loaded from;      
	run.par_file_name='';   % service variable, needed by the program, as if it is not empty, the parameters have to be redefined;
   % The file extentions possible to load at the moment 
	run.supported_extensions = {'.spe','.spe_h5','.nxspe'}; 
   % list of fields which have default values and do not have to be always
   % defined by either file or command arguments;
	run.fields_have_defaults  = {'omega','dpsi','gl','gs','emode','is_crystal','u','v'};
   % The default values for these fields are as follows:
	run.the_fields_defaults   = {0,0,0,0,1,true,[1,0,0],[0,1,0]};
   %
    this=class(run,'rundata');
   
    if nargin>0
        if isstruct(varargin{1}) 
            if nargin>1
                this=build_from_struct(this,varargin{1},varargin{2:end});
            else
                this=build_from_struct(this,varargin{1});                
            end
        elseif isa(varargin{1},'rundata') % copy constructor with modifications
            if nargin>1
                this= build_from_struct(this,varargin{1},varargin{2:end});
            else
                this=varargin{1};
            end
        elseif isa(varargin{1},'spe')        % build from spe class with modifications
               this= build_from_speClass(this,varargin{2:end});           
        else     % construct run data from the input parameters, assuming the first parameter is a file_name
               this=select_loader(this,varargin{:});
        end
        % check if some fields redefinition by command line arguments cause
        % to chande/adapt loader accordingly;
        this=check_loader_redefined(this);               
    end   
    % set default type to crystal if it has not been defined by input
    % parameters;
    if isempty(this.is_crystal)
        this.is_crystal=get_defaults(this,'is_crystal');
    end    
end
% NOT YET IMPLEMENTED:     
   %>>run=run_data(speFileName,parFileName,efix,alatt,andgdeg,varargin) ;
    %               The option with two filenames and list of parameters,
    %               describing the run and provided in the specific order,
    %               where the position specifies the parameter value
    %               The order is:
    %  efix   -- input beam energy meV 
    %  alatt  -- 3-vector of lattice parameters (A^-1)
    %  angdeg -- 3-vector of angles between the lattice cell edges (in degrees)

%-----------------------------------------------------------------------------------------------------------
%end % classdet
