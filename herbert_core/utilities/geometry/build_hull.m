function box_hull = build_hull(img_range,nbins_all_dims)
%BUILD_HULL  constructs nodes which belong to surface of the box, defined
%by its min-max ranges and cover the surface of this box
%
% Inputs:
% img_range  2xNdim array of min-max values which define box in Ndim space
% nbins_all_dims
%            1xNdim array of number of nodes to build along each dimension
%            of the Ndim image. All values have to be larger or equal to 1.
% Returns:
% box_hull - [Ndim x prod(nbins_all_dims)] array of coordinates of the
%            nodes which cover surface of the box

nDims = numel(nbins_all_dims);

if size(img_range,2) ~= nDims
    error('HERBERT:utilities:invalid_agument', ...
        'Number of image ranges (currently %d) must be equal to number of binning ranges (currently %d)', ...
        size(img_range,2),nDims)
end
if nDims > 4
    error('HERBERT:utilities:not_implemented', ...
        'Support for more then 4 dimensions have not yet been implemented. Requested %d dimensions.',...
        nDims);
end

ax = cell(1,nDims);
ax_range = cell(1,nDims);
for i = 1:nDims
    ax{i} = linspace(img_range(1,i),img_range(2,i),nbins_all_dims(i));
    ax_range{i} = [img_range(1,i),img_range(2,i)];
end

switch nDims
    case 1
        box_hull = ax{1};
    case 2
        [Xn1,Yn1] = ndgrid(ax_range{1},ax{2});
        [Xn2,Yn2] = ndgrid(ax{1},ax_range{2});
        Xn = [Xn1(:);Xn2(:)]';
        Yn = [Yn1(:);Yn2(:)]';
        box_hull = [Xn;Yn];
    case 3
        [Xn1,Yn1,Zn1] = ndgrid(ax_range{1},ax{2},ax{3});
        [Xn2,Yn2,Zn2] = ndgrid(ax{1},ax_range{2},ax{3});
        [Xn3,Yn3,Zn3] = ndgrid(ax{1},ax{2},ax_range{3});
        Xn = [Xn1(:);Xn2(:);Xn3(:)]';
        Yn = [Yn1(:);Yn2(:);Yn3(:)]';
        Zn = [Zn1(:);Zn2(:);Zn3(:)]';
        box_hull = [Xn;Yn;Zn];
    case 4
        [Xn1,Yn1,Zn1,En1] = ndgrid(ax_range{1},ax{2},ax{3},ax{4});
        [Xn2,Yn2,Zn2,En2] = ndgrid(ax{1},ax_range{2},ax{3},ax{4});
        [Xn3,Yn3,Zn3,En3] = ndgrid(ax{1},ax{2},ax_range{3},ax{4});
        [Xn4,Yn4,Zn4,En4] = ndgrid(ax{1},ax{2},ax{3},ax_range{4});
        Xn = [Xn1(:);Xn2(:);Xn3(:);Xn4(:)]';
        Yn = [Yn1(:);Yn2(:);Yn3(:);Yn4(:)]';
        Zn = [Zn1(:);Zn2(:);Zn3(:);Zn4(:)]';
        En = [En1(:);En2(:);En3(:);En4(:)]';
        box_hull = [Xn;Yn;Zn;En];
end