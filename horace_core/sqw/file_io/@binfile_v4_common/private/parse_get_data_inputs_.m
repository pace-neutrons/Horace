function argi = parse_get_data_inputs_(varargin)
% take get_data inputs and return them with '-noclass' key appended
%
is_key = cellfun(@(x)(ischar(x)||isstring(x))&&startsWith(x,'-'), ...
    varargin);
if any(is_key)
    is_noclass = ismember('-noclass',varargin(is_key));
    if is_noclass
        argi = varargin;
    else
        argi = [varargin(:);'-noclass'];
    end
else
    argi = varargin;
end
