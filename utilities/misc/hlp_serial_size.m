function sz = hlp_serial_size(v)
% Calculate the size (in bytes) of Matlab structure, woudl be produced by
% hpl_serialize routine. Deduced from hpl_serialize/
%
% See also:
%   hlp_serialize
%   hlp_deserialize
%
% Examples:
%   >>num_bytes = hlp_serial_size(mydata);
%   >>bytes = hlp_serialize(mydata)
%   >>numel(bytes) == num_bytes
%   >>True
%
%   dispatch according to type
%
if isnumeric(v)
    sz = serial_size_numeric(v);
elseif ischar(v)
    sz = serial_size_string(v);
elseif iscell(v)
    sz = serial_size_cell(v);
elseif isstruct(v)
    sz = serial_size_struct(v);
elseif isa(v,'function_handle')
    sz = serial_size_handle(v);
elseif islogical(v)
    sz = serial_size_logical(v);
elseif isobject(v)
    sz = serial_size_object(v);
elseif isjava(v)
    warn_once('hlp_serialize:cannot_serialize_java','Cannot properly serialize Java class %s; using a placeholder instead.',class(v));
    sz = serial_size_string(['<<hlp_serialize: ' class(v) ' unsupported>>']);
else
    try
        sz = serial_size_object(v);
    catch
        warn_once('hlp_serialize:unknown_type','Cannot properly serialize object of unknown type "%s"; using a placeholder instead.',class(v));
        sz = serial_size_string(['<<hlp_serialize: ' class(v) ' unsupported>>']);
    end
end
end

% single scalar
function sz = serial_size_scalar(v)

global types_size;
if isempty(types_size)
    classes = {'double','single','int8','uint8','int16','uint16','int32','uint32','int64','uint64'};
    sizes = [8,4,1,1,2,2,4,4,8,8];
    types_size = containers.Map(classes,sizes);
end


sz = 1+types_size(class(v));
end

% char arrays
function sz = serial_size_string(v)
if size(v,1) == 1
    % horizontal string: Type, Length, and Data
    sz = 1+4+length(v);
    %m = [uint8(0); typecast(uint32(length(v)),'uint8').'; uint8(v(:))];
elseif sum(size(v)) == 0
    % '': special encoding
    sz = 1;
else
    % general char array: Tag & Number of dimensions, Dimensions, Data
    sz = 2+2*numel(size(v))+numel(v);
    %m = [uint8(132); ndims(v); typecast(uint32(size(v)),'uint8').'; uint8(v(:))];
end
end

% logical arrays
function sz = serial_size_logical(v)
% Tag & Number of dimensions, Dimensions, Data
%m = [uint8(133); ndims(v); typecast(uint32(size(v)),'uint8').'; uint8(v(:))];
sz = 2+4*numel(size(v))+numel(v);
end

% non-complex and non-sparse numerical matrix
function sz = serial_size_numeric_simple(v)
% Tag & Number of dimensions, Dimensions, Data
%m = [16+class2tag(class(v)); uint8(ndims(v)); typecast(uint32(size(v)),'uint8').'; typecast(v(:).','uint8').'];
global types_size;
bs = types_size(class(v));
sz = 1+1+4*numel(size(v))+numel(v)*bs;
end

% Numeric Matrix: can be real/complex, sparse/full, scalar
function sz = serial_size_numeric(v)
if issparse(v)
    % Data Type & Dimensions
    %m = [uint8(130); typecast(uint64(size(v,1)), 'uint8').'; typecast(uint64(size(v,2)), 'uint8').']; % vectorize
    sz = 1+8+8;
    % Index vectors
    [i,j,s] = find(v);
    % Real/Complex
    if isreal(v)
        sz = sz+serial_size_numeric_simple(i)+serial_size_numeric_simple(j)+1+serial_size_numeric_simple(s);
        %m = [m; serialize_numeric_simple(i); serialize_numeric_simple(j); 1; serialize_numeric_simple(s)];
    else
        sz = sz+serial_size_numeric_simple(i)+serial_size_numeric_simple(j)+1+serial_size_numeric_simple(real(s));
        %m = [m; serialize_numeric_simple(i); serialize_numeric_simple(j); 0; serialize_numeric_simple(real(s)); serialize_numeric_simple(imag(s))];
    end
elseif ~isreal(v)
    % Data type & contents
    %m = [uint8(131); serialize_numeric_simple(real(v)); serialize_numeric_simple(imag(v))];
    sz = 1+serial_size_numeric_simple(real(v))+serial_size_numeric_simple(imag(v));
elseif isscalar(v)
    % Scalar
    %m = serialize_scalar(v);
    sz = serial_size_scalar(v);
else
    % Simple matrix
    %m = serialize_numeric_simple(v);
    sz = serial_size_numeric_simple(v);
end
end

% Struct array.
function sz = serial_size_struct(v)
% Tag, Field Count, Field name lengths, Field name char data, #dimensions, dimensions
fieldNames = fieldnames(v);
fnLengths = [length(fieldNames); cellfun('length',fieldNames)];
fnChars = [fieldNames{:}];
dims = [ndims(v) size(v)];
sz = 1+4*numel(fnLengths)+numel(fnChars)+4*numel(dims);
%m = [uint8(128); typecast(uint32(fnLengths(:)).','uint8').'; uint8(fnChars(:)); typecast(uint32(dims), 'uint8').'];
% Content.
if numel(v) > length(fieldNames)
    % more records than field names; serialize each field as a cell array to expose homogenous content
    tmp = cellfun(@(f)serial_size_cell({v.(f)}),fieldNames,'UniformOutput',true);
    sz = sz+1+numel(tmp);
    %m = [m; 0; vertcat(tmp{:})];
else
    % more field names than records; use struct2cell
    sz = sz+1+serial_size_cell(struct2cell(v));
    %m = [m; 1; serialize_cell(struct2cell(v))];
end
end

% Cell array of heterogenous contents
function sz = serial_size_cell_heterogeneous(v)
contents = cellfun(@hlp_serial_size,v,'UniformOutput',true);
sz = 1+1+4*numel(size(v))+sum(reshape(contents,1,numel(contents)));
%m = [uint8(33); ndims(v); typecast(uint32(size(v)),'uint8').'; vertcat(contents{:})];
end

% Cell array of homogenously-typed contents
function sz = serial_size_cell_typed(v,serializer)
contents = cellfun(serializer,v,'UniformOutput',true);
sz =1+1+4*numel(size(v))+sum(contents);
%m = [uint8(33); ndims(v); typecast(uint32(size(v)),'uint8').'; vertcat(contents{:})];
end

% Cell array
function sz = serial_size_cell(v)
sizeprod = cellfun('prodofsize',v);
if sizeprod == 1
    % all scalar elements
    if (all(cellfun('isclass',v(:),'double')) || all(cellfun('isclass',v(:),'single'))) && all(~cellfun(@issparse,v(:)))
        % uniformly typed floating-point scalars (and non-sparse)
        reality = cellfun('isreal',v);
        if reality
            % all real
            %m = [uint8(34); serialize_numeric_simple(reshape([v{:}],size(v)))];
            sz = 1+serial_size_numeric_simple(reshape([v{:}],size(v)));
        elseif ~reality
            % all complex
            %m = [uint8(34); serialize_numeric(reshape([v{:}],size(v)))];
            sz = 1+ serial_size_numeric(reshape([v{:}],size(v)));
        else
            % mixed reality
            %m = [uint8(35); serialize_numeric(reshape([v{:}],size(v))); serialize_logical(reality(:))];
            sz = 1+ serial_size_numeric(reshape([v{:}],size(v)))+serial_size_logical(reality(:));
        end
    else
        % non-float types
        if cellfun('isclass',v,'struct')
            % structs
            %m = serialize_cell_typed(v,@serialize_struct);
            sz = serial_size_cell_typed(v,@serial_size_struct);
        elseif cellfun('isclass',v,'cell')
            % cells
            %m = serialize_cell_typed(v,@serialize_cell);
            sz = serial_size_cell_typed(v,@serial_size_cell);
        elseif cellfun('isclass',v,'logical')
            % bool flags
            %m = [uint8(39); serialize_logical(reshape([v{:}],size(v)))];
            sz = 1+serial_size_logical(reshape([v{:}],size(v)));
        elseif cellfun('isclass',v,'function_handle')
            % function handles
            %m = serialize_cell_typed(v,@serialize_handle);
            sz = serial_size_cell_typed(v,@serial_size_handle);
        else
            % arbitrary / mixed types
            %m = serialize_cell_heterogenous(v);
            sz = serial_size_cell_heterogeneous(v);
        end
    end
elseif isempty(v)
    % empty cell array
    %m = [uint8(33); ndims(v); typecast(uint32(size(v)),'uint8').'];
    sz = 1+1+4*nunel(size(v));
else
    % some non-scalar elements
    dims = cellfun('ndims',v);
    size1 = cellfun('size',v,1);
    size2 = cellfun('size',v,2);
    if cellfun('isclass',v,'char') & size1 <= 1 %#ok<AND2>
        % all horizontal strings or proper empty strings
        %m = [uint8(36); serialize_string([v{:}]); serialize_numeric_simple(uint32(size2)); serialize_logical(size1(:)==0)];
        sz = 1+serial_size_string([v{:}])+serial_size_numeric_simple(uint32(size2))+serial_size_logical(size1(:)==0);
    elseif (size1+size2 == 0) & (dims == 2) %#ok<AND2>
        % all empty and non-degenerate elements
        if all(cellfun('isclass',v(:),'double')) || all(cellfun('isclass',v(:),'cell')) || all(cellfun('isclass',v(:),'struct'))
            % of standard data types: Tag, Type Tag, #Dims, Dims
            %m = [uint8(37); class2tag(class(v{1})); ndims(v); typecast(uint32(size(v)),'uint8').'];
            sz = 1+1+1+4*numel(size(v));
        elseif length(unique(cellfun(@class,v(:),'UniformOutput',false))) == 1
            % of uniform class with prototype
            %m = [uint8(38); hlp_serialize(class(v{1})); ndims(v); typecast(uint32(size(v)),'uint8').'];
            sz = 1+hlp_serial_size(class(v{1}))+1+4*numel(size(v));
        else
            % of arbitrary classes
            %m = serialize_cell_heterogenous(v);
            sz = serial_size_heterogeneous(v);
        end
    else
        % arbitrary sizes (and types, etc.)
        %m = serialize_cell_heterogenous(v);
        sz = serial_size_cell_heterogeneous(v);
    end
end
end

% Object / class
function sz = serial_size_object(v)
% can object serialize/deserizlize itself?
if any(strcmp(methods(v), 'serialize'))
    % it has to have serial_size method too
    sz = 1 + serial_size_string(class(v))+v.serizl_size();
    %m = [uint8(135); serialize_string(class(v)); v.serialize()];
else
    try
        % try to use the saveobj method first to get the contents
        conts = saveobj(v);
        if isstruct(conts) || iscell(conts) || isnumeric(conts) || ischar(conts) || islogical(conts) || isa(conts,'function_handle')
            % contents is something that we can readily serialize
            sz = hlp_serial_size(conts);
        else
            % contents is still an object: turn into a struct now
            sz = serial_size_struct(struct(conts));
        end
    catch
        % saveobj failed for this object: turn into a struct
        sz = serial_size_struct(struct(v));
    end
    % Tag, Class name and Contents
    sz = 1+ serial_size_string(class(v))+ sz;
    %m= [uint8(134); serialize_string(class(v)); conts];
end
end

% Function handle
function sz = serial_size_handle(v)
% get the representation
rep = functions(v);
switch rep.type
    case 'simple'
        % simple function: Tag & name
        sz = 1+serial_size_string(rep.function);
        %m = [uint8(151); serialize_string(rep.function)];
    case 'anonymous'
        global tracking; %#ok<TLEV>
        if isfield(tracking,'serialize_anonymous_fully') && tracking.serialize_anonymous_fully
            % serialize anonymous function with their entire variable environment (for complete
            % eval and evalin support). Requires a stack of function id's, as function handles
            % can reference themselves in their full workspace.
            persistent handle_stack; %#ok<TLEV>
            % Tag and Code
            sz = 1+serial_size_string(char(v));
            %m = [uint8(152); serialize_string(char(v))];
            % take care of self-references
            str = java.lang.String(rep.function);
            func_id = str.hashCode();
            if ~any(handle_stack == func_id)
                try
                    % push the function id
                    handle_stack(end+1) = func_id;
                    % now serialize workspace
                    sz = sz+serial_size_struct(rep.workspace{end});
                    %m = [m; serialize_struct(rep.workspace{end})];
                    % pop the ID again
                    handle_stack(end) = [];
                catch e
                    % note: Ctrl-C can mess up the handle stack
                    handle_stack(end) = []; %#ok<NASGU>
                    rethrow(e);
                end
            else
                % serialize the empty workspace
                sz = sz+serial_size_struct(struct());
                %m = [m; serialize_struct(struct())];
            end
            if sz > 2^18
                % If you are getting this warning, it is likely that one of your anonymous functions
                % was created in a scope that contained large variables; MATLAB will implicitly keep
                % these variables around (referenced by the function) just in case you refer to them.
                % To avoid this, you can create the anonymous function instead in a sub-function
                % to which you only pass the variables that you actually need.
                warn_once('hlp_serialize:large_handle','The function handle with code %s references variables of more than 256k bytes; this is likely very slow.',rep.function);
            end
        else
            % anonymous function: Tag, Code, and reduced workspace
            if ~isempty(rep.workspace)
                sz = 1+serial_size_string(char(v))+serial_size_struct(rep.workspace{1});
                %m = [uint8(152); serialize_string(char(v)); serialize_struct(rep.workspace{1})];
            else
                sz = 1+serialize_string(char(v))+serial_size_struct(struct());
                %m = [uint8(152); serialize_string(char(v)); serialize_struct(struct())];
            end
        end
    case {'scopedfunction','nested'}
        % scoped function: Tag and Parentage
        %m = [uint8(153); serialize_cell(rep.parentage)];
        sz = 1+serial_size_cell(rep.parentage);
    otherwise
        warn_once('hlp_serialize:unknown_handle_type','A function handle with unsupported type "%s" was encountered; using a placeholder instead.',rep.type);
        sz = serial_size_string(['<<hlp_serialize: function handle of type ' rep.type ' unsupported>>']);
        %m = serialize_string(['<<hlp_serialize: function handle of type ' rep.type ' unsupported>>']);
end
end


% emit a specific warning only once (per MATLAB session)
function warn_once(varargin)
persistent displayed_warnings;
% determine the message content
if length(varargin) > 1 && any(varargin{1}==':') && ~any(varargin{1}==' ') && ischar(varargin{2})
    message_content = [varargin{1} sprintf(varargin{2:end})];
else
    message_content = sprintf(varargin{1:end});
end
% generate a hash of of the message content
str = java.lang.String(message_content);
message_id = sprintf('x%.0f',str.hashCode()+2^31);
% and check if it had been displayed before
if ~isfield(displayed_warnings,message_id)
    % emit the warning
    warning(varargin{:});
    % remember to not display the warning again
    displayed_warnings.(message_id) = true;
end
end
