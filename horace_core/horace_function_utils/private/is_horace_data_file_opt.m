function [ok,opt_sqw,opt_dnd,opt_hor]=is_horace_data_file_opt(opt)
% Determine if an argument is a Horace data file option ('$hor', '$sqw', '$dnd')
opt_sqw=false; opt_dnd=false; opt_hor=false;
sz=size(opt);
if ischar(opt) && numel(sz)==2 && sz(1)==1 && sz(2)==4
    if strcmpi(opt,'$sqw')
        opt_sqw=true;
    elseif strcmpi(opt,'$dnd')
        opt_dnd=true;
    elseif strcmpi(opt,'$hor')
        opt_hor=true;
    end
end
ok=opt_sqw|opt_dnd|opt_hor;
