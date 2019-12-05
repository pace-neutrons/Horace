function  [obj,pos] = calc_pos_check_input_set_defaults_(obj,input,varargin)
% process input of caclulate_position function and set up proper option and
% default options
%
% Usage: (private function)
% [obj,pos] = calc_pos_check_input_set_defaults_(obj,input);
% or
%[obj,pos] = calc_pos_check_input_set_defaults_(obj,input, initial_position);
%
%where:
% input -- various forms of input data
% initial_position -- if present, starting relative position for calculate_position
%
% Output:
% obj  changed to know the kind of output used to process its data (file,
%      bytes, structure)
%      also knows about the position of the end of the input stream
% pos  if initial_position  is not present
%      -- depending on kind of input stream initial position to look for data
%      if initial_position  is present:
% pos  == initial_position
%
%
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)
%

if isstruct(input)
    obj.input_is_stuct_ = true;
elseif isa(input,'double') % file handler is always double
    obj.input_is_file_ = true; 
    obj.input_is_stuct_ = false;    
else
    if isa(input,'uint8')
        obj.input_is_file_ = false;
        obj.input_is_stuct_ = false;        
        if size(input,1) == 1
            input = input';
        end
    else % input is a class and we try to tread it as a structure
        obj.input_is_stuct_ =true;
        obj.input_is_file_ = false;        
    end
end

if nargin == 3
    pos = varargin{1};
else
    if obj.input_is_stuct_
        pos = 1;  % for in-memory conversion,
    elseif obj.input_is_file_
        % input is a file and we look at calculating its size
        pos = 0;
    else  % bytes
        pos = 1;  % for in-memory conversion
    end
end
if obj.input_is_stuct_
    % for file positioning it has to be 0
    obj.eof_pos_ = inf;
elseif obj.input_is_file_
    % input is a file and we look at calculating its size
    cur_fp = ftell(input);
    fseek(input,0,'eof');
    obj.eof_pos_ = ftell(input);
    fseek(input,cur_fp,'bof');
else  % bytes
    obj.eof_pos_ = numel(input)+1;
end




