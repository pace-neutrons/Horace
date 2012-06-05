function clearfigs
% Delete all figure windows
%
%   >> clearfigs

h=findall(0,'Type','figure');
if ~isempty(h)
    delete(h)
end
