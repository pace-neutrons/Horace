function sqw_obj_in = gen_bm_func_eval_data(nDims,dataType,dataNum)
%GEN_BM_FUNC_EVAL_DATA Summary of this function goes here
%   Detailed explanation goes here
common_data=fullfile(fileparts(fileparts(mfilename('fullpath')...
    )),'common_data');
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';

switch dataType
    case "small"
        dataSource = fullfile(common_data,'ironSmall.sqw');
        %dummy_sqw()
    case "medium"
        dataSource = fullfile(common_data,'ironMedium.sqw');
        %dummy_sqw()
    case "large"
        dataSource = fullfile(common_data,'ironLarge.sqw');
        %dummy_sqw()
    otherwise
        warning("HORACE:gen_sqw_eval_bm_data:invalid_argument",...
            "datatype must be either a string (small, medium or large), or an integer")
end

switch nDims
    case 1
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,175];
        sqw_1D = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case 2
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
        sqw_2D = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case 3
        p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];p4_bin=[0,16,700];
        sqw_3D = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    otherwise
        error("HORACE:gen_bm_data:invalid_argument"...
            ,"nDims is the dimensions of the cuts : must be 1, 2 or 3.")
end

switch true
    case nDims==1 && dataType=="small" && dataNum=="small"
        sqw_obj_in=sqw_1D;

    case nDims==1 && dataType=="small" && dataNum=="medium"
        sqw_obj_in=[sqw_1D,sqw_1D,sqw_1D,sqw_1D];

    case nDims==1 && dataType=="small" && dataNum=="large"
        sqw_obj_in=[sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D];

    case nDims==1 && dataType=="medium" && dataNum=="small"
        sqw_obj_in=sqw_1D;

    case nDims==1 && dataType=="medium" && dataNum=="medium"
        sqw_obj_in=[sqw_1D,sqw_1D,sqw_1D,sqw_1D];

    case nDims==1 && dataType=="medium" && dataNum=="large"
        sqw_obj_in=[sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D];

    case nDims==1 && dataType=="large" && dataNum=="small"
        sqw_obj_in=sqw_1D;

    case nDims==1 && dataType=="large" && dataNum=="medium"
        sqw_obj_in=[sqw_1D,sqw_1D,sqw_1D,sqw_1D];

    case nDims==1 && dataType=="large" && dataNum=="large"
        sqw_obj_in=[sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D];

    case nDims==2 && dataType=="small" && dataNum=="small"
        sqw_obj_in=sqw_2D;

    case nDims==2 && dataType=="small" && dataNum=="medium"
        sqw_obj_in=[sqw_2D,sqw_2D,sqw_2D,sqw_2D];

    case nDims==2 && dataType=="small" && dataNum=="large"
        sqw_obj_in=[sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D];

    case nDims==2 && dataType=="medium" && dataNum=="small"
        sqw_obj_in=sqw_2D;

    case nDims==2 && dataType=="medium" && dataNum=="medium"
        sqw_obj_in=[sqw_2D,sqw_2D,sqw_2D,sqw_2D];

    case nDims==2 && dataType=="medium" && dataNum=="large"
        sqw_obj_in=[sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D];

    case nDims==2 && dataType=="large" && dataNum=="small"
        sqw_obj_in=sqw_2D;

    case nDims==2 && dataType=="large" && dataNum=="medium"
        sqw_obj_in=[sqw_2D,sqw_2D,sqw_2D,sqw_2D];

    case nDims==2 && dataType=="large" && dataNum=="large"
        sqw_obj_in=[sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D];

    case nDims==3 && dataType=="small" && dataNum=="small"
        sqw_obj_in=sqw_3D;

    case nDims==3 && dataType=="small" && dataNum=="medium"
        sqw_obj_in=[sqw_3D,sqw_3D,sqw_3D,sqw_3D];

    case nDims==3 && dataType=="small" && dataNum=="large"
        sqw_obj_in=[sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D];

    case nDims==3 && dataType=="medium" && dataNum=="small"
        sqw_obj_in=sqw_3D;

    case nDims==3 && dataType=="medium" && dataNum=="medium"
        sqw_obj_in=[sqw_3D,sqw_3D,sqw_3D,sqw_3D];

    case nDims==3 && dataType=="medium" && dataNum=="large"
        sqw_obj_in=[sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D];

    case nDims==3 && dataType=="large" && dataNum=="small"
        sqw_obj_in=sqw_3D;

    case nDims==3 && dataType=="large" && dataNum=="medium"
        sqw_obj_in=[sqw_3D,sqw_3D,sqw_3D,sqw_3D];

    case nDims==3 && dataType=="large" && dataNum=="large"
        sqw_obj_in=[sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D];
    otherwise
        warning("HORACE:gen_sqw_eval_bm_data:invalid_argument",...
            "dataNum must be valid args")
end
end
