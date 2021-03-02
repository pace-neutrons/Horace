function [pix_range_nontransf,pix_range] = rundata_find_pix_range(run_files,varargin)
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
%              corresponting to these centers
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
pix_range=PixelData.EMPTY_RANGE_;
pix_range_nontransf=PixelData.EMPTY_RANGE_;

pixels_transformed = ~isempty(run_files{1}.transform_sqw);

for i=1:nfiles
    [pix_range1,~,pix_range_ntr]=run_files{i}.calc_pix_range(varargin{:});
    pix_range = [min(pix_range(1,:),pix_range1(1,:));...
        max(pix_range(2,:),pix_range1(2,:))];
    if pixels_transformed
        pix_range_nontransf = [min(pix_range_nontransf(1,:),pix_range_ntr(1,:));...
            max(pix_range_nontransf(2,:),pix_range_ntr(2,:))];
    end
end
if ~pixels_transformed
    pix_range_nontransf = pix_range;
end
