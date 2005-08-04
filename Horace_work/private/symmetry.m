function hout=symmetry(h, ulen, nsym)
% Symmetrise data by reflecting through a plane perpendicular to that
% defined by axes n1 and n2 and at an angle theta (deg) from axis
% n1 when rotating towards n2. 
%
% Syntax:
%
%
% Input:
%
% ------
%   h:      array containing the components along the plotting axis. Has to be
%           in rlu's
%               e.g. size(h)=[3,n] in the case of binspe data, 4D or qqq 3D
%   ulen:   length of the vectors contained along n1 and n2
%               size(ulen)=[1,2]
%   nsym    3 column vector [n1,n1,theta]
%
% output:
%
% ------
%   hout: symmetrised array

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

% Check to make sure that axes n1 and n2 are present within h and create
% the necisary varaibles.
n1= nsym(1);
n2= nsym(2);
theta= nsym(3);
ln= size(h);
if ln(1)<=n1 | ln(1)<=n2,
    error('ERROR using symmetry routine: n1 or n2 not present within h');
end

% set up length in ang^-1 of the axes n1 and n2 as well as the info needed
% for the rotation array
hout=h;
xlength= ulen(1);
ylength= ulen(2);
ct= cos(theta*pi/180);
st= sin(theta*pi/180);

% apply the matrix rotation, the data will by symmetrised along y
x= (ct*xlength)*hout(n1,:)+(st*ylength)*hout(n2,:);
y= abs(-(st*xlength)*hout(n1,:)+(ct*ylength)*hout(n2,:));

% apply the inverse matrix rotation to obtain the symmetrized data set
hout(n1,:)= (ct*x-st*y)/xlength;
hout(n2,:)= (st*x+ct*y)/ylength;

