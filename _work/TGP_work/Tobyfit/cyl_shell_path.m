function d = cyl_shell_path (a,b,y)
% Distance through a cylindical shell
%
%   d = cyl_shell_path(a,b,y)
%
%   a   inner radius
%   b   outer radius
%   y   off centre distance perpendicular to particle path

if a<=b
    d = zeros(size(y));
    inner = y<a;
    outer = ~inner & y<b;
    if any(inner)
        d(inner) = sqrt(b^2-y(inner).^2) - sqrt(a^2-y(inner).^2);
    end
    if any(outer)
        d(outer) = sqrt(b^2-y(outer).^2);
    end
else
    error('Must have a<=b')
end
