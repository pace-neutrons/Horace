function  [new_axes_block,targ_img_db_range] = build_from_input_binning(...
    cur_img_range_and_steps,pbin)
% build new axes_block object from the binning parameters, provided
% as input. If some input binning parameters are missing, the
% defauls are taken from existing axes_block object.
%
% if the target range defined by binning exceeds the existing image range
% (in target coordinate system), the existing image range is selected
%
% Inputs:
% cur_img_range_and_steps
%          --   cellarray of the ranges and steps of source
%               image, expressed in the target coordinates and
%               used as source of default ranges
%               if these ranges are not specified by pbin
% pbin     --   cellarray of input binning parameters, which define
%               target image binning
% where each cell can contains the following parameters:
%               - [] or ''          Use default (existing) bins (bin size and limits)
%               - [pstep]           Plot axis: sets step size; plot limits taken from extent of the data
%               - [plo, phi]        Integration axis: range of integration
%               - [plo, pstep, phi] Plot axis: minimum and maximum bin centres and step size
% Outputs:
% new_axis_block    -- initialized instance of axes_block class
% targ_img_db_range -- the range to bin pixels

if numel(pbin) ~=4
    error('HORACE:axes_block:invalid_argument',...
        'Have not provided binning descriptor for all three momentun axes and the energy axis');
end
if numel(cur_img_range_and_steps) ~=4
    error('HORACE:axes_block:invalid_argument',...
        'Have not provided default binning for all three momentun axes and the energy axis');
else
    if size(cur_img_range_and_steps,1) > 1
        cur_img_range_and_steps = cur_img_range_and_steps';
    end
end


% calculate target image ranges from the binning requested:
% set up NaN=s for values, which have to be redefined from source
idim = 1:4;
ind = num2cell(idim);
% Check values are acceptable, and make ranges (3+2)x1 (for plot) or (2+2)x1 for integration axes
% plus parameters, which define the bin ranges
% ---------------------------------------------------------------------------------------
targ_img_range = cellfun(@(i,bin_rec,bin_def)parce_pbin(i,bin_rec,bin_def),...
    ind,pbin,cur_img_range_and_steps,'UniformOutput',false);

is_iax = cellfun(@(bin)(numel(bin)==4),targ_img_range);
iax = idim(is_iax);
pax = idim(~is_iax);

niax = sum(is_iax);
npax = 4-niax;


% Compute plot bin boundaries and integration ranges

iint=zeros(2,niax);
p   =cell(1,npax);
%
targ_img_db_range=zeros(2,4);

% Compute plot bin boundaries and range that fully encloses the requested output plot axes
for i=1:npax
    ipax = pax(i);
    the_range = targ_img_range{ipax};
    step = the_range(2);
    if the_range(4) == 1 && the_range(5) == 1
        pmin    = the_range(1)-step/2;
        pmax    = the_range(3)+step/2;
        nsteps  = floor((pmax-pmin)/step);
        if pmin+nsteps*step<pmax
            nsteps = nsteps+1;
        end
        pp = pmin+(0:nsteps)*step;
    elseif the_range(4) == 0 && the_range(5) == 1
        pmin = the_range(1);
        pmax = the_range(3)+step/2;
        nsteps  = floor((pmax-pmin)/step);
        % Old behaviour:
        if pmax-nsteps*step>pmin
            nsteps = nsteps+1;
        end
        pp = sort(pmax-(0:nsteps)*step);
        % would be more reasonable to set up hard bin range on -inf?
        %         if pmin+nsteps*step<the_range(3)
        %             if abs(pmax-nsteps*step-the_range(3))>1.e-12
        %                 nsteps = nsteps+1;
        %             else
        %                 step = (pmax-pmin)/(nsteps+1);
        %             end
        %         end
        %         pp = pmin+(0:nsteps)*step;
    elseif the_range(4) == 1 && the_range(5) == 0
        pmin = the_range(1)-step/2;
        pmax = the_range(3);
        nsteps  = floor((pmax-pmin)/step);
        % Old behaviour:
        if pmin+nsteps*step<pmax
            nsteps = nsteps+1;
        end
        pp = pmin+(0:nsteps)*step;
        %         % would it be more reasonable to set up hard bin range on inf?
        %         if the_range(1)-nsteps*step>pmin
        %             if abs(the_range(1)-nsteps*step-pmin)>1.e-12
        %                 nsteps = nsteps+1;
        %             else
        %                 step = (pmax-pmin)/(nsteps+1);
        %             end
        %         end
        %         pp = sort(pmax-(0:nsteps)*step);
    else % the_range(4) == 0 && the_range(5) == 0
        pmin = the_range(1);
        pmax = the_range(3);
        nsteps  = floor((pmax-pmin)/step);
        if pmin+nsteps*step<pmax
            if abs(pmin+nsteps*step-pmax)>1.e-12
                nsteps = nsteps+1;
            else
                step = (pmax-pmin)/(nsteps+1);
            end
            % change in behaviour. +-Inf spefies hard ranges
            %step = (pmax-pmin)/(nsteps+1);
        end
        pp = pmin+(0:nsteps)*step;
    end
    p{i} =  pp;
    targ_img_db_range(:,ipax)=[pmin;pmax];
end

% Compute integration ranges.
for i=1:niax
    iiax = iax(i);
    the_range = targ_img_range{iiax};
    %
    iint(1,i)=the_range(1);
    iint(2,i)=the_range(2);
    %
    targ_img_db_range(:,iiax)=[iint(1,i);iint(2,i)];
end

new_axes_block = axes_block();
new_axes_block.iax  = iax;
new_axes_block.iint = iint;
new_axes_block.pax  = pax;
new_axes_block.p    = p;
new_axes_block.dax  = 1:npax;




function range = parce_pbin(ind,bin_req,bin_default)
% get defined binning range from the various input parameters
%
% This function defines the logic behind the binning parameters
% interpretation
%
% Returns:
% range  5x1 or 4x1 vector containing the bin ranges and information on how
%        to interpret the ranges, i.e. if true (1) the correspondent range
%        is treated as bin center and if false(0) the range is treated as
%        limit
%        If range contains 5 elements, its first three elements describe
%        binning and if there are 4 elements, it is about integration
%        ranges
if  numel(bin_req) == 2 || (isempty(bin_req) && numel(bin_default)==2)
    left_range_is_bs = 0; % left range not used as a bin center
    right_range_is_bs = 0; % right range not used as a bin center
else
    left_range_is_bs = 1; % left range used as a bin center
    right_range_is_bs = 1; % right range not used as a bin center
end
%
if isempty(bin_req)
    range = [bin_default,left_range_is_bs,right_range_is_bs];
elseif numel(bin_req) == 1
    if bin_req == 0 % this may fail if bin_default is integration axis
        bin_req = bin_default(2);
    end
    range  = [bin_default(1),bin_req,bin_default(end),left_range_is_bs,right_range_is_bs];
else
    range = [bin_req,left_range_is_bs,right_range_is_bs];
    if isinf(range(1))
        range(1) = bin_default(1);
        range(end-1) = 0;
    end
    if isinf(bin_req(end))
        range(numel(bin_req)) = bin_default(end);
        range(end) = 0;
    end
    if numel(range) == 5 && range(2)==0
        if numel(bin_default) == 3
            range(2) = bin_default(2);
        else % integrate in ranges, defined by default bin boundaries if step is 0
            % and the default bin boundaries are integration boundaries
            range = [range(1),range(3:end)];
        end
    end
end
if numel(range)==5 % check if min+step >= max, so it is actually integration range
    % regardless of anything
    if range(1)+range(2)>=range(3)
        range = [range(1),range(3),0,0];
    end
end

% check validity of data ranges
last_range = 3;
if numel(range)==4
    last_range = 2;
end
if range(last_range) <= range(1)
    error('HORACE:axes_block:invalid_argument',...
        'Upper limit greater or equal to the lower limit - check axis N: %d',ind);
end
if size(range,1)>1
    range = range';
end
if size(range,1)>1
    error('HORACE:axes_block:invalid_argument',...
        'Binning range for axis %d is not a vector but have size: %s',...
        ind,evalc('disp(size(range))'));
end
if numel(range)>5
    error('HORACE:axes_block:invalid_argument',...
        'The binning range for axis %d have invalid value: %s',...
        ind,evalc('disp(size(range))'));
end
