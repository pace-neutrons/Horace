function urange = rundata_find_urange(run_files,varargin)
% Find range of data in crystal Cartesian coordinates
%
%   >> urange = rundata_find_urange(run_files)
%
% Input:
% ------
%   run_files 	Cell array of initiated rundata objects
%   emin, emax  Optional energy range to calculate limits
%
% Output:
% -------
%   urange    	2x4 array, describing min-max values in momentum/energy
%              transfer, in crystal Cartesian coordinates and meV. Uses bin centres.
%
% Suppress log messages while calculating urange, as it should be very
% quick by desighn.
%
% $Revision$ ($Date$)
%

hc = hor_config();
log_level = hc.log_level;
clob = onCleanup(@()(set(hc,'log_level',log_level)));
hc.log_level = -1;

%
nfiles = numel(run_files);
if log_level > 0
    fprintf('*** Calculating the q-dE ranges for %d input runfiles -->',nfiles);
end

% Get the maximum limits along the projection axes across all spe files
urange=[Inf, Inf, Inf, Inf;-Inf,-Inf,-Inf,-Inf];
for i=1:nfiles
    urange1=run_files{i}.calc_urange(varargin{:});
    urange = [min(urange(1,:),urange1(1,:)); max(urange(2,:),urange1(2,:))];
end
if log_level > 0
    fprintf('*** <--- completed\n');
end
if log_level>1
    fprintf('*** Range:\n');
    disp(urange);
end
