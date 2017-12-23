%           == Advanced use of functions: ==
%           The fitting function can be made of nested functions. The examples
%           below illustrate why this can be useful. The convention that is
%           followed by this least-squares algorithm is to assume that a
%           fitting function with form:
%               my_func1 (w, @my_func2, pcell, c1, c2, ...)
%
%           where pcell is a cell array, will be evaluated as:
%               my_func1 (my_func2(w, pcell{:}), c1, c2, ...)
%           
%           == EXAMPLE: Fit a model for S(Q,w) to an sqw object:
%           Suppose we have a function to compute S(Q,w) with standard form:
%               weight = my_sqwfunc (qh, qk, ql, en, p, c1, c2,..)
%
%           where in the general case c1, c2 are some constant parameters
%           needed by the function (e.g. the names of files with lookup
%           tables). Suppose also that there is a method of the sqw object to
%           evaluate this function:
%               wcalc = sqw_eval (w, @my_sqwfunc, {p, c1, c2, ...})
%
%           In that case, the model for S(Q,w) can be fitted by the call:
%               fit (w, @sqw_eval, {@my_sqwfunc, {p, c1, c2,...}})
%
%           == EXAMPLE: Resolution convolution of S(Q,w):
%           Suppose there is a method of sqw class that takes a model for 
%           S(Q,w) and convolutes with the resolution function:
%               wres = resconv (w, @my_sqwfunc, {p,c1,c2,...}, res1, res2)
%
%           where res1, res2... are some constant parameters needed to 
%           evaluate the resolution function e.g. flight paths in the
%           instrument. In this case, the function call will be:
%               fit (w, @resconv, {@my_sqwfunc, {p, c1, c2,...}, res1, res2})