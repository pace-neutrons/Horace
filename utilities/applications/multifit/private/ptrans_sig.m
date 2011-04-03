function [sig,bsig]=ptrans_sig(sig_free,w)
% Transform a list of free parameter errors from the least-squares fitting routine
% into arrays matching the sizes of the parameters.
% 
% See also ptrans.m

% Get list of estimated errors
pp=zeros(w.nptot,1);
pp(w.free)=sig_free;
pp(w.bound)=abs(w.ratio(w.bound)).*pp(w.ib(w.bound));   % ratio could be negative - must take absolute value

% Convert to array for global function and cell array for background functions
sig=pp(1:w.np)';
bsig=mat2cell(pp(w.np+1:end)',1,w.nbp(:)');
bsig=reshape(bsig,size(w.nbp));
