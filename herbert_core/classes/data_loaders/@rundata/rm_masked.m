function [S_m,Err_m,det_m,line_notmasked]=rm_masked(obj,ignore_nan,ignore_inf)
% Method removes failed (NaN or Inf) data from the data array and deletes
% detectors, which provided such signal
%
% Input:
% obj -- initialized rundata object to check for failed detectors
% Optional:
% ignore_nan -- mask detectors with Nan signal. If absent, assumed true
% ignore_inf -- mask detectors with Inf signal. If absent, assumed true
%
% providing both ignore_nan and ignore_inf equal to false, disables masking
%
% Returns:
% S_m     -- masked signal array
% Err_m   -- masked error array
% det_m   -- masked detector structure
% line_notmasked-- the array, containing true where the detectors
%            contribute in final S_m,Err_m and det_m arrays
%
if isempty(obj.S)||isempty(obj.ERR)||isempty(obj.det_par)
    error('HERBERT:rm_masked:invalid_argument',...
    ' signal, error and detectors arrays have to be defined\n');
end
if any(size(obj.S)~=size(obj.ERR))||(size(obj.S,2)~=numel(obj.det_par.x2))
    error('HERBERT:rm_masked:invalid_argument',...
    ' signal error and detectors arrays are not consistent\n');
end
if ~exist('ignore_nan', 'var')
    ignore_nan = true;
end
if ~exist('ignore_inf', 'var')
    ignore_inf = true;
end

if ~(ignore_nan || ignore_inf)
    S_m= obj.S;
    Err_m = obj.ERR;
    det_m = obj.det_par;
    line_notmasked = true(1,size(S_m,2));
    return
end

if ignore_nan && ignore_inf
    index_masked = isnan(obj.S)| isinf(obj.S); % masked pixels
elseif ignore_nan
    index_masked = isnan(obj.S);
elseif ignore_inf
    index_masked = isinf(obj.S);
end
line_notmasked= ~any(index_masked,1);   % masked detectors (for any energy)

if get(hor_config,'log_level')> 1
    [ne,ndet]=size(obj.S);
    nnotmasked = sum(line_notmasked);
    if nnotmasked<ndet
        ndet_mask = ndet-nnotmasked;
        disp(['Masked additional ',num2str(ndet_mask),...
            ' detectors out of total ',num2str(ndet), ' detectors'])
        disp(['This removes      ',num2str(ndet_mask*ne),...
            ' pixels out of total ',num2str(ne*ndet), ' pixels'])
    end
end

S_m  = obj.S(:,line_notmasked);
Err_m= obj.ERR(:,line_notmasked);
det = obj.det_par;
det_fields = fields(det);
det_m = struct();
for i=1:numel(det_fields)
    field = det_fields{i};
    if ~ischar(det.(field))
        array = det.(field);
        det_m.(field) = array(line_notmasked);
    else
        det_m.(field) = det.(field);
    end
end
