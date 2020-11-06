function [ok, mess, sym_out] = cut_sqw_check_sym_arg (sym)
% Checks on symmetry description - check valid, and remove empty descriptions
%
%   >> [ok, mess, sym_out] = cut_sqw_check_sym_arg (sym)
%
% Input:
% ------
%   sym     Symmetry description, or cell array of symmetry descriptions.
%           A symmetry description can be:
%           - Scalar symop object
%           - Array of symop objects (multiple symops to be performed in sequence)
%           - Empty argument (which will be removed)
%
% Output:
% -------
%   ok      True if all OK, false otherwise
%   mess    Error message if not OK; empty string '' otherwise
%   sym_out Cell array of symmetry descriptions, each one a scalar or row vector
%           of symop objects. Empty symmetry descriptions or identity descriptions
%           are removed from the cell array.


ok = true;
mess = '';

if ~iscell(sym), sym = {sym}; end   % make a cell array for convenience
keep = true(size(sym));
for i=1:numel(sym)
    sym{i} = sym{i}(:)';    % make row vector
    if isempty(sym{i}) || (isa(sym{i},'symop') && all(is_identity(sym{i})))
        keep(i) = false;
    elseif ~isa(sym{i},'symop')
        ok = false;
        mess = 'Symmetry descriptor must be an symop object or array of symop objects, or a cell of those';
        sym_out = symop();
        return
    end
end
sym_out = sym(keep);
