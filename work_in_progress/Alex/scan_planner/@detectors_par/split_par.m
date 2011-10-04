function  [par_indexes,nBlocks] = split_par( par)
% function analyses angular positions of the detectors 
% specified in the the par-data (columns 2 and 3) and identifies the 
% detectos goups, assuming that data arranged in blocks of adjacent   
% (located one after another) detectos; The significance criteria roughly 
% assumes the existence of blocks of at least 3 adjacent detectors. 
% 
%  usage:
%>> par_indexes = split_par( par)
%Input:
%par     --  is data obtanied from Tobyfit Par file with column 2 and 3
%             containing radial and asimutal detectors positions;
% Output:
% par_indexes -- integer array of size par with numbers, specifying the
%                     detectors block
%
% Original author: AB
%
% $Revision: 480 $ ($Date: 2010-07-12 12:56:46 +0100 (Mon, 12 Jul 2010) $)
%

% how many adjacent detecotors assumed to be a line 
Criteria = 3; % will actually work on four.

if isstruct(par)
    X = par.phi;
    Y = par.azim;
    nDetectors = numel(X);
else
    X = par(2,:);
    Y = par(3,:);
    nDetectors = size(par,2);    
end
distX=X(2:end)-X(1:end-1);
distY=Y(2:end)-Y(1:end-1);
Dist = sqrt(distX.*distX+distY.*distY);
md = sum(Dist)/numel(Dist);

nBlocks =1;
par_indexes = logical(zeros(nDetectors,1));
par_indexes(1)=1;
for i=2:nDetectors
    if Dist(i-1)>Criteria*md
       par_indexes(i-1)=true;
       par_indexes(i)   =true;    
    end

end

