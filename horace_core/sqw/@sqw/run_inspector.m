function [pr,nd,split_array] = run_inspector(w,varargin)
% run_inspector(w)
%
% Creates a new window displaying the parts of an sqw dataset that came
% from individual runs, i.e. it is an animation of the result of a "split"
% command.
%
% The animation can be run using the following keyboard shortcuts (or by
% moving the scroll bar with the mouse):
%
%     Enter (Return) -- play/pause video (5 frames-per-second default).
%     Backspace -- play/pause video 5 times slower.
%     Right/left arrow keys -- advance/go back one frame.
%     Page down/page up -- advance/go back 10 frames.
%     Home/end -- go to first/last frame of video.
%
% Currently only works for 1d and 2d sqw data
%
% Optional inputs (multiple combinations allowed), with preceding keywords
%
% run_inspector(w,'col',[c_lo,c_hi]) - for the 2d slice case, allows you
%       to specify the limits of the colourbar. If not specified then each plot
%       will have different colour limits, determined by the min/max intensity.
%
% run_inspector(w,'ax',[x_lo,x_hi,y_lo,y_hi]) - for both 1d and 2d cases,
%       allows you to specify the limits of the x and y axes of the plot. The
%       default behavior is to use the axes of the original (unsplit) object
%
% Test parameters:
% run_inspector(__,'test_parser',true) - the pair used in unit tests and if
%         provided 'test_parser',true, roudine does nothing but returns
%         parsed input parameters
%
% Outputs: (used in testing)
% pm    -- the structure, containing the values of processed input
%          parameteres. If no input parameters were provided, returns their
%          default values
% nd    -- number of dimensions for input sqw object
%
% split_array -- array of the non-empty sqw objects, the input multirun sqw
%          object has been split

%RAE 30/1/15

%Do some checks on the data:
[pr,nd] = parse_inputs(w,varargin{:});
if pr.test_parser % provide 'test_parser', true, argument to unit test parser only
    split_array = [];
    return;
end

%=======================================

%Now switch between 1d and 2d cases
split_array = split(w);
args = {5,10,[],'Name','Horace Run Inspector'};
if pr.test_videofig
    args = [args(:)',{'test_videofig'}];
end
if nd==1
    run_inspector_videofig(numel(split_array),@run_inspector_animate_1d,{split_array,pr.ax},args{:});
elseif nd==2
    run_inspector_videofig(numel(split_array),@run_inspector_animate_2d,{split_array,pr.col,pr.ax},args{:});
end

function [pr,nd] = parse_inputs(obj,varargin)
% 
% shorten input file name to the minimal useful abbreviations
short_par = {'ax','col','test_parser'};
argi = cellfun(@(x)shorten_kw(x,short_par),varargin,'UniformOutput',false);


pm = inputParser;
val_obj = @(x)(isa(x,'sqw')&&numel(x)==1&&~x.data.pix.is_filebacked());
pm.addRequired('obj',val_obj)
pm.addParameter('col',[],@(x)(isnumeric(x)&&numel(x)==2&&x(1)<x(2)))
pm.addParameter('ax',[],@(x)(isnumeric(x)&&numel(x)==4&&x(1)<x(2)&&x(3)<x(4)))
pm.addParameter('test_parser',false,@(x)(islogical(x)));
pm.addParameter('test_videofig',false,@(x)(islogical(x)));
try
    parse(pm,obj,argi{:});
    pr = pm.Results;
catch ME
    if ismember(ME.identifier,{'MATLAB:InputParser:ArgumentFailedValidation',...
            'MATLAB:InputParser:ParamMissingValue'})
        error('HORACE:run_inspector:invalid_argument',...
            ME.message);
    else
        rethrow(ME);
    end
end
nd=dimensions(obj);
if nd<1 || nd>2
    error('HORACE:run_inspector:invalid_argument',...
        'Input dataset must be an sqw object that is 2d or 1d');
end
function kw = shorten_kw(x,short_names)
kw = x;
if ~ischar(x)
    return;
end
for i=1:numel(short_names)
    if strncmp(x,short_names{i},numel(short_names{i}))
        kw = short_names{i};
        return;
    end
end
