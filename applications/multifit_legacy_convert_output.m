function fitpar_out = multifit_legacy_convert_output (fitpar_in)
% Convert original multifit fit parameter output to that for latest multifit version
%
%   >> fitpar_out = test_multifit_legacy_convert_output (fitpar_in)
%
% Checks that the input is indeed multifit output by checking structure field names
% If it is not, then simply passes the input through unchanged

fitpar_out=fitpar_in;
if isstruct(fitpar_in) && all(isfield(fitpar_in,{'p','sig','corr','chisq'}))  % output will always have these fields
    for i=1:numel(fitpar_in)
        if isfield(fitpar_in,'bpnames') && iscell(fitpar_in(i).bpnames)&&numel(fitpar_in(i).bpnames)==1
            fitpar_out(i).bpnames=fitpar_in(i).bpnames{1};
        end
        if isfield(fitpar_in,'bp')&&iscell(fitpar_in(i).bp)&&numel(fitpar_in(i).bp)==1
            fitpar_out(i).bp=fitpar_in(i).bp{1};
        end
        if isfield(fitpar_in,'bsig')&&iscell(fitpar_in(i).bsig)&&numel(fitpar_in(i).bsig)==1
            fitpar_out(i).bsig=fitpar_in(i).bsig{1};
        end
    end
end
