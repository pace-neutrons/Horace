function pbind = bbind(obj, in_bind)
% Field containing the parameter bindings for the foreground fit function(s)
%
%   bpbind  [Optional] Indicates which parameters are bound to other 
%           parameters in a fixed ratio determined by the initial 
%           parameter values contained in pin and bpin. 
%           Default: if pbind is omitted or pbind=[] all parameters are unbound. 
% 
%           The syntax is the same as for the foreground function. Rather than 
%           repeat the documentation for pbind with minor changes to refer to 
%           background functions, the general form of both pbind and bpbind is 
%           described here. 
% 
%           - A binding description for a fit function is a cell array of 
%             binding elements of the form: 
%               {1,3}                   Parameter 1 is bound to parameter 3 
%                                      of the same function, in the ratio 
%                                      determined by the initial values. 
%               {1,3,[],7.4}            Parameter 1 is bound to parameter 3, 
%                                      of the same function, with ratio 7.4 
%               {1,3,ind,7.4}            Parameter 1 is bound to parameter 3 
%                                      of a different function, determined by 
%                                      the value of ind, with ratio 7.4 
%                where  ind = []        Binding parameters within he same 
%                                      function 
% 
%                or, in the case of foreground function(s): 
%                       ind = -1        The foreground function for the first 
%                                      data set (or the global foreground 
%                                      function, if 'global_foreground' is true) 
%                       ind = -3        The foreground function for the third 
%                                      data set (an index other than -1 is 
%                                      only valid if 'local_foreground') 
%                       ind = -[2,3]    The foreground function for data set 
%                                      with index [2,3] in the input data w 
% 
%                or, in the case of background function(s): 
%                       ind =  1        The background function for the first 
%                                      data set (or the global foreground 
%                                      function, if 'global_background' is true) 
%                       ind =  3        The background function for the third 
%                                      data set (an index other than 1 is 
%                                      only valid if 'local_background') 
%                       ind= [2,3]      The foreground function for data set 
%                                      with index [2,3] in the input data w 
% 
%           - If the fit function is global, you can only give a single 
%             binding description 
% 
%           - If the fit functions are local, then give a cell array of 
%             binding descriptions 
%               - if there is only one binding description in the cell array 
%                 then it will apply to all fit functions 
%               - if the number of binding descriptions equlas the number of 
%                 data sets, then there is one binding description per fit 
%                 function 

% If not called as a callback
if nargin==1
    obj.bpbind
    return
end

[obj.np obj.nbp]
[ok,mess,ipbound,ipboundto,ifuncboundto,pratio]=pbind_parse(in_bind,false,obj.np,obj.nbp);
if ~ok
    error('Input is not a valid bindings list');
end
pbind = in_bind;
