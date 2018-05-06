function [width, height] = aperture_width_height (aperture)
% Package aperture width and height into convenient form for later calculation
%
%   >> [width, height] = aperture_width_height (aperture)
%
% Input:
% ------
%   aperture    Aperture array (array of aperture objects)
%
% Output:
% -------
%   width       Column vector of full aperture widths
%   height      Column vector of full aperture heights


nrun=numel(aperture);
width=zeros(nrun,1);
height=zeros(nrun,1);
for j=1:nrun
    width(j)=aperture(j).width;
    height(j)=aperture(j).height;
end
