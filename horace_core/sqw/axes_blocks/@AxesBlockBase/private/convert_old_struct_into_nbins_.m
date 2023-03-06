function in = convert_old_struct_into_nbins_(in)
% convert old AxesBlockBase structure, containing iint, p, iax etc 
% into the AxesBlockBase ver 2 structure
%

nbins_all_dims = zeros(1,4);
img_range = zeros(2,4);

prop_to_convert = {'iax','iint','pax','p'};
nbins_all_dims(in.iax) = 1;
img_range(:,in.iax) = in.iint;
if ~isempty(in.pax)
    nbin = cellfun(@(p)(numel(p)-1),in.p);
    range = cellfun(@(p)([min(p);max(p)]),in.p,'UniformOutput',false);
    nbins_all_dims(in.pax) = nbin;
    img_range(:,in.pax) = [range{:}];
end

in = rmfield(in,prop_to_convert);
in.nbins_all_dims = nbins_all_dims;
in.img_range = img_range;
if isfield(in,'img_db_range') && ~isequal(in.img_db_range,PixelDataBase.EMPTY_RANGE_) 
    % old format with img_db_range defined
    in.img_range = in.img_db_range;
end
if isfield(in,'ulabel')
    in.label = in.ulabel;
    in = rmfield(in,'ulabel');
end
