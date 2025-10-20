function result = move_all_to_proj(pageop_obj,proj_array,varargin)
% Convert all equivalent directions found in the cellarray of input datasets into
% the coordinate system specified by pageop_obj.
%
% Inputs:
% pageop_obj  -- instance of PageOp_sqw_binning object containing
%                information about source sqw object(s), including page of
%                pixel data currently loaded in memory.
% proj_array  -- array of projections which describe directions of cuts
%                to combine.
%
% Returns:
% result      -- page of modified pixels data to bin using
%                PageOp_sqw_binning algorithm transformed into coordinate
%                system related with first projection
%
%

% get access to current page of pixels data
data = pageop_obj.page_data;
% get access to the projection, which describe target image
targ_proj = pageop_obj.proj;
%
% done explicitly for 2-D cuts for performance to avoid internal loop over pixels ranges
%---------------------------------------------------------------------------------------
% Get access to the target image and obtain indices of the integration axis
iax  = pageop_obj.img.iax;  % expect two integration axis here
% get cut ranges of the image to combine everything into these ranges.
cut_range = pageop_obj.img.img_range(:,iax  );
%
q_coord = data(1:3,:);
result = cell(1,numel(proj_array));
% go through all combining images coordinates system, select pixels
% which
for i=1:numel(proj_array)
    % input projections used for cut do not have lattice set up for them.
    % They need lattice so let's set it up here.
    proj_array(i).alatt = targ_proj.alatt;
    proj_array(i).angdeg = targ_proj.angdeg;
    % transform momentum transfer values from current page of data into
    % image associated with proj_array(i) projection
    coord_tr = proj_array(i).transform_pix_to_img(q_coord);
    % find the data falling outside of the projection of interest range
    % forcing target image and the image produced by current projection to
    % coincide.
    include = coord_tr(iax(1),:)>=cut_range(1,1)&coord_tr(iax(1),:)<=cut_range(2,1)&...
        coord_tr(iax(2),:)>=cut_range(1,2)&coord_tr(iax(2),:)<=cut_range(2,2);
    % extract coordinates which lie within current cut ranges.
    coord_tr  = coord_tr(:,include);
    res_l = data(:,include);
    % transform pixels coordinates from image defined by proj_array(i) cut
    % projection into the Crystal Cartesian coordinates system related with
    % target projection.
    res_l(1:3,:) = targ_proj.transform_img_to_pix(coord_tr);
    % collect transformed pixels as partial result
    result{i} = res_l;

    data = data(:,~include); % extract remaining data for processing using
    % other projections.
    if isempty(data) % leave if all data was processed and transformed
        break
    end
    q_coord = data(1:3,:);
end
% combine all partial cut results
result = cat(2,result{:});
end