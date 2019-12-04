function this = set_proj_binning_(this,urange,pax,iax,p)

% Check input arguments
%
this.urange_ = urange;
%---------------------------------------------------
% Get matrix, and offset in pixel proj. axes, that convert from coords in pixel proj. axes to multiples of step from lower point of range
% ---------------------------------------------------------------------------------------------------------------------------------------------
%  (Step size of zero is possible e.g. integration range is zero over what we know is exactly zero for Qz on HET west bank
% or energy transfer if select constant-E plane exactly at bin centre)
%  In the cutting algorithm, plot axes with one bin only will be treated exactly as integration axes; we can always reshape the output
% to insert singleton dimensions as required.
%  (*** Implicitly assumes that there is no energy offset in uoffset, either in the input data or the requested output proj axes
%   *** Will need to modify get_nrange_rot_section, calc_ubins and routines they call to handle this.)

% Get plot axes with two or more bins, and the number of bins along those axes
j=1;
pax_gt1=[];
nbin_gt1=[];
ustep_gt1=[];
for i=1:length(pax)
    if length(p{i})>2
        pax_gt1(j)=pax(i);              % row vector of plot axes with two or more bins
        nbin_gt1(j)=length(p{i})-1;     % row vector of number of bins
        ustep_gt1(j)=(p{i}(end)-p{i}(1))/(length(p{i})-1);  % row vector of bin widths
        j=j+1;
    end
end
% Set range and step size for plot axes with two or more bins to be the permitted range in multiples of the bin width
% Treat other axes as unit step length, range in units of output proj. axes
urange_step=urange;             % range expressed as steps/length of output ui
urange_offset = zeros(1,4);     % offset for start of measurement as lower left corner/origin as defined by uoffset
ustep = ones(1,4);              % step as multiple of unit ui/unity
if ~isempty(pax_gt1)
    urange_step(:,pax_gt1)=[zeros(1,length(pax_gt1));nbin_gt1];
    urange_offset(pax_gt1)=urange(1,pax_gt1);
    ustep(pax_gt1)=ustep_gt1;
end


this.targ_pax_  = pax;
this.targ_iax_  = iax;
this.targ_p_    = p;
this.pax_gt1_    = pax_gt1;
this.nbin_gt1_   = nbin_gt1;
this.usteps_ = ustep;
this.urange_step_ = urange_step;
this.urange_offset_ = urange_offset;




