function [triHull, vbOutside, vbInside] = AlphaHull(mfPoints, fAlphaRadius, triDelaunay)

% AlphaHull - FUNCTION Find the alpha hull of a set of points
%
% Usage: [triHull, vbOutside, vbInside] = AlphaHull(mfPoints, fAlphaRadius <, triDelaunay>)
%
% This function computes the alpha shape / alpha hulls of a set of points; both
% the external hull as well as interior voids.
%
% This algorithm is based on qhull and the delaunay tetrahedralisation of the
% set of points.  It will return a hull TRIANGULATION, and ignore points
% connected only by a line.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd February, 2009


% -- Check arguments

if (nargin < 2)
   disp('*** AlphaHull: Incorrect usage');
   help AlphaHull;
   return;
end


%% -- Find the Delaunay triangulation (tetrahedralisation), if required

if (~exist('triDelaunay', 'var') || isempty(triDelaunay))
   [mfPointsUnique, vnUniqueIndices] = unique(mfPoints, 'rows');
   triDelaunay = vnUniqueIndices(delaunayn(mfPointsUnique));
end

%% -- Make a list of triplets to check (each tetrahedron defines four)

mnTriplets = [ triDelaunay(:, [1 2 3]);
               triDelaunay(:, [1 2 4]);
               triDelaunay(:, [1 3 4]);
               triDelaunay(:, [2 3 4])];

% - Filter for unique triplets
mnTriplets = sort(mnTriplets, 2);
mnTriplets = unique(mnTriplets, 'rows');


%% -- Check each triplet to see if it is on the alpha hull

nNumPoints = size(mfPoints, 1);
nNumTriplets = size(mnTriplets, 1);
vbTripletOnHull = false(nNumTriplets, 1);
mbHullSide = false(nNumTriplets, 2);
parfor (nTripletIndex = 1:nNumTriplets)
   % - Get triplet points
   mfTripletPoints = mfPoints(mnTriplets(nTripletIndex, :), :); %#ok<PFBNS>
   
   % - Find the triangle plane unit normal
   vfCross = cross_prod(mfTripletPoints(2, :) - mfTripletPoints(1, :), ...
      mfTripletPoints(3, :) - mfTripletPoints(1, :));
   vfNormal = vfCross ./ sqrt(sum(vfCross.^2));

   % - Find the midpoint of the circle for which these point are co-circular
   vfCircumcenter = TriCircumcenter(mfTripletPoints(1, :), mfTripletPoints(2, :), mfTripletPoints(3, :));
   fSliceRadius = sqrt(sum((vfCircumcenter - mfTripletPoints(1, :)).^2));

   % - If the circumcircle radius is bigger than the alpha radius, reject this triplet
   if (fSliceRadius > fAlphaRadius)
      continue;
   end

   % - Find the distance from circumcircle midpoint to circumsphere midpoint
   fSphereMidpointDist = sqrt(fAlphaRadius^2 - fSliceRadius^2);

   % - The sphere midpoint is this distance from the circumcenter, along (and
   % opposite to) the surface normal
   mfSphereMidpoints = [vfCircumcenter; vfCircumcenter] + fSphereMidpointDist .* [vfNormal; -vfNormal];

   % -- Find the distances for each other point to the circumsphere midpoint
   vnTriPoints = sort(mnTriplets(nTripletIndex, :));

   % - You could also use setdiff here, but it's much slower...
   vnOtherPoints = [1:vnTriPoints(1)-1 vnTriPoints(1)+1:vnTriPoints(2)-1 vnTriPoints(2)+1:vnTriPoints(3)-1 vnTriPoints(3)+1:nNumPoints];

   % - We do it like this because repmat is too slow...
   vfDists1 = sqrt(  (mfPoints(vnOtherPoints, 1) - mfSphereMidpoints(1, 1)).^2 + ...
      (mfPoints(vnOtherPoints, 2) - mfSphereMidpoints(1, 2)).^2 + ...
      (mfPoints(vnOtherPoints, 3) - mfSphereMidpoints(1, 3)).^2); %#ok<PFBNS>
   vfDists2 = sqrt(  (mfPoints(vnOtherPoints, 1) - mfSphereMidpoints(2, 1)).^2 + ...
      (mfPoints(vnOtherPoints, 2) - mfSphereMidpoints(2, 2)).^2 + ...
      (mfPoints(vnOtherPoints, 3) - mfSphereMidpoints(2, 3)).^2);

   % - This triplet is on the alpha hull if either of the two spheres contain no
   % other points
   bSphere1Pass = all(vfDists1 > fAlphaRadius);
   bSphere2Pass = all(vfDists2 > fAlphaRadius);

   if (bSphere1Pass || bSphere2Pass)
      % - Sphere is "inside" if the sphere midpoint is closer to the origin
      % than the triangle centrum
      fCentrumOriginDist = sqrt(sum(mean(mfTripletPoints, 1).^2));
      
      % - Work out which sphere midpoint distances to origin
      vfOriginDists = sqrt(sum(mfSphereMidpoints.^2, 2));

      % - Add this triplet to the hull
      vbTripletOnHull(nTripletIndex) = true;
      vbSphereSide = [false false];

      % - Assign the triplet to the inside or outside (or both) of the hull
      if (bSphere1Pass)
         if (vfOriginDists(1) > fCentrumOriginDist)
            % - Sphere 1 is outside
            vbSphereSide(1) = true;
         elseif (vfOriginDists(1) < fCentrumOriginDist)
            % - Sphere 1 is inside
            vbSphereSide(2) = true;
         else
            % - Extremely unlikely...
            vbSphereSide = [true true];
         end
      end

      if (bSphere2Pass)
         if (vfOriginDists(2) > fCentrumOriginDist)
            % - Sphere 2 is outside
            vbSphereSide(1) = true;
         elseif (vfOriginDists(2) < fCentrumOriginDist)
            % - Sphere 2 is inside
            vbSphereSide(2) = true;
         else
            % - Extremely unlikely...
            vbSphereSide = [true true];
         end
      end

      % - Accumulate in/out-side results
      mbHullSide(nTripletIndex, :) = vbSphereSide;
   end
end

fprintf(1, '\n');

% -- Extract hull list and inside/outside lists

triHull = mnTriplets(vbTripletOnHull, :);
vbOutside = mbHullSide(vbTripletOnHull, 1);
vbInside = mbHullSide(vbTripletOnHull, 2);


% -- END of AlphaHull FUNCTION ---

function cross = cross_prod(a, b)

cross = [a(2)*b(3) - a(3)*b(2) ...
         a(3)*b(1) - a(1)*b(3) ...
         a(1)*b(2) - a(2)*b(1)];

% --- END of AlphaHull.m ---
