function bin_range = get_binning_range_(obj)
% return binning range, defined by current projection and
% integration axes ranges
%
% Returns:
% range  -- 2x4 array of min/max values of the axes grid,
%           described by the axes_block and used for the
%           pixels binning.

bin_range = zeros(2,4);
p = obj.p;
steps = cellfun(@(x)(x(2)-x(1)),p,'UniformOutput',false);
pax_range = cellfun(@(x,st)([x(1)+0.5*st;x(end)-0.5*st]),...
    p,steps,'UniformOutput',false);
pax_range  = [pax_range{:}];
bin_range(:,obj.pax) = pax_range(:,1:numel(p));
bin_range(:,obj.iax) = obj.iint;
