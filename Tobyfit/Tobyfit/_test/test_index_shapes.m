% -------------------------------------------------------------------------
% Script to empirically test the shape of arrays following logical indexing
% -------------------------------------------------------------------------

% Summary:
% ---------
% Scalar:
%   The output has the size of the index array
%
% Vector array with vector index:
%   A vector retains its shape (i.e. row or column) independent of the
%   orientation of the index vector
%
%   If an array index, then output has the size of the index array

s=3;
vr=rand(1,3);   % Row vector
vc=vr(:);       % Column vector

is=2;           % Scalar index
ir=[3,1,1,2];   % Row index
ic=ir(:);       % Column index
ia=[3,1,1;2,3,1];% Array index


% -------------------------------------------------------------
% Scalar
% -------------------------------------------------------------
s([1])

s([1,1,1,1])

s([1,1,1,1]')

s(ones(2,3))


% -------------------------------------------------------------
% Vector
% -------------------------------------------------------------

% Scalar index
% -------------
% Output is a scalar i.e. size [1,1]
ars=vr(is);
size(ars)

acs=vc(is);
size(acs)


% Row index
% ----------
arr=vr(ir);
size(arr)

acr=vc(ir);
size(acr)

% Column index
% ------------
arc=vr(ic);
size(arc)

acc=vc(ic);
size(acc)

% Array index
% -----------
ara=vr(ia);
size(ara)

aca=vc(ia);
size(aca)
