function hout=symmetry(h, ulen, nsym)
% Symmetrise multi-dimensional data by reflecting coordinates of a plane
% across a mirror line. 
%
% Syntax:
%   >> hout = symmetry(h, ulen, nsym)
%
% Input:
% ------
%   h       Array containing the components along the plotting axes in an
%           orthogonal coordinate frame
%               size(h) = [n_axes, n_points]
%   ulen    Length of the basis vectors along n1 and n2
%               size(ulen)=[1,2]
%   nsym    3 column vector [n1,n1,theta]
%               n1, n2: index of axes within the array h (max(n1,n2) <= n_axes)
%               theta: angle of line of reflection from n1 rotating towards n2.
%
%
% output:
% ------
%   hout    Symmetrised array
%
%
% The plane in which symmetrisation takes place is defined by axes n1 and n2,
% and the mirror line is at an angle theta (deg) from axis n1 when rotating
% towards n2.

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

% Check to make sure that axes n1 and n2 are valid and are present within h
n1= nsym(1);
n2= nsym(2);
theta= nsym(3);
ndim = size(h,1);
if ndim<n1 | ndim<n2 | n1<1 | n2<1 |n1==n2
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

