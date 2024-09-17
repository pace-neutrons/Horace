#################
List of functions
#################

Listed here are all the functions and commands that can be used in Horace. Each function is listed with a **brief** description of what it does, and an example syntax for its use.

:ref:`Generating SQW files <manual/Generating_SQW_files:Generating SQW files>`

- :ref:`accumulate_sqw <manual/Generating_SQW_files:accumulate_sqw>`
- :ref:`gen_sqw <manual/Generating_SQW_files:gen_sqw>`


:ref:`Correcting for sample misalignment <manual/Correcting_for_sample_misalignment:Correcting for sample misalignment>`

- :ref:`bragg_positions <manual/Correcting_for_sample_misalignment:bragg_positions>`
- :ref:`bragg_positions_view <manual/Correcting_for_sample_misalignment:bragg_positions_view>`
- :ref:`calc_proj_matrix <manual/Correcting_for_sample_misalignment:calc_proj_matrix>`
- :ref:`crystal_pars_correct <manual/Correcting_for_sample_misalignment:crystal_pars_correct>`
- :ref:`refine_crystal <manual/Correcting_for_sample_misalignment:refine_crystal>`
- :ref:`rlu_corr_to_lattice <manual/Correcting_for_sample_misalignment:rlu_corr_to_lattice>`
- :ref:`ubmatrix <manual/Correcting_for_sample_misalignment:ubmatrix>`
- :ref:`uv_correct <manual/Correcting_for_sample_misalignment:uv_correct>`


:ref:`Data diagnostics <manual/Data_diagnostics:Data diagnostics>`

- :ref:`run_inspector <manual/Data_diagnostics:run_inspector>`


:ref:`Plotting <manual/Plotting:Plotting>`

- :ref:`1-dimensional plot commands <manual/Plotting:pd (plot data)>`
- :ref:`2-dimensional plot commands <manual/Plotting:da (draw area)>`
- :ref:`3-dimensional plot commands <manual/Plotting:sliceomatic>`
- :ref:`Adjusting figures <manual/Plotting:Colour of lines and markers>`
- :ref:`Spaghetti plot <manual/Plotting:spaghetti_plot>`


:ref:`Cutting data of interest from SQW files and objects <manual/Cutting_data_of_interest_from_SQW_files_and_objects:Cutting data of interest from SQW files and objects>`

- :ref:`cut_sqw <manual/Cutting_data_of_interest_from_SQW_files_and_objects:cut>`
- :ref:`cut_sqw <manual/Cutting_data_of_interest_from_SQW_files_and_objects:section>`

:ref:`Special \`\`SQW\`\` information from sqw objects and files <manual/Special_sqw_information:Special \`\`SQW\`\` information from sqw objects and files>`

- :ref:`head_sqw <manual/Special_sqw_information:head>`
- :ref:`extract coordinates <manual/Special_sqw_information:xye>`
- :ref:`save xye ascii file <manual/Special_sqw_information:save_xye>`


:ref:`Loading \`\`sqw\`\` and \`\`dnd\`\` objects to memory <manual/Save_and_load:Loading \`\`sqw\`\` and \`\`dnd\`\` objects to memory>`

- :ref:`read <manual/Save_and_load:read_horace>`
- :ref:`read <manual/Save_and_load:read_sqw>`
- :ref:`read <manual/Save_and_load:read_dnd>`
- :ref:`save <manual/Save_and_load:save>`


:ref:`Symmetrising etc <manual/Symmetrising_etc:Symmetry Operations>`

- :ref:`Symmetrise <manual/Symmetrising_etc:Symmetrising>`
- :ref:`Combine <manual/Symmetrising_etc:Combining>`
- :ref:`Rebin <manual/Symmetrising_etc:Rebinning>`


:ref:`Simulation <manual/Simulation:Simulation>`

- :ref:`func_eval <manual/Simulation:Simulation>`
- :ref:`sqw_eval <manual/Simulation:Simulation>`
- :ref:`disp2sqw_eval <manual/Simulation:Simulation>`
- :ref:`dispersion_plot <manual/Simulation:Simulation>`
- :ref:`disp2sqw_plot <manual/Simulation:Simulation>`

.. _LoF_Fitting:

:ref:`Fitting data <manual/Multifit:Multifit>`

- :ref:`multifit <manual/Multifit:multifit>`
- :ref:`multifit_func <manual/Multifit:multifit_func>`
- :ref:`multifit_sqw <manual/Multifit:multifit_sqw>`
- :ref:`multifit_sqw_sqw <manual/Multifit:multifit_sqw_sqw>`



:ref:`Binary operations <manual/Binary_operations:Binary operations>`

- :ref:`minus <manual/Binary_operations:List of operations and their equivalent code>`
- :ref:`plus <manual/Binary_operations:List of operations and their equivalent code>`
- :ref:`mtimes <manual/Binary_operations:List of operations and their equivalent code>`
- :ref:`mrdivide <manual/Binary_operations:List of operations and their equivalent code>`
- :ref:`mldivide <manual/Binary_operations:List of operations and their equivalent code>`
- :ref:`mpower <manual/Binary_operations:List of operations and their equivalent code>`


:ref:`Unary operations <manual/Unary_operations:Unary operations>`

- :ref:`uplus <manual/Unary_operations:unary plus>`
- :ref:`uminus <manual/Unary_operations:unary minus>`
- :ref:`Trigonometric and hyperbolic functions <manual/Unary_operations:Trigonometric and hyperbolic functions>`
- :ref:`Other mathematical functions <manual/Unary_operations:Other mathematical functions>`


:ref:`Reshaping etc <manual/Reshaping_etc:Other shape functions>`

- :ref:`replicate <manual/Reshaping_etc:\`\`replicate\`\`>`
- :ref:`compact <manual/Reshaping_etc:\`\`compact\`\`>`
- :ref:`permute <manual/Reshaping_etc:\`\`permute\`\`>`
- :ref:`cut <manual/Reshaping_etc:\`\`cut\`\`>`
- :ref:`smooth <manual/Reshaping_etc:\`\`smooth\`\`>`
- :ref:`mask <manual/Reshaping_etc:\`\`mask\`\`>`
- :ref:`mask_points <manual/Reshaping_etc:\`\`mask_points\`\`>`
- :ref:`mask_runs <manual/Reshaping_etc:\`\`mask_runs\`\`>`
- :ref:`section <manual/Reshaping_etc:\`\`section\`\`>`


:ref:`Read or write to disk <manual/Save_and_load:Loading \`\`sqw\`\` and \`\`dnd\`\` objects to memory>`

- :ref:`read_horace <manual/Save_and_load:read_horace>`
- :ref:`read_sqw <manual/Save_and_load:read_sqw>`
- :ref:`read_dnd <manual/Save_and_load:read_dnd>`
- :ref:`save <manual/Save_and_load:save>`
- :ref:`save xye ascii file <manual/Special_sqw_information:save_xye>`
- :ref:`header <manual/Special_sqw_information:head>`

..
   - :ref:`display <manual/Read_or_write_to_disk:display>`


:ref:`Changing object type <manual/Changing_object_type:Changing object type>`

.. Comment from Chris
   The sqw->dnd bits here have the useful information that the pixels are thrown away.
   It could be added that an average of the pixels are left in the image data.

   The dnd->sqw bit is lacking such a comment.
   As the pixel data will be constructed,
   and will presumably lack detail that will be present in a "real" sqw,
   worth at least a note saying how the construction is done

- :ref:`d0d <manual/Changing_object_type:dnd>`
- :ref:`d1d <manual/Changing_object_type:dnd>`
- :ref:`d2d <manual/Changing_object_type:dnd>`
- :ref:`d3d <manual/Changing_object_type:dnd>`
- :ref:`d4d <manual/Changing_object_type:dnd>`
- :ref:`sqw <manual/Changing_object_type:sqw>`

.. Comment from Chris
   A brief description of what IX_dataset_nd is and why it is useful would be good
   Duc: I'm not sure users need to know - maybe just remove this?

.. - :ref:`IX_dataset_1d <manual/Changing_object_type:IX_dataset_1d>`
.. - :ref:`IX_dataset_2d <manual/Changing_object_type:IX_dataset_2d>`
.. - :ref:`IX_dataset_3d <manual/Changing_object_type:IX_dataset_3d>`
