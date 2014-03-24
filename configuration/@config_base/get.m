function varargout= get(this,varargin)
% Get values of one or more fields from a configuration class
%
%   >> S = get(config_obj)      % returns a structure with the current values
%                               % of the fields in the requested configuration object
%

%   >> S = get(config_obj,'defaults')   % returns the defaults this
%                                       % configuration has
%
%   >> [val1,val2,...] = get(config_obj,'field1','field2',...); % returns named fields
%
%
%
% This is deprecated function kept for compatibility with old interface

% $Revision: 287 $ ($Date: 2013-11-08 18:47:25 +0000 (Fri, 08 Nov 2013) $)
options = {'-public','defaults'};
[ok,mess,public,defaults,other]=parse_char_options(varargin,options);
if ~ok; error('CONFIG_BASE:get',mess); end
% public field is not currently used
if defaults
    this.return_defaults = true;
end
if numel(other) == 0 % form 1
    S = struct();
    fields =  this.get_storage_field_names();
    for i=1:numel(fields)
        field = fields{i};
        S.(field) = this.(field);
    end
    varargout{1} = S;
    return;
end

n_calls = min(numel(other),nargout);
for i=1:n_calls
    varargout{i} = this.(other{i});
end

