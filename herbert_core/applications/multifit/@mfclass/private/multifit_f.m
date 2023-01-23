function f = multifit_f(w,xye,func,bfunc,pin,bpin,f_pass_caller_info,bf_pass_caller_info,pfin,p_info,store_calc,S,Store,listing)
%
%
%
%

[f,~,~,~]=multifit_lsqr_func_eval(w,xye,func,bfunc,pin,bpin,...
                    f_pass_caller_info,bf_pass_caller_info,pfin,p_info,false,S,Store,listing);

f = cat(1, f{:});
psidisp('C:\Users\vrs42921\Documents\pace\Horace\_work\JK_work\dump\f',f)