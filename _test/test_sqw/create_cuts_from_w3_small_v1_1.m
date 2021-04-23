function [w1,w2,w3] = create_cuts_from_w3_small_v1_1 (opt)
% Create a set of cuts for testing binary operations
%
%   >> [w1,w2,w3] = create_cuts_from_w3_small_v1_1              % read cuts from data file
%
%   >> [w1,w2,w3] = create_cuts_from_w3_small_v1_1 ('-setup')   % create data file by making cuts
%                                                               % from sqw object and saving to file
%                                                               % Uses private data!

% Parse options
if nargin>0
    if ischar(opt) && isequal(lower(opt),'-setup')
        create_cuts = true;
    else
        error('Unrecognised option: can only be ''-setup''')
    end
else
    create_cuts = false;
end


%% Read or create cuts
datafile='testsqw_w3_small_v1.mat';     % filename where saved cuts are written

if ~create_cuts
    load(datafile,'w3_small_v1')
else
    % Creates cuts from a private sqw file. The code is included here for completeness
    % as it defines the assumed relationships between the cuts
    
    data_source='T:\data\Fe\sqw_Toby\Fe_ei787.sqw'; % sqw file from which to take cuts for setup
    % Master 3D cut
    % -------------
    % [This cut takes about 8 seconds! Far too long. Use profiler]
    % In the following, the energy bin boundaries have been chosen so that there are no problems
    % with cut bin boundaries falling on intrinsic energy bin centres. That has not immediately
    % obviously correct pixel assignment to bins in the case of cuts with more than one dimension.
    proj.u=[1,1,0];
    proj.v=[-1,1,0];
    w3_small_v1 = cut_sqw(data_source,proj,[0.98,0.01,1.02],[-0.6,0.05,0.6],[-0.025,0.025],[146,10,226]);
    
    % Check cuts
    % [The 1D cut from file is taking too long]
    % [equal_to_tol is taking far too long. Use profiler]
    w1_from_file = cut_sqw(data_source,proj,[0.975,1.025],[-0.6,0.05,0.6],[-0.025,0.025],[141,151]);
    w1_from_cut = cut_sqw(w3_small_v1,[0.975,1.025],[],[141,151]);
    if ~equal_to_tol(w1_from_file, w1_from_cut)
        error('Problem with making cuts!!!')
    end
    
    % Save to mat file
    % -----------------
    datafile_full = fullfile(tmp_dir,datafile);
    save(datafile_full,'w3_small_v1')
end

%% Create cuts

% One-dimensional cuts: size =  [1,25,1,1]
% These are slices along the energy axis
w1 = repmat(sqw, [9,1]);
w1(1) = cut_sqw(w3_small_v1, [0.975,1.025], [], [141,151]);
w1(2) = cut_sqw(w3_small_v1, [0.975,1.025], [], [151,161]);
w1(3) = cut_sqw(w3_small_v1, [0.975,1.025], [], [161,171]);
w1(4) = cut_sqw(w3_small_v1, [0.975,1.025], [], [171,181]);
w1(5) = cut_sqw(w3_small_v1, [0.975,1.025], [], [181,191]);
w1(6) = cut_sqw(w3_small_v1, [0.975,1.025], [], [191,201]);
w1(7) = cut_sqw(w3_small_v1, [0.975,1.025], [], [201,211]);
w1(8) = cut_sqw(w3_small_v1, [0.975,1.025], [], [211,221]);
w1(9) = cut_sqw(w3_small_v1, [0.975,1.025], [], [221,231]);

% Two-dimensional cuts: size = [1,25,1,3]
% These divide the energy axis into three slices; each 2D cut is made from
% a stack of three of the 1D cuts made above
w2 = repmat(sqw, [3,1]);
w2(1) = cut_sqw(w3_small_v1, [0.975,1.025], [], [146,10,166]);
w2(2) = cut_sqw(w3_small_v1, [0.975,1.025], [], [176,10,196]);
w2(3) = cut_sqw(w3_small_v1, [0.975,1.025], [], [206,10,226]);

% Three-dimensional cuts: size = [5,25,1,3]
% These divide the energy axis into three slices, corresponding to a stack of
% three of the 1D cuts made above
% They divide the first axis into 4
w3 = repmat(sqw, [3,1]);
w3(1) = cut_sqw(w3_small_v1, [], [], [146,10,166]);
w3(2) = cut_sqw(w3_small_v1, [], [], [176,10,196]);
w3(3) = cut_sqw(w3_small_v1, [], [], [206,10,226]);





