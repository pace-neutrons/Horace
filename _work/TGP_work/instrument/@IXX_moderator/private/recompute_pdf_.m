function pdf = recompute_pdf_ (self)
% Compute the pdf_table object for the moderator pulse shape
%
%   >> pdf = recompute_pdf_ (moderator)
%
% Input:
% -------
%   moderator   IX_sample object (scalar only)
%
% Output:
% -------
%   pdf         pdf_table object


if ~isscalar(self), error('Function only takes a scalar moderator object'), end
if ~self.valid_
    error('Moderator object is not valid')
end

models= self.pulse_models_;
model = self.pulse_model_;

if models.match('ikcarp',model)
    pdf = ikcarp_recompute_pdf (self.pp_);
    
elseif models.match('ikcarp_param',model)
    pdf = ikcarp_param_recompute_pdf (self.pp_, self.energy_);
    
else
    error('Unrecognised moderator pulse model for computing pdf_table')
end
