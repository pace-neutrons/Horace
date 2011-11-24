function [S_m,Err_m,det_m]=rm_masked(this)
% method removes failed (NaN or Inf) data from the data array and deletes 
% detectors, which provided such signal
%
if isempty(this.S)||isempty(this.ERR)||isempty(this.det_par)
    error('RUNDATA:rm_masked',' singal, error and detectors arrays have to be defined\n');
end
if any(size(this.S)~=size(this.ERR))||(size(this.S,2)~=size(this.det_par,2))
    error('RUNDATA:rm_masked',' singal error and detectors arrays are not consistent\n');    
end

index_masked = (isnan(this.S)|(isinf(this.S))); % masked pixels
line_notmasked= ~any(index_masked,1);             % masked detectors (for any energy)

S_m  = this.S(:,line_notmasked);
Err_m= this.ERR(:,line_notmasked);
det_m= this.det_par(:,line_notmasked);
