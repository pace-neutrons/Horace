function [sw_x,sw_y,sw_z,se_x,se_y,se_z,nw_x,nw_y,nw_z,ne_x,ne_y,ne_z]=make_bin_corners(q1,q2,varargin)
%
% function to turn a set of bin centre coordinates into a set of coords
% giving the positions of the bin corners, assuming the bins are 2d
% quadrilaterals
%
%
% Assumes orthonormal co-ordinate system (i.e. before any reflections have
% been done)

if nargin==2
    q3=0;
    q4=0;
elseif nargin==3
    q3=varargin{1};
    q4=0;
elseif nargin==4
    q3=varargin{1};
    q4=varargin{2};
else
    error('Horace error: bin centres for a dataset with dimensionality greater than 4 used');
end

dq1=diff(q1(diff(q1)~=0)); if isempty(dq1); dq1=0; end;
dq2=diff(q2(diff(q2)~=0)); if isempty(dq2); dq2=0; end;
dq3=diff(q3(diff(q3)~=0)); if isempty(dq3); dq3=0; end;
dq1=mode(dq1); dq2=mode(dq2); dq3=mode(dq3);%most common difference,
%which avoids confusion when moving to a new row/line
%
q1_old=q1; q2_old=q2; q3_old=q3;

if dq1==0
    q1=q2_old; q2=q3_old; q3=q1_old;
elseif dq2==0
    q1=q1_old; q2=q3_old; q3=q2_old;
end

sw_x=q1-dq1/2;
nw_x=sw_x;
se_x=q1+dq1/2;
ne_x=se_x;

sw_y=q2-dq2/2;
se_y=sw_y;
nw_y=q2+dq2/2;
ne_y=nw_y;

sw_z=q3; se_z=q3; ne_z=q3; nw_z=q3;
