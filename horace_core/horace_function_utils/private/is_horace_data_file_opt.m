function [ok,opt_sqw,opt_dnd,opt_hor]=is_horace_data_file_opt(opt)
% Determine if an argument is a Horace data file option ('$hor', '$sqw', '$dnd')
opt_sqw=strcmp(opt,'$sqw');
opt_dnd=strcmp(opt,'$dnd');
opt_hor=strcmpi(opt,'$hor');

ok=opt_sqw|opt_dnd|opt_hor;

end
