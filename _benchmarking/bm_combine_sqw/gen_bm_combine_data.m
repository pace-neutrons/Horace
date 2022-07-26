function [cut1, cutN] = gen_bm_combine_data(nDims,dataType, dataNum)
common_data=fullfile(fileparts(fileparts(mfilename('fullpath')...
    )),'common_data');
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr'; 

switch nDims
    case 1
        p1_bin=[-3,0.05,3];p2_bin=[1.9,2.1];p3_bin=[-0.1,0.1];p4_bin=[0,175];
    case 2
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
    otherwise
        error("HORACE:test_combine_sqw_smallData:gen_bm_data:invalid_argument"...
            ,"nDims is the dimensions of the cuts to combine: must be 1 or 2 ")
end

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
        warning("HORACE:gen_combine_bm_data:invalid_argument",...
            "datatype must be either a string (small, medium or large), or an integer")
end

switch true
    case nDims==1 && dataType=="small" && dataNum=="small"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN=copy(cut1);
        cutN.data.pix.signal = 2*cutN.data.pix.signal;

    case nDims==1 && dataType=="small" && dataNum=="medium"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,3);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end

    case nDims==1 && dataType=="small" && dataNum=="large"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,7);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end

    case nDims==1 && dataType=="medium" && dataNum=="small"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN=copy(cut1);
        cutN.data.pix.signal = 2*cutN.data.pix.signal;

    case nDims==1 && dataType=="medium" && dataNum=="medium"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,3);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end

    case nDims==1 && dataType=="medium" && dataNum=="large"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,7);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end

    case nDims==1 && dataType=="large" && dataNum=="small"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN=copy(cut1);
        cutN.data.pix.signal = 2*cutN.data.pix.signal;

    case nDims==1 && dataType=="large" && dataNum=="medium"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,3);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end

    case nDims==1 && dataType=="large" && dataNum=="large"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,7);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end

     case nDims==2 && dataType=="small" && dataNum=="small"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN=copy(cut1);
        cutN.data.pix.signal = 2*cutN.data.pix.signal;

    case nDims==2 && dataType=="small" && dataNum=="medium"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,3);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end

    case nDims==2 && dataType=="small" && dataNum=="large"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,7);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end

    case nDims==2 && dataType=="medium" && dataNum=="small"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN=copy(cut1);
        cutN.data.pix.signal = 2*cutN.data.pix.signal;

    case nDims==2 && dataType=="medium" && dataNum=="medium"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,3);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end

    case nDims==2 && dataType=="medium" && dataNum=="large"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,7);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end

    case nDims==2 && dataType=="large" && dataNum=="small"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN=copy(cut1);
        cutN.data.pix.signal = 2*cutN.data.pix.signal;

    case nDims==2 && dataType=="large" && dataNum=="medium"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,3);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end

    case nDims==2 && dataType=="large" && dataNum=="large"
        cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        cutN = cell(1,7);
        for i=1:numel(cutN)
            cutN{i} = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            cutN{i}.data.pix.signal = 2*cut1.data.pix.signal;
        end
    otherwise
        warning("HORACE:gen_combine_bm_data:invalid_argument",...
            "nDims, dataType and dataNum must be valid args")
end
end

