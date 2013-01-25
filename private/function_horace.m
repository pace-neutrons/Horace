function varargout=function_horace(infile,func,varargin)
% Generic function to take file input sqw or d0d,d1d,...d4d data source to Horace functions.
%
%   >> varargout=function_horace(infile,@some_function,args)
%
% Function called is that appropriate to the type (sqw-type or dnd-type) contained in the file.
%
% Input:
% ------
%   infile  Name of input data file, or cell array of file names
%   func    Handle to function to be executed. The input and output arguments must be able to handle
%          three alternative forms of input:
%           - if data source is an object (or object array):
%               [out1,out2,...] = some_function(data_source_obj,arg1,arg2,...)
%
%           - if data source is a file name (or array of file names):
%               [out1,out2,...] = some_function(dummy_source_obj,filename,arg1,arg2,...)
%
%           - if data source is a data_source structure:
%               out_cellarray  = some_function(dummy_source_obj,data_source_struct,arg1,arg2,...)
%           
%           Input:
%           ------
%           data_source_obj     sqw or d0d, d1d,...d4d object
%         *OR*
%           dummy_source_obj    sqw or d0d, d1d,...d4d object that directs to correct function for the files
%           filename            Filename or cell array of filenames
%         *OR*
%           dummy_source_obj    sqw or d0d, d1d,...d4d object that directs to correct function for the files
%           data_source_struct  Structure or array of structures of form:
%                                 data_source_struct.keyword     '$file_data'
%                                 data_source_struct.file        Input file name
%                                 data_source_struct.sqw_type    How to read data file:
%                                                                  =true if read as sqw_type
%                                                                  =false if read dnd_type
%                                 data_source_struct.ndims       Dimensions of the sqw object
%                               Note that data_source.sqw_type is not necessarily the same as the
%                               type of data in the file e.g. if the file contains sqw_type data,
%                               we may still set the flag so that it is read as dnd-type data.
%
%           arg1,arg2,...       Input arguments
%
%           Output:
%           -------
%           out1,out2,...       Output arguments (data object or filename input)
%         *OR*
%           out_cellarray       If data_source structure input (but NOT if just filename(s)), then
%                              out1,out2,... must be packaged into a single cell array
%                              out_cellarray={out1,out2,...} as the sole output argument.
%                               See @sqw/read for an example.
%               
%   args    Cell array of arguments to be passed to the Horace function, as required in the above
%          description of the function to be executed.
%
% Output:
% -------
%   varargout   Output argument from the Horace function. By construction, the
%               functionality of the input argument func will ensure that varargout
%               will be either empty or contain a single argument that is a cell array of
%               all the output arguments of func.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

[sqw_type, ndims, data_source, mess] = is_sqw_type_file(sqw,infile);
if ~isempty(mess), error(mess), end

% Branch on type of data in the file, and if there are output arguments or not
% Recall that if the input data source was a file, we demand that all output
% arguments from the function being called are returned in a cell array.
% Consequently we can pass the output straight to the output of this function.
% We check the case of no output arguments as this can be significant - for example,
% in the cut method for sqw object, no output means that the output is written to file
% and so cuts that are far too large to be held in the matlab workspace can be performed.

if all(sqw_type)
    if nargout==0
        func(sqw,data_source,varargin{:});
    else
        varargout = func(sqw,data_source,varargin{:});
    end
    
elseif all(ndims==ndims(1))
    for i=1:numel(ndims)
        data_source(i).sqw_type=false;     % enforce reading as dnd object
    end
    nd=ndims(1);    % for convenience
    if nd==0
        if nargout==0
            func(d0d,data_source,varargin{:});
        else
            varargout = func(d0d,data_source,varargin{:});
        end
    elseif nd==1
        if nargout==0
            func(d1d,data_source,varargin{:});
        else
            varargout = func(d1d,data_source,varargin{:});
        end
    elseif nd==2
        if nargout==0
            func(d2d,data_source,varargin{:});
        else
            varargout = func(d2d,data_source,varargin{:});
        end
    elseif nd==3
        if nargout==0
            func(d3d,data_source,varargin{:});
        else
            varargout = func(d3d,data_source,varargin{:});
        end
    elseif nd==4
        if nargout==0
            func(d4d,data_source,varargin{:});
        else
            varargout = func(d4d,data_source,varargin{:});
        end
    else
        error('Dimensionality of dnd object must be 0,1,2..4')
    end
    
else
    error('All data files must be sqw type (i.e. contain pixel information) or have same dimensionality')
end
