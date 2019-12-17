function [varargout] =get_rundata(this,varargin)
% Returns whole or partial data from a rundata object
%
%   >> [val1,val2,...]    = get_rundata (this,nam1,nam2,...)
%   >> data_structure     = get_rundata (this,nam1,nam2,...)
%   >> ...                = get_rundata (...,opt1,opt2,...)
%   >> this               = get_rundata (this,nam1,'-this')
%
% Examples:
%   >> [S,psi]            = get_rundata (this,'S','psi')
%   >> [S,Err,en]         = get_rundata (this,'S','Err','en')
%   >> [S,Err,en,psi,par] = get_rundata (this,'S','Err','en','psi','det_par')
%   >> data               = get_rundata (this)
%   >> data               = get_rundata (this,'S','Err','en')
%
%   >> data               = get_rundata (this,'-nonan','-rad')
%   >> data               = get_rundata (this,'det_par')
%
%   >> this               = get_rundata (this,'det_par','-this')
%
% Input:
% ------
%   this            An instance of the rundata class
%
%   nam1,nam2,...   Names of valid fields of the rundata class
%                   Type >> rundata to get a listing of the valid field names
%
%   opt1,opt2       Optional key modifiers (begin with '-') that control
%                   the format of the output:
%
%       '-nonan'      -- Signals, errors and corresponding detectors values
%                        which are undefined (have values NaN) are removed.
%                        Cannot be used with '-this' key.
%
%       '-rad'        -- Transform known angular values into radians;
%                        Cannot be used with '-this' key.
%
%       '-this'       -- Explicitly requests to modify input class data and
%                        return these data as output argument.
%                        Incompatible with  '-nonan' and '-rad' keys as
%                        these keys request changes in the data structure and '-this'
%                        loads the data into memory in the form, they are present in a
%                        file
%
%                        If more then one output argument is supplied to
%                        the function, this key is ignored;
%
%                        Error is thrown if more then one output argument
%                        is requested in this case
%
% Output:
% -------
%   val1,val2,...   Returned values for fields names nam1,nam2,... in the order the
%                   names were given
%
%   data_structure  Structure with field names matching nam1,nam2,.. and with
%                   values val1,val2,...
%
%   this            Modified input instance of rundata class
%
%
%
% Notes:
% ------
% The experiment data can have three locations:
% - loaded into memory
% - stored on disk
% - have defaults defined by rundata_config
%
% The function retrieves the requested data as follows:
% 1) The data already loaded into memory.
% 2) The data present in the spe and par file or their equivalents, when
%    the data are loaded to memory and returned
% 3) If 1) and 2) is not possible, method tries to retrieve defaults values
%
% then:
% 4) Error is thrown if some data fields are not present in file, have not
%    been set before and do not have defaults, but are mentioned in the
%    input parameters list

% $Author: Alex Buts 20/10/2011
%
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)


% possible modifiers of the data format
keys_recognized={'-nonan','-rad','-this'};

if isempty(this.loader)
    error('RUNDATA:invalid_arguments','Can not get data as data loader is not defined for this instance of the class');
end
%
% is input varargin correct (all input fields have to be strings)
if ~iscellstr(varargin)
    error('RUNDATA:invalid_arguments','all input parameters have to be a cell strings');
end

% what is actually defined by this class instance:
% (should be only public fields but currently works with all)
[ok,mess,suppress_nan,get_rad,return_this,fields_requested] = parse_char_options(varargin,keys_recognized);
if(~ok)
    error('RUNDATA:invalid_arguments',mess);
end
[all_fields,lattice_fields] = what_fields_are_needed(this,'all_fields');
if return_this && isempty(fields_requested)
    fields_requested=all_fields;
end

non_fields =~ismember(fields_requested,all_fields);
if any(non_fields)
    error('RUNDATA:invalid_arguments',[' missing fields requested: ',fields_requested{non_fields}]);
end
if ~isempty(lattice_fields)
    in_latice = ismember(lattice_fields,fields_requested);
    lattice_fields = lattice_fields(in_latice);
end
% --> CHECK THE CONSISTENCY OF OUTPUT FIELDS
% identify desired form of output:
% when more then one output argument, we probably want the list of
% variables; if only one -- it is structure or class
if nargout==1
    return_structure=true;
    if numel(fields_requested)==1 && ~return_this
        return_structure = false;
    end
else
    return_structure=false;
end

% check if I want just read data into the class and return this class

if return_this
    if nargout>1
        error('RUNDATA:invalid_arguments',' modifying the class structure is not consistent with  more then one output argument\n');
    end
end
% can and if we should delete NaN-s from output data

if return_this
    if suppress_nan
        error('RUNDATA:invalid_arguments',' -this and -nonan keys are incompatible\n');
        % for nonan you need S fields
    end
    if get_rad
        error('RUNDATA:invalid_arguments',' -this and -rad keys are incompatible\n');
    end
end
if ~ismember('S',fields_requested) && suppress_nan
    error('RUNDATA:invalid_arguments',' can not drop NaN values if signal is not defined/not requested \n');
end



% --> CHECK THE CONSISTENCY OF THE DATA ITSELF
% what fields are actually needed:?
if isempty(fields_requested) && ~return_this % all data fields are needed
    fields_requested  = what_fields_are_needed(this);
    [is_undef,fields_to_load,undef_fields]=check_run_defined(this,fields_requested);
    
else       % needed the fields requested by varargin, they have been selected above:
    [is_undef,fields_to_load,undef_fields]=check_run_defined(this,fields_requested);
end
%
if is_undef==2 % run can not be defined by the arguments
    if get(herbert_config,'log_level')>-1
        fprintf('ERROR: ->field:  %s requested but is not defined by the run\n',undef_fields{:});
    end
    error('RUNDATA:invalid_arguments',' data field is not defined by the current instance of the run class ');
end

if is_undef==1 % some data have to be either loaded or obtained from defaults
    data_fields  = {'S';'ERR'};
    data_members = ismember(data_fields ,fields_to_load)';
    loader = this.loader;
    if any(data_members)
        loader = loader.load_data();
        % guard against the situation when data may be inconsistent with header,
        % As all data are loaded any way, we will use newly loaded data to
        % set up all internal fields from loaded data:
        %
        fields_to_load=[fields_to_load;data_fields(~data_members)];
        
        if ~isempty(loader.det_par)
            [ok,mess] = loader.is_loader_valid();
            if ~ok % detectors are non-consistent with data
                error('RUNDATA:invalid_arguments',mess)
            end
        end
    end
    if ismember('det_par',fields_to_load)
        [dummy,loader] = loader.load_par();
    end
    this.loader__=loader;
    loader_defines = loader.loader_can_define();
    loader_dep = ismember(fields_to_load,loader_defines);
    fields_to_load = fields_to_load(~loader_dep);
    if numel(lattice_fields)>0
        loader_lattice_fields=ismember(lattice_fields,loader_defines);
        % copy lattice parameter which loader defines, if lattice
        % parameters are not already defined
        if any(loader_lattice_fields)
            lattice_in_loader=lattice_fields(loader_lattice_fields);
            for i=1:numel(lattice_in_loader) 
                % set rundata value using field in loader only if loader
                % field is empty. Necessary when gen_sqw redefines fields,
                % stored in the data file (e.g. uses different psi wrt psi
                % in nxspe file
                this=set_lattice_field(this,lattice_in_loader{i},loader.(lattice_in_loader{i}),'-ifempty');
            end
        end
    end
    for i=1:numel(fields_to_load)
        field = fields_to_load{i};
        this.(field)= loader.(field);
    end
end


% Deal with input parameters (keys) ----------------
% if parameters have to be represented as horace structure;
if get_rad
    this.lattice.angular_units = 'rad';
end

% modify result to return only detectors and data which not contain NaN and
% Inf
if suppress_nan
    [this.S,this.ERR,this.det_par]=rm_masked(this);
end

% what and how to return the result
if return_structure
    if return_this
        varargout{1}=this;
        return;
    else
        out=struct();
    end
    for i=1:numel(fields_requested)
        out.(fields_requested{i})=get_field(this,fields_requested{i});
    end
    varargout{1}=out;
    
else % return cell array of output variables, defined by the list of
    %  input variables names
    min_num = nargout;
    if numel(fields_requested)<min_num; min_num =numel(fields_requested);end
    
    for i=1:min_num
        varargout{i}=get_field(this,fields_requested{i});
    end
    
end

