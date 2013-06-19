function ap=aperture_width_height(aperture)
% Package aperture width and height into convenient form for later calculation
%
%   >> ap_wh=aperture_width_height(aperture)
%
% Input:
% ------
%   aperture    Cell array of aperture arrays, one per sqw object. The
%              aperture array has length equal to the number of runs in the
%              sqw object. Each aperture array is a columkn vector
%
% Output:
% -------
%   ap          Structures with two fields
%                   ap.width    Cell array of row vectors of full aperture widths
%                                - number of row vectors = number of sqw objects
%                                - number of elements in a vector = number of runs
%                                  in the corresponding sqw object
%
%                   ap.height   Cell array of row vectors of full aperture heights
%                                - number of row vectors = number of sqw objects
%                                - number of elements in a vector = number of runs
%                                  in the corresponding sqw object

width=cell(numel(aperture),1);
height=cell(numel(aperture),1);
for i=1:numel(aperture)
    nrun=numel(aperture{i});
    width{i}=zeros(1,nrun);
    height{i}=zeros(1,nrun);
    for j=1:nrun
        width{i}(j)=aperture{i}(j).width;
        height{i}(j)=aperture{i}(j).height;
    end
end

ap.width=width;
ap.height=height;
