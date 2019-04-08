function obj = append_data(obj,varargin)
% Append datasets to the list of current datasets
%
% If data in the form of objects is expected:
%   >> obj = obj.append_data (w1,w2,...)    % Append objects or arrays of objects
%
% If x,y,e data is valid (i.e. datasets are not required to be objects)
%   >> obj = obj.append_data (x,y,z)        % If valid: append x,y,e, data
%   >> obj = obj.append_data (w1,w2,...)    % Set cell arrays or structures of
%                                           % x,y,e, data
% For more details about data formats see <a href="matlab:help('mfclass/set_data');">set_data</a>
%
%
% In addition, portions of the data sets can be masked using one or more of
% the optional keyword-value pairs (keyword-value pairs can appear in any order):
%
%   >> obj = obj.replace_data (...'keep', xkeep, 'remove', xremove, 'mask', mask)
%
% For full details of the syntax, see <a href="matlab:help('mfclass/set_mask');">set_mask</a>
%
%
% See also remove_data replace_data set_data
 

% Note for developers:
%   >> obj = obj.append_data ()             % Inert operation: does nothing
%   >> obj = obj.append_data ([])           % Inert operation: does nothing


% Original author: T.G.Perring 
% 
% $Revision:: 830 ($Date:: 2019-04-08 17:54:30 +0100 (Mon, 8 Apr 2019) $)


% Trivial case of no input arguments; just return without doing anything
if numel(varargin)==0, return, end

% Find arguments and optional arguments
keyval_def = struct('keep',[],'remove',[],'mask',[]);
[args,keyval,present,~,ok,mess] = parse_arguments (varargin, keyval_def);
if ~ok, error(mess), end
if isempty(args) && any(cellfun(@logical,struct2cell(present)))
    error('Syntax error: no input data was given but optional arguments were provided')
end

% Check input
class_name = obj.dataset_class_;
[ok, mess, w] = is_valid_data (class_name, args{:});
if ~ok, error(mess), end

% Check optional arguments
[ok,mess,xkeep,xremove,msk] = mask_syntax_valid (numel(w), keyval.keep, keyval.remove, keyval.mask);
if ~ok, error(mess), end

% Create mask arrays
[msk_out,ok,mess] = mask_data (w,[],xkeep,xremove,msk);
if ok && ~isempty(mess)
    display_message(mess)
elseif ~ok
    error_message(mess)
end


% Set object properties
% ---------------------
% The following should work even if no data sets are appended
ndatatot_init = obj.ndatatot_;  % keep current value

% Set data properties
if isempty(obj.data_)
    obj.data_ = args;
    obj.w_ = w;
    obj.msk_ = msk_out;
else
    if numel(obj.data_)==3 && ndatatot_init==1  % data is {x,y,e}
        obj.data_ = {obj.data_};
    end
    if numel(args)==3 && numel(w)==1        % new data is {x,y,e}
        args = {args};
    end
    obj.data_ = [obj.data_, args];
    obj.w_ = [obj.w_, w];
    obj.msk_ = [obj.msk_, msk_out];
end

% Append function properties
% (Only need to append properties if datasets have been added)
% Note that constraints properties do not need to be changed, as the default
% is that the additional default functions do not have any parameters)
if numel(w)>0
    Sfun = obj.get_fun_props_;
    if obj.foreground_is_local_
        Sfun = functions_append (Sfun, true, numel(w));
    elseif ndatatot_init==0     % no data initially, so must add global function
        Sfun = functions_append (Sfun, true, 1);
    end
    if obj.background_is_local_
        Sfun = functions_append (Sfun, false, numel(w));
    elseif ndatatot_init==0
        Sfun = functions_append (Sfun, false, 1);
    end
    obj = obj.set_fun_props_(Sfun);
end
