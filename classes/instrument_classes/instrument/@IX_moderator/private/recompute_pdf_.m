function pdf = recompute_pdf_ (obj)
% Compute the pdf_table object for the moderator pulse shape
%
%   >> pdf = recompute_pdf_ (moderator)
%
% Input:
% -------
%   moderator   IX_moderator object (scalar only)
%
% Output:
% -------
%   pdf         pdf_table object


if ~isscalar(obj), error('Function only takes a scalar moderator object'), end
if ~obj.valid_
    error('Moderator object is not valid')
end

models= obj.pulse_models_;
model = obj.pulse_model_;

if models.match('ikcarp',model)
    pdf = ikcarp_recompute_pdf (obj.pp_);
    
elseif models.match('ikcarp_param',model)
    pdf = ikcarp_param_recompute_pdf (obj.pp_, obj.energy_);
    
else
    error('Unrecognised moderator pulse model for computing pdf_table')
end
