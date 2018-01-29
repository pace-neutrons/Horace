function ok = ischarstring (x)
%--------------------------------------------------------------------------
ok = (ischar(x) && numel(size(x))==2 && size(x,1)==1 && size(x,2)>0);
end
