function sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataSize,dataSet)
%GEN_TOBYFIT_DATA Summary of this function goes here

proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';

switch nDims
    case 1
        p1_bin=[-3,0.05,3];p2_bin=[1.9,2.1];p3_bin=[-0.1,0.1];p4_bin=[0,175];
        sqw_1D=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case 2
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
        sqw_2D=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case 3
        p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];p4_bin=[0,16,700];
        sqw_3D=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    otherwise
        error("HORACE:gen_bm_data:invalid_argument"...
            ,"nDims is the dimensions of the cuts : must be 1, 2 or 3 ")
end

switch true
    case nDims==1 && dataSize=="small" && dataSet=="small"
        sqw_obj=sqw_1D;

    case nDims==1 && dataSize=="small" && dataSet=="medium"
        sqw_obj=[sqw_1D,sqw_1D,sqw_1D,sqw_1D];
        
    case nDims==1 && dataSize=="small" && dataSet=="large"
        sqw_obj=[sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D];

    case nDims==1 && dataSize=="medium" && dataSet=="small"
        sqw_obj=sqw_1D;

    case nDims==1 && dataSize=="medium" && dataSet=="medium"
        sqw_obj=[sqw_1D,sqw_1D,sqw_1D,sqw_1D];

    case nDims==1 && dataSize=="medium" && dataSet=="large"
        sqw_obj=[sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D];

    case nDims==1 && dataSize=="large" && dataSet=="small"
        sqw_obj=sqw_1D;

    case nDims==1 && dataSize=="large" && dataSet=="medium"
        sqw_obj=[sqw_1D,sqw_1D,sqw_1D,sqw_1D];

    case nDims==1 && dataSize=="large" && dataSet=="large"
        sqw_obj=[sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D,sqw_1D];

    case nDims==2 && dataSize=="small" && dataSet=="small"
        sqw_obj=sqw_2D;

    case nDims==2 && dataSize=="small" && dataSet=="medium"
        sqw_obj=[sqw_2D,sqw_2D,sqw_2D,sqw_2D];

    case nDims==2 && dataSize=="small" && dataSet=="large"
        sqw_obj=[sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D];

    case nDims==2 && dataSize=="medium" && dataSet=="small"
        sqw_obj=sqw_2D;

    case nDims==2 && dataSize=="medium" && dataSet=="medium"
        sqw_obj=[sqw_2D,sqw_2D,sqw_2D,sqw_2D];

    case nDims==2 && dataSize=="medium" && dataSet=="large"
        sqw_obj=[sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D];

    case nDims==2 && dataSize=="large" && dataSet=="small"
        sqw_obj=sqw_2D;

    case nDims==2 && dataSize=="large" && dataSet=="medium"
        sqw_obj=[sqw_2D,sqw_2D,sqw_2D,sqw_2D];

    case nDims==2 && dataSize=="large" && dataSet=="large"
        sqw_obj=[sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D,sqw_2D];

    case nDims==3 && dataSize=="small" && dataSet=="small"
        sqw_obj=sqw_3D;

    case nDims==3 && dataSize=="small" && dataSet=="medium"
        sqw_obj=[sqw_3D,sqw_3D,sqw_3D,sqw_3D];

    case nDims==3 && dataSize=="small" && dataSet=="large"
        sqw_obj=[sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D];

    case nDims==3 && dataSize=="medium" && dataSet=="small"
        sqw_obj=sqw_3D;

    case nDims==3 && dataSize=="medium" && dataSet=="medium"
        sqw_obj=[sqw_3D,sqw_3D,sqw_3D,sqw_3D];

    case nDims==3 && dataSize=="medium" && dataSet=="large"
        sqw_obj=[sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D];

    case nDims==3 && dataSize=="large" && dataSet=="small"
        sqw_obj=sqw_3D;

    case nDims==3 && dataSize=="large" && dataSet=="medium"
        sqw_obj=[sqw_3D,sqw_3D,sqw_3D,sqw_3D];

    case nDims==3 && dataSize=="large" && dataSet=="large"
        sqw_obj=[sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D,sqw_3D];

    otherwise
        warning("HORACE:gen_sqw_eval_bm_data:invalid_argument",...
            "nDims, dataType and dataNum must be valid args")
end
end