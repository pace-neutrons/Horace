function sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataNum,dataSet,objType)
%GEN_BM_SQW_EVAL_DATA Summary of this function goes here
%   Detailed explanation goes here
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';

switch true
    case nDims==1 && objType=="sqw"
        p1_bin=[-3,0.05,3];p2_bin=[1.9,2.1];p3_bin=[-0.1,0.1];p4_bin=[0,175];
        sqw_dnd_1D=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case nDims==2 && objType=="sqw"
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
        sqw_dnd_2D=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case nDims==3 && objType=="sqw"
        p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];p4_bin=[0,16,700];
        sqw_dnd_3D=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case nDims==1 && objType=="dnd"
        p1_bin=[-3,0.05,3];p2_bin=[1.9,2.1];p3_bin=[-0.1,0.1];p4_bin=[0,175];
        sqw_dnd_1D=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin,'-nopix');
    case nDims==2 && objType=="dnd"
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
        sqw_dnd_2D=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin,'-nopix');
    case nDims==3 && objType=="dnd"
        p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];p4_bin=[0,16,700];
        sqw_dnd_3D=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin,'-nopix');
    otherwise
        error("HORACE:gen_bm_data:invalid_argument"...
            ,"nDims is the dimensions of the cuts : must be 1, 2 or 3 ")
end

switch true
    case nDims==1 && dataNum=="small" && dataSet=="small"
        sqw_obj=sqw_dnd_1D;

    case nDims==1 && dataNum=="small" && dataSet=="medium"
        sqw_obj=[sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D];
        
    case nDims==1 && dataNum=="small" && dataSet=="large"
        sqw_obj=[sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D];

    case nDims==1 && dataNum=="medium" && dataSet=="small"
        sqw_obj=sqw_dnd_1D;

    case nDims==1 && dataNum=="medium" && dataSet=="medium"
        sqw_obj=[sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D];

    case nDims==1 && dataNum=="medium" && dataSet=="large"
        sqw_obj=[sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D];

    case nDims==1 && dataNum=="large" && dataSet=="small"
        sqw_obj=sqw_dnd_1D;

    case nDims==1 && dataNum=="large" && dataSet=="medium"
        sqw_obj=[sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D];

    case nDims==1 && dataNum=="large" && dataSet=="large"
        sqw_obj=[sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D,sqw_dnd_1D];

    case nDims==2 && dataNum=="small" && dataSet=="small"
        sqw_obj=sqw_dnd_2D;

    case nDims==2 && dataNum=="small" && dataSet=="medium"
        sqw_obj=[sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D];

    case nDims==2 && dataNum=="small" && dataSet=="large"
        sqw_obj=[sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D];

    case nDims==2 && dataNum=="medium" && dataSet=="small"
        sqw_obj=sqw_dnd_2D;

    case nDims==2 && dataNum=="medium" && dataSet=="medium"
        sqw_obj=[sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D];

    case nDims==2 && dataNum=="medium" && dataSet=="large"
        sqw_obj=[sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D];

    case nDims==2 && dataNum=="large" && dataSet=="small"
        sqw_obj=sqw_dnd_2D;

    case nDims==2 && dataNum=="large" && dataSet=="medium"
        sqw_obj=[sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D];

    case nDims==2 && dataNum=="large" && dataSet=="large"
        sqw_obj=[sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D,sqw_dnd_2D];

    case nDims==3 && dataNum=="small" && dataSet=="small"
        sqw_obj=sqw_dnd_3D;

    case nDims==3 && dataNum=="small" && dataSet=="medium"
        sqw_obj=[sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D];

    case nDims==3 && dataNum=="small" && dataSet=="large"
        sqw_obj=[sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D];

    case nDims==3 && dataNum=="medium" && dataSet=="small"
        sqw_obj=sqw_dnd_3D;

    case nDims==3 && dataNum=="medium" && dataSet=="medium"
        sqw_obj=[sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D];

    case nDims==3 && dataNum=="medium" && dataSet=="large"
        sqw_obj=[sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D];

    case nDims==3 && dataNum=="large" && dataSet=="small"
        sqw_obj=sqw_dnd_3D;

    case nDims==3 && dataNum=="large" && dataSet=="medium"
        sqw_obj=[sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D];

    case nDims==3 && dataNum=="large" && dataSet=="large"
        sqw_obj=[sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D,sqw_dnd_3D];

    otherwise
        warning("HORACE:gen_sqw_eval_bm_data:invalid_argument",...
            "nDims, dataType and dataNum must be valid args")
end
end

