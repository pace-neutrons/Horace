function [ok,mess] = write_ascii (w, varargin)
% Writes IX_dataset_1d or array of IX_dataset_1d to an ascii file. Inverse of read_ascii.
%
% Identical to save_ascii; type >> help IX_dataset_1d\save_ascii  for full help.
%
% Included only for backwards compatibility

[ok,mess] = save_ascii (w, varargin{:});

% Ensure that if no arguments, do not get any output (otherwise from command line
% a succesful >> write_acsii(w) would print "ans = 1")
if nargout==0
    clear ok mess
end
