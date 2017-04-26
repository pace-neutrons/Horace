function proj = build_4D_proj_box_(proj,grid_size_in,urange,varargin)
%
if nargin>3
    if iscell(varargin{1}) && numel(varargin{1}) == 4 && ischar(varargin{1}{1})
        proj.labels = varargin{1};
    else
        proj.labels = {'Q_\zeta','Q_\xi','Q_\eta','E'};
    end
end
[proj.grid_size_,proj.p_,proj.pix_urange_]=construct_grid_size_(grid_size_in,urange);

proj.uoffset_=[0;0;0;0];

%
iint_ind = proj.grid_size_ == 1;
n_iax = sum(iint_ind);
n_pax = 4-n_iax;
proj.pax_ = zeros(1,n_pax);
proj.dax_ = zeros(1,n_pax);
proj.iax_ = zeros(1,n_iax);
proj.iint_= zeros(2,n_iax);
ic_pax = 0;
ic_iax = 0;
for i=1:4
    if iint_ind(i) %iax
        ic_iax = ic_iax+1;
        proj.iax_(ic_iax) = i;
        proj.iint_(:,ic_iax) = proj.pix_urange_(:,i);
    else
        ic_pax = ic_pax+1;
        proj.pax_(ic_pax) = i;
        proj.dax_(ic_pax) = i;
    end
end
