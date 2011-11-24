classdef rundata
% The class describes single processed run used in Horace and Mslice
% It used as an interface to load processed run data from any file format
% supported and to verify that all data necessary for the run 
% are availible either from the file itself or from the parameters,
% supplied with the file. 
%
% If some parameters, which describe the run are missing from the 
% file format used, the user have to provide these parameters to the
% constructor, or set them later (e.g. efix=10); 
%
% The data consitency is not verified by the class -- the class method
% verify if data are loaded. 
% 
%  
% $Revision: -1 $ ($Date: $)
%
 properties
% Experiment parameters;
   S         = [];  % Array of signals        -- obtained from speFile or equivalent
   ERR       = [];  % Array of errors         -- obtained from speFile or equivalent
   efix      = [];  % input beam energy meV         -- has to be in file or supplied  as  parameters list     
                    % (has to be larger then maximal scattered energy max(en) 
   en        = [];  % list of transferred energies  -- obtained from speFile or equivalent
     
% Detectors parameters:
   n_detectors = []; % number of detectors, used when dealing with masked detectors   -- will be derived    
   det_par     = []; % array of par-values, describing detectors angular positions    -- usually obtained from parFile or equivalent ;   

   % by default, the data are obtained for crystal, but powder can be
   % different and request different fields to be defined;
   is_crystal   = [];
% Crystal parameters             
    alatt     =[];  % Lattice parameters (Ang^-1)   -- has to be in file or supplied  as  parameters list
    angldeg   =[];  % Lattice angles (deg)          -- has to be in file or supplied  as  parameters list
 % goniometer parameters
   psi   = [];     %  Angle of u w.r.t. ki (deg)                          --- default value 0      
   omega = [];     %  Angle of axis of small goniometer arc w.r.t. notional u (deg) 
   dpsi  = [];     %  Correction to psi (deg)            
   gl    = [];     %  Large goniometer arc angle (deg) 
   gs    = [];     %  Small goniometer arc angle (deg)  
   %
   %%---  INTERNAL SERVICE PARAMETERS: (private read, private write in new
   %       Matlab versions)
   % this is the class which provides actual data loading from correspondent data format;
   loader = ''; 
   % the name of the file, where data have to be loaded from;   
   data_file_name='';  % service variable, needed by the program, as if it is not empty, the loader will be redefined
   % the name of the file, where detector parameters have to be loaded from;      
   par_file_name='';   % service variable, needed by the program, as if it is not empty, the parameters have to be redefined;
   % The file extentions possible to load at the moment 
   supported_extensions = {'.spe','.spe_h5','.nxspe'}; 
   % list of fields which have default values and do not have to be always
   % defined by either file or command arguments; The default values for these
   % fields are defined by rundata_config
   fields_have_defaults  = {'omega','dpsi','gl','gs','emode'};
   %
 end    
%   
methods
    function this=rundata(varargin)
    % run_data class constructor
    %
    % usages:
    %>>run=run_data(nxspe_file_name);    
    %               nxspe_file_name -- the name of nxspe file with data
    % 
    %>>run=run_data(run_data,speFileName,key,value,key,value,....)
    %               where the 'key', 'value' are the pairs of keys and valudes from the list
    %               of the class field names and with correspondent values,
    %               described below
    %>>run=run_data(run_data,speFileName,data_structure)
    %               where the data structure has fields with values, equivalend to the 
    %               keys and values described above    
    %where:                            
    % speFileName  -- Full file name of ASCII spe file 
    % parFileName  -- Full file name of detector parameter file (Tobyfit format)
%   The keys (names of the fields), whcih can be present in the list of the
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
% % goniometer parameters
%   psi       %  Angle of u w.r.t. ki (deg)                          --- default value 0      
%   omega     %  Angle of axis of small goniometer arc w.r.t. notional u (deg) 
%   dpsi      %  Correction to psi (deg)            
%   gl        %  Large goniometer arc angle (deg) 
%   gs        %  Small goniometer arc angle (deg)  
%   %

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
        this.is_crystal=get(rundata_config,'is_crystal');
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
function this=build_from_struct(this,a_struct,varargin)
        set_fields     = fieldnames(a_struct);
        present_fields = fieldnames(this);
        if ~any(ismember(set_fields,present_fields))
                error('RUNDATA:invalid_argument',' attempting to set field %s but such field does not exist in run_data class\n',set_fields{ismember(set_fields,present_fields)});            
        end
        for i=1:numel(set_fields)
            if ~isempty(a_struct.(set_fields{i}))
                this.(set_fields{i})=a_struct.(set_fields{i});          
            end
        end
        
        this=parse_arg(this,varargin{:});
end



%-----------------------------------------------------------------------------------------------------------
    function this= build_from_speClass(this,varargin)         
        error('RUNDATA:not_implemented','build_from_speClass not implemented yet');
    end
    
    end % methods
end % classdet
