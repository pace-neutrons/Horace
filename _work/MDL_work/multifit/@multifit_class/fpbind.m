function pbind = fbind(obj, in_bind)
% Field containing the parameter bindings for the foreground fit function(s)
%
%   pbind   [Optional] Cell array that indicates which parameters are bound 
%           to other parameters in a fixed ratio determined by the initial 
%           parameter values contained in pin, (and also in bpin if there are 
%           background functions). 
%           Default: if pbind is omitted or pbind=[] all parameters are unbound. 
% 
%           Case of global foreground function 
%           ---------------------------------- 
%           A binding element describes how one parameter is bound to another: 
%             pbind={1,3}               Parameter 1 is bound to parameter 3. 
% 
%           A binding description is made from a cell array of binding elements: 
%             pbind={{1,3},{4,3},{5,6}} Parameter 1 bound to 3, 4 bound to 3, 
%                                      and 5 bound to 6. 
% 
%           To explicity give the ratio in a binding element, ignoring that 
%           determined from pin: 
%             pbind=(1,3,[],7.4)        Parameter 1 is bound to parameter 3 
%                                      with ratio 7.4 (the [] is required to 
%                                      indicate binding is to a parameter in 
%                                      the same function i.e. in this case 
%                                      the foreground function rather than 
%                                      the optional background function(s). 
%             pbind={1,3,0,7.4}         Same meaning: 0 (or -1) for foreground 
%                                      function 
% 
%           To bind to background function parameters (see below) 
%             pbind={1,3,7}             Parameter 1 bound to parameter 3 of 
%                                      the background function for the 7th 
%                                      data set, in the ratio given by the 
%                                      initial values. 
%             pbind={1,3,7,3.14}        Give explicit binding ratio. 
%             pbind={1,3,[2,3],3.14}    The binding is to parameter 3 of the 
%                                      data set with index [2,3] in the array 
%                                      of data sets (index must be a valid one 
%                                      in the array size returned by size(w)) 
% 
%           If the background function is defined as global i.e. you have set 
%           'global_background' as true, then always refer to background with 
%           index 1 because in this case there is only one background function. 
%             pbind={1,3,1,3.14} 
% 
%           EXAMPLE: 
%             pbind={{1,3,[],7.4},{4,3,0,0.023},{5,2,1},{6,3,2,3.14}} 
%                                       Parameters 1 and 4 bound to parameter 
%                                      3, and parameter 5 is bound to the 2nd 
%                                      parameter of the background to the first 
%                                      data set, and parameter 6 is bound to 
%                                      parameter 3 of the background to the 
%                                      second data set. 
% 
%           Note that you cannot bind a parameter to a parameter that is 
%           itself bound to another parameter. You can bind to a fixed or free 
%           parameter. 
% 
%           Case of local foreground functions 
%           ---------------------------------- 
%           If the function applies independently to each data set, that is, 
%           'local_foreground' is set, then pbind must be a cell array of 
%           binding descriptions of the form above, for each data set. Each 
%           of those binding descriptions is in turn a cell array. 
%           E.g. if there are two datasets, a valid pbind is: 
%            pbind={ {{1,3},{4,3},{5,6}}, {{1,3},{7,10}} } 
%           where the element {{1,3},{4,3},{5,6}} is the binding description 
%           for the first data set, and {{1,3},{7,10}} is for the second. 
% 
%           To reference parameters in the foreground function applying to 
%           a particular data set, give the index of the dataset as a 
%           negative number or array (c.f. a positive index to reference 
%           the background function applying to a particular dataset) 
%            pbind={1,3}               Parameter 1 is bound to parameter 3 
%                                     of the same function 
% 
%            pbind={1,3,-4}            Parameter 1 is bound to parameter 3 
%                                     of the function fitting the 4th data set 
% 
%            pbind={1,3,-[2,3]}        Parameter 1 is bound to parameter 3 
%                                     of the function fitting data set w(2,3) 
% 
%           It is easy to get confused about how pbind applies to the 
%           datasets, because to bind two parameters requires a cell array 
%           (e.g. {1,3}), to bind several parameters requires a cell array 
%           of cell arrays (e.g. {{1,3},{2,4,[],1.3}}), and lastly if there 
%           are several data sets we will in general have a cell array of 
%            *these* cell arrays. The rule is as follows: 
%           - If pbind is scalar cell array (i.e. size(pbind)==[1,1]), then 
%            pbind applies to every one of the data sets. 
%           - If size(pbind)==size(w) i.e. the number of cell arrays inside 
%            pbind matches the number of data sets, then each cell array of 
%            pbind applies to one dataset. 
% 
%           EXAMPLE: Suppose we have three data sets 
%             pbind={{1,3,[],7.4}, {4,3,[],0.023}}          INVALID 
%                                       size(pbind)==[1,2] i.e. there are 
%                                      two cell arrays in pbind, which is 
%                                      inconsistent with the number of data sets 
% 
%             pbind={{{1,3,[],7.4}, {4,3,[],0.023}}}        OK 
%                                       size(pbind)==[1,1] so the content: 
%                                           {{1,3,[],7.4},{4,3,[],0.023}} 
%                                       applies to every data set; which is 
%                                       parameters 1 and 4 bound to parameter 3 
% 
%             pbind={{1,3,[],7.4}, {4,3,[],0.023}, {{2,6},{3,6}}}   OK 
%                                       size(pbind)==[1,3] i.e. there are 
%                                      three cell arrays in pbind, which 
%                                      corresponds to one for each data set. 
%                                      In this case parameter 1 is bound to 
%                                      parameter 3 in the function fitting the 
%                                      first data set, parameters 4 is bound 
%                                      to parameter 3 in the function fitting 
%                                      the second data set, and parameters 2 
%                                      and 3 are bound to parameter 6 in the 
%                                      function fitting the third data set. 
% 

% If not called as a callback
if nargin==1
    obj.fpbind
    return
end

[ok,mess,ipbound,ipboundto,ifuncboundto,pratio]=pbind_parse(in_bind,true,obj.np,obj.nbp);
if ~ok
    error('Input is not a valid bindings list');
end
pbind = in_bind;
