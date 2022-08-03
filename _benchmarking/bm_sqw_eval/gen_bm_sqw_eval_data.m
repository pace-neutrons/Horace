<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
function sqw_obj = gen_bm_sqw_eval_data(nDims,dataFile,dataSize,dataSet,objType)
%GEN_BM_SQW_EVAL_DATA Summary of this function goes here
%   Detailed explanation goes here

pths = horace_paths;
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';

if is_file(dataFile)
          dataSource=dataFile;
else
    switch dataSize
        case 'small'
            dataSource = gen_fake_sqw_data(6);
        case 'medium'
            dataSource = gen_fake_sqw_data(7);
        case 'large'
            dataSource = gen_fake_sqw_data(8);
        otherwise
            try
                dataSource = gen_fake_sqw_data(dataSize);
            catch
                error("HORACE:gen_bm_data:invalid_argument"...
                    ,"dataSize is the size of the sqw object : must be small, " + ...
                    "medium, large (char type) or numeric (from 1 to 9)")
            end
    end
end
=======
function sqw_obj = gen_bm_sqw_eval_data(nDims,dataNum,dataSet,objType)
=======
function sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataNum,dataSet,objType)
>>>>>>> f19dcce9c (switch to using dummy_sqw to generate bm data)
=======
function sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataSize,dataSet,objType)
>>>>>>> d26fc9d4c (getting rid of duplicate code)
=======
function sqw_obj = gen_bm_sqw_eval_data(nDims,dataFile,dataSize,dataSet,objType)
>>>>>>> 968c751e0 (using horace_paths and updating variable names)
%GEN_BM_SQW_EVAL_DATA Summary of this function goes here
%   Detailed explanation goes here

pths = horace_paths;
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';

<<<<<<< HEAD
<<<<<<< HEAD
if isa(dataNum,'string')
    switch dataNum
        case "small"
            dataSource = fullfile(common_data,'ironSmall.sqw');
        case "medium"
            dataSource = fullfile(common_data,'ironMedium.sqw');
        case "large"
            dataSource = fullfile(common_data,'ironLarge.sqw');
        otherwise
            error("HORACE:gen_sqw_eval_bm_data:invalid_argument",...
                "datatype must be either a string (small, medium or large), or an integer")
    end
>>>>>>> 4ad9d7cfa (add first benchmarking version)

=======
>>>>>>> f19dcce9c (switch to using dummy_sqw to generate bm data)
switch true
    case nDims==1 && objType=="sqw"
        p1_bin=[-3,0.05,3];p2_bin=[1.9,2.1];p3_bin=[-0.1,0.1];p4_bin=[0,175];
<<<<<<< HEAD
        sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case nDims==2 && objType=="sqw"
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
        sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case nDims==3 && objType=="sqw"
        p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];p4_bin=[0,16,700];
        sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case nDims==1 && objType=="dnd"
        p1_bin=[-3,0.05,3];p2_bin=[1.9,2.1];p3_bin=[-0.1,0.1];p4_bin=[0,175];
        sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin,'-nopix');
    case nDims==2 && objType=="dnd"
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
        sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin,'-nopix');
    case nDims==3 && objType=="dnd"
        p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];p4_bin=[0,16,700];
        sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin,'-nopix');
=======
        sqw_dnd_1D=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
=======
switch dataSize
  case 'small'
      if isfile(dataFile)
          dataSource = dataFile;
      else
          gen_fake_sqw_data(6);
          dataSource = fullfile(pths.bm_common,'NumData6.sqw');
      end
  case 'medium'
      if isfile(dataFile)
          dataSource = dataFile;
      else
          gen_fake_sqw_data(7);
          dataSource = fullfile(pths.bm_common,'NumData7.sqw');
      end
    case 'large'
      if isfile(dataFile)
          dataSource = dataFile;
      else
          gen_fake_sqw_data(8);
          dataSource = fullfile(pths.bm_common,'NumData8.sqw');
      end
    otherwise
        try
            gen_fake_sqw_data(dataSize);
            filenameStr= "Numdata" + num2str(dataSize) + ".sqw";
            filenameChar = char(filenameStr);
            dataSource=fullfile(pths.bm_common,filenameChar);
        catch
            error("HORACE:gen_bm_data:invalid_argument"...
                ,"dataSize is the size of the sqw object : must be small, " + ...
                "medium, large (char type) or numeric (from 1 to 9)")
        end
end

switch true
    case nDims==1 && objType=="sqw"
        p1_bin=[-3,0.05,3];p2_bin=[1.9,2.1];p3_bin=[-0.1,0.1];p4_bin=[0,175];
        sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
>>>>>>> d26fc9d4c (getting rid of duplicate code)
    case nDims==2 && objType=="sqw"
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
        sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case nDims==3 && objType=="sqw"
        p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];p4_bin=[0,16,700];
        sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case nDims==1 && objType=="dnd"
        p1_bin=[-3,0.05,3];p2_bin=[1.9,2.1];p3_bin=[-0.1,0.1];p4_bin=[0,175];
        sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin,'-nopix');
    case nDims==2 && objType=="dnd"
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
        sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin,'-nopix');
    case nDims==3 && objType=="dnd"
        p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];p4_bin=[0,16,700];
<<<<<<< HEAD
        sqw_dnd_3D=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin,'-nopix');
>>>>>>> 4ad9d7cfa (add first benchmarking version)
=======
        sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin,'-nopix');
>>>>>>> d26fc9d4c (getting rid of duplicate code)
    otherwise
        error("HORACE:gen_bm_data:invalid_argument"...
            ,"nDims is the dimensions of the cuts : must be 1, 2 or 3 ")
end

<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> d26fc9d4c (getting rid of duplicate code)
switch dataSet
    case 'small'
        sqw_obj=sqw_dnd;
    case 'medium'
        sqw_obj = repmat(sqw_dnd,1,4);
    case 'large'
        sqw_obj = repmat(sqw_dnd,1,8);
<<<<<<< HEAD
    otherwise
        try
            sqw_obj = repmat(sqw_dnd, 1, dataSet);
        catch
            error("HORACE:gen_bm_data:invalid_argument"...
                ,"dataSet is the number of sets : must be small, medium, " + ...
                "large (char) or numeric")
        end
end
end
=======
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

=======
>>>>>>> d26fc9d4c (getting rid of duplicate code)
    otherwise
        try
            sqw_obj = repmat(sqw_dnd, 1, dataSet);
        catch
            error("HORACE:gen_bm_data:invalid_argument"...
                ,"dataSet is the number of sets : must be small, medium, " + ...
                "large (char) or numeric")
        end
end
end
<<<<<<< HEAD

>>>>>>> 4ad9d7cfa (add first benchmarking version)
=======
>>>>>>> 7a8c2792b (Use horace_paths object)
