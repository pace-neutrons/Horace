void accumulate_cut(mxLogical *ok, mxArray *&pix_transformed,double *actual_pix_range,mwSize &nPixel_retained,
					double const* pixel_data,mwSize data_size,
					double const* rot_ustep,double const* trans_bott_left,double ebin,double trans_elo, // transformation matrix
					double const* cut_range, bool ignore_nan,bool ignore_inf, // drop pixel conditions;
					int nParallel_threads);
