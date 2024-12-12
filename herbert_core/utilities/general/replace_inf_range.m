function img_range = replace_inf_range(img_range)
%REPLACE_INF_RANGE Remove old inf integration ranges which may be present
% in old sqw or dnd objects
%
% Inputs:
% img_range  -- 2xN array of min/max values with possible -+inf values
%               present in it.
% Returns:
% img_range  -- the same array of ranges, modifies so that inf ranges are
%               replaced by closest defined value e.g:
%  if input is:
%  [ -1,-inf,-inf, 10,...
%   inf, 1,   inf, 20]
% The output would be
%  [-1    ,1-eps,-eps, 10,...
%   -1+eps,1    , eps, 20]
% Where eps is smallest positive compatible with 1 i.e. 1+eps ~= 1
%
% Horace-4 does not support inf ranges any more.
% Unlike previous Horace version, where  -inf:inf mean whole integration
% range, dnd with inf-integration range does not work in number of cases.
% This procedure is used to replace inf range to [0-eps,0+eps] range if
% both ranges are inf or extends present range by eps if only one range is
% present.
%
eps_single = double(eps('single'));
min_is_inf = isinf(img_range(1,:));
max_is_inf = isinf(img_range(2,:));
if any(min_is_inf)
    max_base= min_is_inf&(~max_is_inf); % max range is defined and min range is not. Take max range as reference
    guess_range            =  img_range(1,:);
    guess_range(min_is_inf)= -eps_single ;
    if any(max_base)
        guess_range(max_base)  =  img_range(2,max_base)*(1-sign(img_range(2,max_base))*eps_single );
    end
    img_range(1,min_is_inf)=  guess_range(min_is_inf) ;
end

if any(max_is_inf)
    min_base= max_is_inf&(~min_is_inf); % min range is defined and max range is not. Take min range as reference
    guess_range            = img_range(2,:);
    guess_range(max_is_inf)= eps_single ;
    if any(min_base)
        guess_range(min_base)  = img_range(1,min_base)*(1+sign(img_range(1,min_base))*eps_single);
    end
    img_range(2,max_is_inf)= guess_range(max_is_inf);
end
end
