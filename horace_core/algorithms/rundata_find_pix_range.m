function pix_range = rundata_find_pix_range(run_files,varargin)
% Find range of data in crystal Cartesian coordinates
%
%   >> pix_range = rundata_find_pix_range(run_files)
%
% Input:
% ------
%   run_files 	Cell array of initiated rundata objects
%   emin, emax  Optional energy range to calculate limits
%
% Output:
% -------
%   pix_range  2x4 array, describing min-max values in momentum/energy
%              transfer, in crystal Cartesian coordinates and meV.
%              Uses bin centres of energy bins and q-coordinates
%              corresponding to these centres
%



% Suppress log messages while calculating pix_range, as it should be very
% quick by design.
hc = hor_config();
log_level = hc.log_level;
clob = onCleanup(@()(set(hc,'log_level',log_level)));
hc.log_level = -1;

%
nfiles = numel(run_files);
% Get the maximum limits along the projection axes across all spe files
pix_range=PixelDataBase.EMPTY_RANGE_;

for i=1:nfiles
    pix_range1=...
        run_files{i}.calc_pix_range(varargin{:},'-ignore_transf');
    pix_range = [min(pix_range(1,:),pix_range1(1,:));...
        max(pix_range(2,:),pix_range1(2,:))];
end
