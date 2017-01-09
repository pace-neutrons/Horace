function obj = output_clear_ (obj)
% Clear output properties

if obj.output_ok_
    obj.output_ok_      = false;
    obj.data_out_       = cell(1,0);
    obj.is_fit_         = false;
    obj.is_simulation_  = false;
    obj.pf_             = zeros(0,1);
    obj.sig_            = zeros(0,0);
    obj.cor_            = zeros(0,0);
    obj.chisqr_         = NaN;
    obj.converged_      = false;
    obj.message_        = '';
end
