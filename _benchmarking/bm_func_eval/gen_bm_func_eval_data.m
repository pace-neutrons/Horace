<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
function sqw_obj = gen_bm_func_eval_data(nDims,dataFile,dataSize,dataSet)
%GEN_BM_FUNC_EVAL_DATA Summary of this function goes here
%   Detailed explanation goes here

pths = horace_paths;
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';

<<<<<<< HEAD
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
            gen_fake_sqw_data(dataSize)
            filenameStr= "Numdata" + num2str(dataSize) + ".sqw";
            filenameChar = char(filenameStr);
            dataSource=fullfile(pths.bm_common,filenameChar);
        catch
            error("HORACE:gen_bm_data:invalid_argument"...
                ,"dataSize is the size of the sqw object : must be small, " + ...
                "medium, large (char type) or numeric (from 1 to 9)")
        end
=======
function sqw_obj_in = gen_bm_func_eval_data(nDims,dataType,dataNum)
=======
function sqw_obj_in = gen_bm_func_eval_data(nDims,dataSource,dataType,dataNum)
>>>>>>> f19dcce9c (switch to using dummy_sqw to generate bm data)
=======
function sqw_obj = gen_bm_func_eval_data(nDims,dataSource,dataSize,dataSet)
>>>>>>> 8d4db5de5 (updating gen_data functions)
=======
function sqw_obj = gen_bm_func_eval_data(nDims,dataFile,dataSize,dataSet)
>>>>>>> 968c751e0 (using horace_paths and updating variable names)
%GEN_BM_FUNC_EVAL_DATA Summary of this function goes here
%   Detailed explanation goes here

pths = horace_paths;
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';

<<<<<<< HEAD
<<<<<<< HEAD
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
>>>>>>> 4ad9d7cfa (add first benchmarking version)
end

=======
>>>>>>> f19dcce9c (switch to using dummy_sqw to generate bm data)
switch nDims
    case 1
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,175];
<<<<<<< HEAD
        sqw = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case 2
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
        sqw = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case 3
        p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];p4_bin=[0,16,700];
        sqw = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
=======
        sqw_1D = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
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
            gen_fake_sqw_data(dataSize)
            filenameStr= "Numdata" + num2str(dataSize) + ".sqw";
            filenameChar = char(filenameStr);
            dataSource=fullfile(pths.bm_common,filenameChar);
        catch
            error("HORACE:gen_bm_data:invalid_argument"...
                ,"dataSize is the size of the sqw object : must be small, " + ...
                "medium, large (char type) or numeric (from 1 to 9)")
        end
=======
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
>>>>>>> 22c35e817 (changing order of if loop wrapping and adding output variable)
end

switch nDims
    case 1
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,175];
        sqw = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
>>>>>>> 8d4db5de5 (updating gen_data functions)
    case 2
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
        sqw = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case 3
        p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];p4_bin=[0,16,700];
<<<<<<< HEAD
        sqw_3D = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
>>>>>>> 4ad9d7cfa (add first benchmarking version)
=======
        sqw = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
>>>>>>> 8d4db5de5 (updating gen_data functions)
    otherwise
        error("HORACE:gen_bm_data:invalid_argument"...
            ,"nDims is the dimensions of the cuts : must be 1, 2 or 3.")
end

<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 8d4db5de5 (updating gen_data functions)
switch dataSet
    case 'small'
        sqw_obj=sqw;
    case 'medium'
        sqw_obj = repmat(sqw,1,4);
    case 'large'
        sqw_obj = repmat(sqw,1,8);
<<<<<<< HEAD
    otherwise
        try
            sqw_obj = repmat(sqw,1,dataSet);
        catch
            error("HORACE:gen_bm_data:invalid_argument"...
                ,"dataSet is the number of sets : must be small, medium, " + ...
                "large (char) or numeric")
        end
=======
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
>>>>>>> 4ad9d7cfa (add first benchmarking version)
=======
    otherwise
        try
            sqw_obj = repmat(sqw,1,dataSet);
        catch
            error("HORACE:gen_bm_data:invalid_argument"...
                ,"dataSet is the number of sets : must be small, medium, " + ...
                "large (char) or numeric")
        end
>>>>>>> 8d4db5de5 (updating gen_data functions)
end
end
