function vfCircumcenter = TriCircumcenter(vfPoint1, vfPoint2, vfPoint3)

% TriCircumcenter - FUNCTION Find the circumcenter of three points
%
% Usage: vfCircumcenter = TriCircumcenter(vfPoint1, vfPoint2, vfPoint3)
%
% Algorithm adapted from http://elmo.imtek.uni-freiburg.de

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd February, 2009

% -- Check arguments

if (nargin < 3)
   disp('*** TriCircumcenter: Incorrect usage');
   help TriCircumcenter;
   return;
end

% - Check for 2-D points
if (numel(vfPoint1) == 2)
   vfPoint1(3) = 0;
end

if (numel(vfPoint2) == 2)
   vfPoint2(3) = 0;
end

if (numel(vfPoint3) == 2)
   vfPoint3(3) = 0;
end


% -- Do it!

xba = vfPoint2(1)-vfPoint1(1);
yba = vfPoint2(2)-vfPoint1(2);
zba = vfPoint2(3)-vfPoint1(3);

xca = vfPoint3(1)-vfPoint1(1);
yca = vfPoint3(2)-vfPoint1(2);
zca = vfPoint3(3)-vfPoint1(3);

baLength = xba*xba + yba*yba + zba*zba;
caLength = xca*xca + yca*yca + zca*zca;

xcross = yba * zca - yca * zba;
ycross = zba * xca - zca * xba;
zcross = xba * yca - xca * yba;

denom = (1/2) / ( xcross*xcross + ycross*ycross + zcross*zcross );
xcic = ( (baLength * yca - caLength * yba) * ...
         zcross - (baLength * zca - caLength * zba) * ycross) * denom;
ycic = ( (baLength * zca - caLength * zba) * ...
         xcross - (baLength * xca - caLength * xba) * zcross) * denom;
zcic = ( (baLength * xca - caLength * xba) * ...
         ycross - (baLength * yca - caLength * yba) * xcross) * denom;

vfCircumcenter = [vfPoint1(1) + xcic, ...
                  vfPoint1(2) + ycic, ...
                  vfPoint1(3) + zcic];

% --- END of TriCircumcenter.m ---
