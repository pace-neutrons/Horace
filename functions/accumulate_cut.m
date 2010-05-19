function [s, e, npix, urange_step_pix, npix_retain,ok, ix] = accumulate_cut (s, e, npix, urange_step_pix, keep_pix,...
                                                      v, urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax)
% Accumulate signal into output arrays
%
% Syntax:
%   >> [s,e,npix,npix_retain] = accumulate_cut (s, e, npix, v, urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax, keep_pix)
%
% Input: (* denotes output argumnet with same name exists - exploits in-place working of Matlab R2007a)
% * s               Array of accumulated signal from all contributing pixels (dimensions match the plot axes)
% * e               Array of accumulated variance
% * npix            Array of number of contributing pixels
% * urange_step_pix Actual range of contributing pixels
%   keep_pix        Set to true if wish to retain the information about individual pixels; set to false if not
%   v(9,:)          u1,u2,u3,u4,irun,idet,ien,s,e for each pixel, where ui are coords in projection axes of the pixel data in the file
%   urange_step     [2x4] array of the ranges of the data as defined by (i) output proj. axes ranges for
%                  integration axes (or plot axes with one bin), and (ii) step range (0 to no. bins)
%                  for plotaxes (with more than one bin)
%   rot_ustep       Matrix [3x3]     --|  that relate a vector expressed in the
%   trans_bott_left Translation [3x1]--|  frame of the pixel data to no. steps from lower data limit
%                                             r_step(i) = A(i,j)(r(j) - trans(j))
%   ebin            Energy bin width (plays role of rot_ustep for energy axis)
%   trans_elo       Bottom of energy scale (plays role of trans_bott_left for energy axis)
%   pax             Indices of plot axes (with two or more bins) [row vector]
%
% Output:
%   s               Array of accumulated signal from all contributing pixels (dimensions match the plot axes)
%   e               Array of accumulated variance
%   npix            Array of number of contributing pixels
%   urange_step_pix Actual range of contributing pixels
%   npix_retain     Number of pixels that contribute to the cut
%   ok              If keep_pix==true: v(:,ok) are the pixels that are retained; otherwise =[]
%   ix              If keep_pix==true: column vector of single bin index of each retained pixel; otherwise =[]
%
%
% Note:
% - Aim to take advantage of in-place working within accumulate_cut

% T.G.Perring   19 July 2007

% $Revision$ ($Date$)

ignore=horace_cut_nan_inf;
%
% parameters has to be doubles in current version of the c-prorgam

[use_mex,n_theads]=get(hor_config,'use_mex','threads');
%% USE MEX
if use_mex
    try
    %throw(' use matlab');
    parameters = zeros(4,1);
    parameters(1)=ignore.nan;
    parameters(2)=ignore.inf;
    parameters(3)=keep_pix;    
    parameters(4)=n_theads;
    %parameters(4)=1;
    
    [urange_step_pix_recent, ok, ix,s,e,npix,npix_retain]=...
                                             accumulate_cut_c(v,s,e,npix,...
                                             rot_ustep,trans_bott_left,ebin,trans_elo,...
                                             urange_step,pax,parameters);

    urange_step_pix =[min(urange_step_pix(1,:),urange_step_pix_recent(1,:));max(urange_step_pix(2,:),urange_step_pix_recent(2,:))];  % true range of data
    %%<*** version specific >= 7.5
    catch 
        use_mex=false;        
        if horace_info_level>=1
            disp([' C- code generated error: ',lasterr()]);
            warning('HORACE:use_mex',' Can not accumulate_cut using C routines; using Matlab');
        end
    end
end    
%% NOT USE MEX
if ~use_mex    
  [s, e, npix, urange_step_pix, npix_retain, ok, ix] = accumulate_cut_matlab (s, e, npix, urange_step_pix, keep_pix,...
                                                         v, urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax);
end

