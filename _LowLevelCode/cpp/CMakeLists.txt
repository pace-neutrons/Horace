set(
    MEX_FUNCTIONS
    "combine_sqw"
)

foreach(func "${MEX_FUNCTIONS}")
    add_subdirectory("${func}")
endforeach(func MEX_FUNCTIONS)
