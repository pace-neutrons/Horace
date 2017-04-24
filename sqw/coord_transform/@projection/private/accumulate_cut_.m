function [urange_step_pix, ok, ix, s, e, npix, npix_retain,success] = ...
    accumulate_cut_(this,v,s,e,npix,pax,ignore_nan,ignore_inf,keep_pix,n_threads)
%
%Interface to accumulate rectangular cut using mex code. 
%
[rot_ustep,trans_bott_left,ebin,trans_elo,urange_step] = this.get_pix_transf_();
try
    % Parameters have to be doubles in current version of the c-program
    parameters = zeros(5,1);
    parameters(1)=ignore_nan;
    parameters(2)=ignore_inf;
    parameters(3)=keep_pix;
    parameters(4)=n_threads;
   [urange_step_pix, ok, ix, s, e, npix, npix_retain]=...
        accumulate_cut_c(v,s,e,npix,rot_ustep,trans_bott_left,ebin,trans_elo,urange_step,pax,parameters);
    if npix_retain==0
        ix=ones(0,1); % to be consistent with Matlab
    end
    success = true;
    %%<*** version specific >= 7.5
catch Err
    if get(hor_config,'log_level')>=1
        disp([' C- code generated error: ',Err.message]);
        warning('HORACE:use_mex',' Cannot accumulate_cut using C routines; using Matlab');
    end
    urange_step_pix=[];
    ok=[];
    ix=[];
    npix_retain=[];
    success=false;
end





