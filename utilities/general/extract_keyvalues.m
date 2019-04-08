function [keyval,data]=extract_keyvalues(arglist,keywords)
% Extract keyword-value pairs from a list of input parameters
%
%   >> [keyval,data_out] = extract_keyvalues (data_in,keywords)
%
% Input:
% ------
%   arglist     Cellarray (row) of arguments that contains data and
%               keyword-value pairs. These items can be interspersed i.e.
%               has in general the form e.g.
%                   data={something1,key1,val1,something2,key2,val2,key3,val3...}
%   keywords    Cellarray of permissible keywords e.g.
%                   keys = {key1,key2,key3...}
%
% Output:
% -------
%   keyval      Cell array containing the extracted keyword-value pairs
%                   {key1,val1,key2,val2,key3,val3...}
%
%   data        Arguments that do not follow keywords:
%                   {something1,something2,...}
%
%
% Throws an error if a key is not followed by a value e.g:


% Original author: A.Buts
%
% $Revision:: 830 ($Date:: 2019-04-08 16:16:02 +0100 (Mon, 8 Apr 2019) $)


% Catch case of empty data cell array
if numel(arglist) == 0
    keyval=cell(1,0);
    data = cell(1,0);
    return;
end

% Get locations of keywords and values
keys_check = @(x)iskey(x,keywords);
keys_present = cellfun(keys_check,arglist);

vals_present = false(1,numel(keys_present));
vals_present(2:end) = keys_present(1:end-1);

collisions = vals_present&keys_present;
if any(collisions)
    error('EXTRACT_KEYVALUES:invalid_argument',' some keys do not have values attached');
end

keyval_present = vals_present|keys_present;

% Fill output arguments
keyval = arglist(keyval_present);
data       = arglist(~keyval_present);

%------------------------------------------------------------------------------
function is = iskey(val,keys)
if ~isempty(val) && is_string(val)
    is = any(ismember(keys,val));
else
    is = false;
end
