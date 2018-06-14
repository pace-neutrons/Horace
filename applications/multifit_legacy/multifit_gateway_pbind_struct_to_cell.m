function pbind_cell=multifit_gateway_pbind_struct_to_cell (pbind_struct)
% Convert structure output of pbind_parse into cell array of binding descriptions
%
%   >> pbind_cell=multifit_gateway_pbind_struct_to_cell (pbind_struct)
%
% Input:
% ------
%   pbind_struct    Structure with four fields, each a cell array with the same size
%                  as the corresponding functions array:
%  
%       ipbound     Cell array of column vectors of indicies of bound parameters,
%                  one vector per function
%       ipboundto   Cell array of column vectors of the parameters to which those
%                  parameters are bound, one vector per function
%       ifuncboundto  Cell array of column vectors of single indicies of the functions
%                  corresponding to the free parameters, one vector per function. The
%                  index is ifuncfree(i)<0 for foreground functions, and >0 for
%                  background functions.
%       pratio      Cell array of column vectors of the ratios (bound_parameter/free_parameter),
%                  if the ratio was explicitly given. Will contain NaN if not (the
%                  ratio will be determined from the initial parameter values). One
%                  vector per function.
%
% Output:
% -------
%   pbind_cell      Cell array of function binding descriptions, one per function. The
%                  size of the cell array is the same as the input structure fields.
%
%                   A function binding descriptor is a cell array of parameter binding
%                  descriptors e.g.
%                    - An empty cell array (which means no binding)   i.e. {}
%                    - A single parameter binding descriptor          e.g. {1,3,-5,NaN} or {2,5,13,5.2}
%                    - A cell array of parameter binding descriptors  e.g. {{1,3,-5,NaN},{2,5,13,5.2}}
%
%                   A single parameter description is a cell array with four elements:
%                        {<parameter to bind>, <parameter to bind to>, <function index>, <ratio>}
%                    - The function index is negative for foreground functions and positive
%                      for background functions
%                    - The ratio is a finite number, or NaN to indicate that the fixed ratio 
%                      is the value given by the initial parmaeter values
 
 
% Original author: T.G.Perring 
% 
% $Revision$ ($Date$) 


pbind_cell=cell(size(pbind_struct.ipbound));
for i=1:numel(pbind_cell)
    if ~isempty(pbind_struct.ipbound{i})
        a=[pbind_struct.ipbound{i}';pbind_struct.ipboundto{i}';pbind_struct.ifuncboundto{i}';pbind_struct.pratio{i}'];
        nbind=size(a,2);
        pbind_cell(i)={mat2cell(num2cell(a(:)'),1,4*ones(1,nbind))};
    else
        pbind_cell(i)={{}};
    end
end
