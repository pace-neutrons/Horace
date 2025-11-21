function range = get_img_range_from_cut_range(varargin)
% retrieve data range from binning range provided as input. 
%
n_bin_pars= numel(varargin);
range = zeros(2,n_bin_pars);
range(1,:) = -inf;
range(2,:) =  inf;
for i = 1:n_bin_pars
    bin_range = varargin{i}(:);
    if numel(bin_range) == 2
        range(1,i) = bin_range(1);
        range(2,i) = bin_range(2);
    elseif numel(bin_range) == 3
        if bin_range(2) == 0
            error("HORACE:AxesBlock:invalid_argument", ...
                "This method can not accept zero binning step in direction %d", ...
                 i)            
        end
        range(1,i) = bin_range(1)-0.5*bin_range(2);
        range(2,i) = bin_range(3)+0.5*bin_range(2);
    end
end
