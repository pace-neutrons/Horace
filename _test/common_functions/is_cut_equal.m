function [ok,mess,w1tot,w2tot]=is_cut_equal(f1,f2,varargin)
% Make cut from an array of files or sqw objects,
% add together, and compare with same for another array of files
%
%   >> [ok,mess]=is_cut_equal(f1,f2,proj,p1,p2,p3,p4)
%   >> [ok,mess]=is_cut_equal(f1,f2,proj,p1,p2,p3,p4,tol,1.e-6)
%
% Only checks the number of pixels per point, and the overall signal and error on the points
% Optional:
% if tol is provided, the parameters are checked within the tol. If tol is
% positive, it means absolute error and if negative -- relative error.
%
% Example:
%   >> f1={'sqw_12.sqw',sqw_34.sqw'};
%   >> f2='sqw_1234.sqw';
%   >> proj.u=[1,1,0]; proj.v=[0,0,1];
%   >> w1_2=cut_sqw(f1,f2,proj,[-1.5,0.05,-0.5],[-0.6,-0.44],[-0.5,0.5],[5,10]);
keyval_def = struct('tol',1.e-12);
[argi,keyval,~,~,ok,mess]= parse_arguments (varargin, keyval_def);
if ~ok
    error('IS_CUT_EQUAL:invalid_arguments',mess);
end

if ischar(f1), f1={f1}; end
if ischar(f2), f2={f2}; end
if isa(f1,'sqw'), f1={f1}; end
if isa(f2,'sqw'), f2={f2}; end

w1=repmat(sqw,1,numel(f1));
w2=repmat(sqw,1,numel(f2));
for i=1:numel(f1)
    w1(i)=cut_sqw(f1{i},argi{:});
end
for i=1:numel(f2)
    w2(i)=cut_sqw(f2{i},argi{:});
end

w1tot=combine_cuts(w1);
w2tot=combine_cuts(w2);
tol = keyval.tol;
% To check equality, see if npix, s, e arrays are the same
if equal_to_tol(w1tot.data.npix,w2tot.data.npix,'tol',tol) &&...
        equal_to_tol(w1tot.data.s,w2tot.data.s,'tol',tol) &&...
        equal_to_tol(w1tot.data.e,w2tot.data.e,'tol',tol) &&...
        equal_to_tol(w1tot.data.img_range,w2tot.data.img_range,'tol',tol)
    if isempty(w1tot.pix)
        ok=true;
        mess='';
    else
        if equal_to_tol(w1tot.pix.pix_range,w2tot.pix.pix_range,'tol',tol) && ...
                equal_to_tol(w1tot.pix.num_pixels,w2tot.pix.num_pixels,'tol',tol)
            ok=true;
            mess='';
        else
            ok = false;
            mess=sprintf(['Pixels parameters of two cuts are different:\n',...
                '   npix1=%d and npix2 = %d\n',...
                'pix_range1 = [%f  %f %f %f; pix_range2=[%f  %f %f  %f;\n',...
                '              %f  %f %f %f]             %f  %f %f  %f]'],...
                w1tot.pix.num_pixels,w2tot.pix.pix_range,...
                w1tot.pix.pix_range(1,:),w2tot.pix.pix_range(1,:),...
                w1tot.pix.pix_range(2,:),w2tot.pix.pix_range(2,:));
        end
    end
else
    ok=false;
    npix_diff = sum(w1tot.data.npix(:))-sum(w2tot.data.npix(:));
    s_diff = sum(w1tot.data.s(:))-sum(w2tot.data.s(:));
    e_diff = sum(w1tot.data.e(:))-sum(w2tot.data.e(:));
    mess=sprintf(['One or more of npix, s, e are not the same:\n',...
        'total differences: npix: %d; signal: %f; err: %f\n', ...
        'img ranges difference: = [%f %f %f %f;\n',...
        '                          %f %f %f %f]\n'],...
        npix_diff,s_diff,e_diff,...
        w1tot.data.img_range(1,:)-w2tot.data.img_range(1,:),...
        w1tot.data.img_range(2,:)-w2tot.data.img_range(2,:));
end
