function  img_db_range = calc_img_db_range_(ax_data)
% function used to retrieve 4D range used for rebinning pixels
% from old style sqw objects, where this range was not stored
% directly as it may become incorrect after some
% transformations.
%
% Returns:
% img_db_range  -- the estimate for the image range, used to
%                  build the grid used as keys to get the pixels,
%                  contributed into the image
%
% Should not be used directly, only for compatibility with old
% data formats. New sqw object should maintain correct
% img_db_range during all operations
%
% Inputs: either data_sqw_dnd instance or a structure
% containing:
% The relevant data structure used as source of image range is as follows:
%
%   ds.iax        Index of integration axes into the projection axes  [row vector]
%                  Always in increasing numerical order
%                       e.g. if data is 2D, data.iax=[1,3] means summation has been performed along u1 and u3 axes
%   ds.iint       Integration range along each of the integration axes. [iint(2,length(iax))]
%                       e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
%   ds.pax        Index of plot axes into the projection axes  [row vector]
%                  Always in increasing numerical order
%                       e.g. if data is 3D, data.pax=[1,2,4] means u1, u2, u4 axes are x,y,z in any plotting
%                                       2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
%   ds.p          Cell array containing bin boundaries along the plot axes [column vectors]
%                       i.e. row cell array{data.p{1}, data.p{2} ...} (for as many plot axes as given by length of data.pax)
%   ds.dax        Index into data.pax of the axes for display purposes. For example we may have
%                  data.pax=[1,3,4] and data.dax=[3,1,2] This means that the first plot axis is data.pax(3)=4,
%                  the second is data.pax(1)=1, the third is data.pax(2)=3. The reason for data.dax is to allow
%                  the display axes to be permuted but without the contents of the fields p, s,..pix needing to
%
if isfield(ax_data,'img_range')
    img_db_range  = ax_data.img_range;
    return
end

img_db_range = zeros(2,4);
img_db_range(:,ax_data.iax) = ax_data.iint;
npax = numel(ax_data.p);
pax_range = zeros(2,npax);
for i=1:npax
    pax_range(:,i) = [ax_data.p{i}(1);...
        ax_data.p{i}(end)];

end
img_db_range(:,ax_data.pax) = pax_range;

