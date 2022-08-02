<<<<<<< HEAD
<<<<<<< HEAD
function sqw_obj = gen_bm_tobyfit_data(nDims,dataFile,dataSize,dataSet)
%GEN_TOBYFIT_DATA Summary of this function goes here

pths=horace_paths;
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';

switch dataSize
  case 'small'
      if isfile(dataFile)
          dataSource=dataFile;
      else
          gen_fake_sqw_data(6);
          dataSource = fullfile(pths.bm_common,'NumData6.sqw');
      end
  case 'medium'
      if isfile(dataFile)
          dataSource=dataFile;
      else
          gen_fake_sqw_data(7);
          dataSource = fullfile(pths.bm_common,'NumData7.sqw');
      end
    case 'large'
      if isfile(dataFile)
          dataSource=dataFile;
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
end

switch nDims
    case 1
        p1_bin=[-3,0.05,3];p2_bin=[1.9,2.1];p3_bin=[-0.1,0.1];p4_bin=[0,175];
        sqw=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case 2
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
        sqw=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case 3
        p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];p4_bin=[0,16,700];
        sqw=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
=======
function sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataSize,dataSet)
=======
function sqw_obj = gen_bm_tobyfit_data(nDims,dataFile,dataSize,dataSet)
>>>>>>> 968c751e0 (using horace_paths and updating variable names)
%GEN_TOBYFIT_DATA Summary of this function goes here

pths=horace_paths;
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';

switch dataSize
  case 'small'
      if isfile(dataFile)
          dataSource=dataFile;
      else
          gen_fake_sqw_data(6);
          dataSource = fullfile(pths.bm_common,'NumData6.sqw');
      end
  case 'medium'
      if isfile(dataFile)
          dataSource=dataFile;
      else
          gen_fake_sqw_data(7);
          dataSource = fullfile(pths.bm_common,'NumData7.sqw');
      end
    case 'large'
      if isfile(dataFile)
          dataSource=dataFile;
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
end

switch nDims
    case 1
        p1_bin=[-3,0.05,3];p2_bin=[1.9,2.1];p3_bin=[-0.1,0.1];p4_bin=[0,175];
        sqw=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case 2
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
        sqw=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case 3
        p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];p4_bin=[0,16,700];
<<<<<<< HEAD
        sqw_3D=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
>>>>>>> 7e6efa9a0 (adding tobyfit benchmarks)
=======
        sqw=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
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
        sqw_obj=sqw;
    case 'medium'
        sqw_obj = repmat(sqw,1,4);
    case 'large'
        sqw_obj = repmat(sqw,1,8);
<<<<<<< HEAD
    otherwise
        try
            sqw_obj = repmat(sqw, 1, dataSet);
        catch
            error("HORACE:gen_bm_data:invalid_argument"...
                ,"dataSet is the number of sets : must be small, medium, " + ...
                "large (char) or numeric")
        end
end

=======
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

=======
>>>>>>> d26fc9d4c (getting rid of duplicate code)
    otherwise
        try
            sqw_obj = repmat(sqw, 1, dataSet);
        catch
            error("HORACE:gen_bm_data:invalid_argument"...
                ,"dataSet is the number of sets : must be small, medium, " + ...
                "large (char) or numeric")
        end
end
<<<<<<< HEAD
>>>>>>> 7e6efa9a0 (adding tobyfit benchmarks)
=======

>>>>>>> d26fc9d4c (getting rid of duplicate code)
end