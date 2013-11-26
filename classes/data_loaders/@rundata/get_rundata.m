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
%   >> [S,Err,en,psi,par] = get_rundata (this,'S','Err','en','psi','par')
%   >> data               = get_rundata (this)
%   >> data               = get_rundata (this,'S','Err','en')
%
%   >> data               = get_rundata (this,'-hor','-nonan')
%   >> data               = get_rundata (this,'par','-horace')
%
%   >> this               = get_rundata (this,'par','-this')
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
%       '-horace'     -- Detector parameters to be returned as a horace 
%    or '-hor'           structure rather then 6 column array.
%                        Cannot be used with '-this' key.
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
%                        Incompatible with '-hor', '-rad', and '-nonan' keys
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
% 1) The data already loaded into memorty.
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
% $Revision$ ($Date$)


% possible modifiers of the data format
keys_recognized={'-hor','-horace','-nonan','-rad','-this'};

if isempty(this.loader)
    error('RUNDATA:invalid_arguments','Can not get data as data loader is not defined for this instance of the class');
end
%
% is input varargin correct (all input fields have to be strings)
if ~iscellstr(varargin)
    error('RUNDATA:invalid_arguments','all input parameters have to be a cell strings');
end

% what is actually defined by this class instance:
% (should be only public fiedls but currenly works with all)
all_fields              = fieldnames(this);
% separate fields and keys
[keys,fields_requested] = split_keys_nonkeys(keys_recognized,all_fields,varargin{:});

% --> CHECK THE CONSISTENCY OF OUTPUT FIELDS
% identify desired form of output:
% when more then one output argument, we probably want the list of
% variables; if only one -- it is structure or class
if nargout==1
    return_structure=true;
else
    return_structure=false;
end
% if there is one field requested to return, it is probably a variable
if numel(fields_requested)==1
    return_structure=false;
end

% check if I want just read data into the class and return this class
return_this =false;
if ismember('-this',keys)
    return_this     = true;
    return_structure= true;
    if nargout>1
        error('RUNDATA:invalid_arguments',' modifying the class structure is not consistent with  more then one output argument\n');
    end
end
% can and if we should delete NaN-s from output data
suppress_nan=false;
if ismember('-nonan',keys)&&any(ismember({'S','ERR','det_par'},fields_requested))
    suppress_nan = true;
    if return_this
        error('RUNDATA:invalid_arguments',' -this and -nonan keys are incompartible\n');
    end
    % for nonan you need S fields
    if (~ismember('S',fields_requested)) && isempty(this.S)
        error('RUNDATA:invalid_arguments',' can not drop NaN values if signal is not defined \n');
    end
end

% --> CHECK THE CONSISTENCY OF THE DATA ITSELF
% what fields are actually needed:?
if isempty(fields_requested) % all data fields are needed
    fields_requested  = what_fields_are_needed(this);
    [is_undef,fields_to_load,fields_from_defaults,undef_fields]=check_run_defined(this);
else       % needed the fields requested by varargin, they have been selected above:
    [is_undef,fields_to_load,fields_from_defaults,undef_fields]=check_run_defined(this,fields_requested);
end
%
if is_undef==2 % run can not be defined by the arguments
    if get(herbert_config,'log_level')>-1
        fprintf('ERROR: ->field:  %s requested but is not defined by the run\n',undef_fields{:});
    end
    error('RUNDATA:invalid_arguments',' data field is not defined by the current instance of the run class ');
end

if is_undef==1 % some data have to be either loaded or obtained from defaults
    data_fields  = {'S';'ERR';'en'};
    data_members = ismember(data_fields ,fields_to_load)';
    if any(data_members)
        data = load_data(this.loader);
        % guard against the situation when data may be inconsistent with header,
        % As all data are loaded any way, we will use newly loaded data to
        % set up all internal fields from loaded data:
        %
        fields_to_load=[fields_to_load;data_fields(~data_members)];
        
        if ~isempty(data.det_par)
            if size(data.S,2) ~= numel(data.det_par) 
                % the detectors are inconsistent with data
                % let's try to reload them
                if ~ismember('det_par',fields_to_load)
                    fields_to_load=[fields_to_load,'det_par'];
                end
            end
        end
    end
    if ismember('det_par',fields_to_load)
        data.det_par = load_par(this.loader);
    end
    for i=1:numel(fields_to_load)
        this.(fields_to_load{i})= data.(fields_to_load{i});
    end
    default_values = get_defaults(this,fields_from_defaults);
    ndef =numel(default_values);
    if ndef==1
        this.(fields_from_defaults{1})= default_values;
    else
        for i=1:ndef
            this.(fields_from_defaults{i})= default_values{i};
        end
    end
end

% Deal with input parameters (keys) ----------------
% if parameters have to be represented as horace structure;
return_horace_format=false;
if any(ismember({'-hor','-horace'},keys))&& ismember('det_par',fields_requested)
    return_horace_format = true;
    if return_this
        error('RUNDATA:invalid_arguments',' -this and -hor keys are incompartible\n');
    end
end

transform_to_rad_requested=false;
if ismember('-rad',keys)
    transform_to_rad_requested=true;
    if return_this
        error('RUNDATA:invalid_arguments',' -this and -rad keys are incompartible\n');
    end
    
end

% modify result to return only detectors and data which not contain NaN and
% Inf
if suppress_nan
    [this.S,this.ERR,this.det_par]=rm_masked(this);
end


[ok,mess,this]=isvalid(this);
if ~ok
    error('RUNDATA:invalid_data',mess);
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
        out.(fields_requested{i})=this.(fields_requested{i});
    end
    if return_horace_format
        out.det_par = get_hor_format(out.det_par,this.loader.par_file_name,this.loader.azimuthal_inverted);
    end
    if transform_to_rad_requested
        out=transform_to_rad(out);
    end
    
    varargout{1}=out;
    
else % return cell array of output variables, defined by the list of
    %  input variables names
    min_num = nargout;
    if numel(fields_requested)<min_num; min_num =numel(fields_requested);end
    
    for i=1:min_num
        varargout{i}=this.(fields_requested{i});
        
        if return_horace_format && strcmp('det_par',fields_requested{i})
            varargout{i} = get_hor_format(varargout{i},this.loader.par_file_name,this.loader.azimuthal_inverted);
        end
        
    end
    if transform_to_rad_requested
        varargout=transform_to_rad([varargout;fields_requested]);
    end
    
end
