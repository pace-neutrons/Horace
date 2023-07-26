function [ok,mess,w1tot,w2tot]=is_cut_equal(f1,f2,varargin)
% Given two valid cut targets f1 & f2
% apply a cut with the arguments in varargin (cut_args)
% for each set of cut targets (f1 & f2) accumulate the resultant cuts into a single sqw
% subsequently test the equality of these combined sqws.
%
% A valid cut target is any of the following:
% - Single sqw object
% - Array of sqw objects
% - Char array with path to valid saved sqw
% - Cell array of file-paths
%
%   >> [ok,mess]=is_cut_equal(f1, f2, cut_args)
%   >> [ok,mess]=is_cut_equal(___, 'tol', [abs_err,rel_err])
%
% where cut_args is arguments to be passed to cut, e.g. `proj,p1,p2,p3,p4`
%
% where 'tol' is the comparison tolerance. See equal_to_tol for the format
% of the parameter.
%
% Only checks the number of pixels per point, and the overall signal and error on the points
%
% Example:
%   >> f1={'sqw_12.sqw',sqw_34.sqw'};
%   >> f2='sqw_1234.sqw';
%   >> proj = ortho_proj([1,1,0], [0,0,1]);
%   >> w1_2=cut_sqw(f1,f2,proj,[-1.5,0.05,-0.5],[-0.6,-0.44],[-0.5,0.5],[5,10]);

keyval_def = struct('tol',[1.e-12,1.e-12]);

[cut_args,keyval,~,~,ok,mess]= parse_arguments(varargin, keyval_def);
if ~ok
    error('HORACE:is_cut_equal:invalid_argument',mess);
end

if istext(f1) || isa(f1,'sqw')
    f1={f1};
end
if istext(f2) || isa(f2,'sqw')
    f2={f2};
end

w1 = cellfun(@(w) cut(w, cut_args{:}), f1, 'UniformOutput', false);
w2 = cellfun(@(w) cut(w, cut_args{:}), f2, 'UniformOutput', false);

w1tot = combine_sqw(w1{:});
w2tot = combine_sqw(w2{:});

% To check equality, see if npix, s, e arrays are the same
tol = keyval.tol;

if equal_to_tol(w1tot.data.npix,w2tot.data.npix,'tol',tol) &&...
        equal_to_tol(w1tot.data.s,w2tot.data.s,'tol',tol) &&...
        equal_to_tol(w1tot.data.e,w2tot.data.e,'tol',tol) &&...
        equal_to_tol(w1tot.data.img_range,w2tot.data.img_range,'tol',tol)

    if w1tot.pix.num_pixels == 0
        ok=true;
        mess='';
    elseif equal_to_tol(w1tot.pix.pix_range,w2tot.pix.pix_range,'tol',tol) && ...
            equal_to_tol(w1tot.pix.num_pixels,w2tot.pix.num_pixels,'tol',tol)
        ok=true;
        mess='';
    else
        ok = false;
        pixrange_diff = w1tot.pix.pix_range-w2tot.pix.pix_range;
        mess=sprintf(['Pixels parameters of two cuts are different:\n',...
                      '   npix1=%d and npix2 = %d\n',...
                      '   pix_range difference =  [%g  %g %g %g;\n',...
                      '                            %g  %g %g %g]'],...
                     w1tot.pix.num_pixels,w2tot.pix.num_pixels,...
                     pixrange_diff');
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

end
