function [varargout] =get_rundata(this,varargin)
% function returns the results of an inelastic experiment 
% defined by the run_data class. 
%
% usage: 
%>> [S,psi]            = get_run_data(this,'S','psi')
%>> [S,Err,en]         = get_run_data(this,'S','Err','en')
%>> [S,Err,en,psi,par] = get_run_data(this,'S','Err','en','psi','par')
%>> data               = get_run_data(this)
%>> data               = get_run_data(this,'S','Err','en')
%
%>> data               = get_run_data(this,'-hor','-nonan')
%>> data               = get_run_data(this,'par','-horace')
%  
%   the form with more then one output argument returns run data as list of
%   variables. The sequence of variables can be obtained from the function 
% 
%   last form returns run data as the structure with all defined in the class fields. 
% 
% '-horace' or '-hor' --optional parameter requesting the detectors
%                        parameters to be returned as a horace structure
%                        rather then 6 column array
% '-nonan'            -- optional parameter requesting not to return
%                        signals,errors  and correspondent detectors values 
%                        wich are undefined (have values NaN)
% '-rad'              -- transform known angular values into radians;
%
% The experiment data can have three locations:
% a) loaded into memory, b) stored on hdd, c) have defaults (stored in
%                                            rundata_config)
% The function returns requested data as follows. 
% 1) The data loaded to memorty if avail.
% 2) The data present in the spe and par file or their equivalents
%    The data are loaded to memory
% 3) If 1) and 2) are not present, defaults attempted
%
% 4) Error is thrown if some data fields are not present in file, have not
%    been defined before and do not have defaults, but are requested by the
%    parameters list
%
%
% $Author: Alex Buts 20/10/2011
% 
% 
% $Revision:  $ ($Date:  $)
%
% possible modifiers of the data format
keys_recognized={'-hor','-horace','-nonan','-rad'};

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


% what fields are actually needed:?
if isempty(fields_requested) % all data fields are needed
    fields_requested  = what_fields_are_needed(this);
    [is_undef,fields_to_load,fields_from_defaults,undef_fields]=check_run_defined(this);     
else       % needed the fields requested by varargin, they have been selected above:
    [is_undef,fields_to_load,fields_from_defaults,undef_fields]=check_run_defined(this,fields_requested); 
end
% 
if is_undef==2 % run can not be defined by the arguments
    fprintf('ERROR: ->field:  %s requested but is not defined by the run\n',undef_fields{:});    
    error('RUNDATA:invalid_arguments',' data field is not defined by the current instance of the run class ');
end

if is_undef==1 % some data have to be either loaded or obtained from defaults
    if any(ismember({'S','ERR','en'},fields_to_load))
        data = load_data(this.loader);
    end
    if ismember('det_par',fields_to_load)
        data.det_par = load_par(this.loader);
    end
    for i=1:numel(fields_to_load)
        this.(fields_to_load{i})= data.(fields_to_load{i});
    end
    for i=1:numel(fields_from_defaults)
        this.(fields_from_defaults{i})= get(rundata_config,fields_from_defaults{i});        
    end
end

% Deal with input parameters (keys) ----------------
% if parameters have to be represented as horace structure;
return_horace_format=false;
if any(ismember({'-hor','-horace'},keys))&& ismember('det_par',fields_requested)
    return_horace_format = true;
end
% the boolean checks if all data are requested
suppress_nan=false;
if ismember('-nonan',keys)&&any(ismember({'S','ERR'},fields_requested))
    suppress_nan = true;
    error('RUNDATA:not_implemented','not yet implemented')
end



% what and how to return as the result
if nargout==1
    out=struct();
    for i=1:numel(fields_requested)
        out.(fields_requested{i})=this.(fields_requested{i});
    end
    if return_horace_format 
        out.det_par = get_hor_format(out.det_par,this.loader.par_file_name);
    end
    if ismember('-rad',keys)
        out=transform_to_rad(out);
    end
    
    varargout{1}=out;
    
elseif nargout>1
    min_num = nargout;
    if numel(fields_requested)<min_num; min_num =numel(fields_requested);end
    
    for i=1:min_num
        varargout{i}=this.(fields_requested{i});
        
        if return_horace_format && strcmp('det_par',fields_requested{i})
            varargout{i} = get_hor_format(varargout{i},this.loader.par_file_name);
        end
       
    end
    if ismember('-rad',keys)
        varargout=transform_to_rad([varargout;fields_requested]);
    end
    
end

  

    



