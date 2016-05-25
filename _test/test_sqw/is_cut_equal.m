function [ok,mess,w1tot,w2tot]=is_cut_equal(f1,f2,varargin)
% Make cut from an array of files or sqw objects, 
% add together, and compare with same for another array of files
%
%   >> [ok,mess]=is_cut_equal(f1,f2,proj,p1,p2,p3,p4)
%
% Only checks the number of pixels per point, and the overall signal and error on the points
%
% Example:
%   >> f1={'sqw_12.sqw',sqw_34.sqw'};
%   >> f2='sqw_1234.sqw';
%   >> proj.u=[1,1,0]; proj.v=[0,0,1];
%   >> w1_2=cut_sqw(f1,f2,proj,[-1.5,0.05,-0.5],[-0.6,-0.44],[-0.5,0.5],[5,10]);

if ischar(f1), f1={f1}; end
if ischar(f2), f2={f2}; end
if isa(f1,'sqw'), f1={f1}; end
if isa(f2,'sqw'), f2={f2}; end

w1=repmat(sqw,1,numel(f1));
w2=repmat(sqw,1,numel(f2));
for i=1:numel(f1)
    w1(i)=cut_sqw(f1{i},varargin{:});
end
for i=1:numel(f2)
    w2(i)=cut_sqw(f2{i},varargin{:});
end

w1tot=combine_cuts(w1);
w2tot=combine_cuts(w2);

% To check equality, see if npix, s, e arrays are the same
if equal_to_tol(w1tot.data.npix,w2tot.data.npix) &&...
        equal_to_tol(w1tot.data.s,w2tot.data.s) &&...
        equal_to_tol(w1tot.data.e,w2tot.data.e)
    ok=true;
    mess='';
else
    ok=false;
    mess='One or more of npix, s, e are not the same';
end
