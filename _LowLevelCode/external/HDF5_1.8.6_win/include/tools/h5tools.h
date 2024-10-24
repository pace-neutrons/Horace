/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Copyright by The HDF Group.                                               *
 * Copyright by the Board of Trustees of the University of Illinois.         *
 * All rights reserved.                                                      *
 *                                                                           *
 * This file is part of HDF5.  The full HDF5 copyright notice, including     *
 * terms governing use, modification, and redistribution, is contained in    *
 * the files COPYING and Copyright.html.  COPYING can be found at the root   *
 * of the source code distribution tree; Copyright.html can be found at the  *
 * root level of an installed copy of the electronic HDF5 document set and   *
 * is linked from the top-level documents page.  It can also be found at     *
 * http://hdfgroup.org/HDF5/doc/Copyright.html.  If you do not have          *
 * access to either file, you may request a copy from help@hdfgroup.org.     *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/*
 * Programmer:  Robb Matzke <matzke@llnl.gov>
 *              Thursday, July 23, 1998
 *
 * Purpose:     Support functions for the various tools.
 */
#ifndef H5TOOLS_H__
#define H5TOOLS_H__

#include "hdf5.h"
#include "h5tools_error.h"

#define ESCAPE_HTML             1
#define OPT(X,S)                ((X) ? (X) : (S))
#define OPTIONAL_LINE_BREAK     "\001"  /* Special strings embedded in the output */
#define START_OF_DATA       0x0001
#define END_OF_DATA     0x0002

/*
 * The output functions need a temporary buffer to hold a piece of the
 * dataset while it's being printed. This constant sets the limit on the
 * size of that temporary buffer in bytes. For efficiency's sake, choose the
 * largest value suitable for your machine (for testing use a small value).
 */
#if 1
#define H5TOOLS_BUFSIZE         (1024 * 1024)
#else
#define H5TOOLS_BUFSIZE         (1024)
#endif

/*
 * Maximum size used in a call to malloc
 */
#define H5TOOLS_MALLOCSIZE      (128 * 1024 * 1024)

/* format for hsize_t */
#define HSIZE_T_FORMAT   "%"H5_PRINTF_LL_WIDTH"u"

#define H5TOOLS_DUMP_MAX_RANK     H5S_MAX_RANK

/*
 * Strings for output - these were duplicated from the h5dump.h
 * file in order to support region reference data display
 */
#define ATTRIBUTE       "ATTRIBUTE"
#define BLOCK           "BLOCK"
#define SUPER_BLOCK     "SUPER_BLOCK"
#define COMPRESSION     "COMPRESSION"
#define CONCATENATOR    "//"
#define COMPLEX         "COMPLEX"
#define COUNT           "COUNT"
#define CSET            "CSET"
#define CTYPE           "CTYPE"
#define DATA            "DATA"
#define DATASPACE       "DATASPACE"
#define EXTERNAL        "EXTERNAL"
#define FILENO          "FILENO"
#define HARDLINK        "HARDLINK"
#define NLINK           "NLINK"
#define OBJID           "OBJECTID"
#define OBJNO           "OBJNO"
#define S_SCALAR        "SCALAR"
#define S_SIMPLE        "SIMPLE"
#define S_NULL          "NULL"
#define SOFTLINK        "SOFTLINK"
#define EXTLINK         "EXTERNAL_LINK"
#define UDLINK          "USERDEFINED_LINK"
#define START           "START"
#define STRIDE          "STRIDE"
#define STRSIZE         "STRSIZE"
#define STRPAD          "STRPAD"
#define SUBSET          "SUBSET"
#define FILTERS         "FILTERS"
#define DEFLATE         "COMPRESSION DEFLATE"
#define DEFLATE_LEVEL   "LEVEL"
#define SHUFFLE         "PREPROCESSING SHUFFLE"
#define FLETCHER32      "CHECKSUM FLETCHER32"
#define SZIP            "COMPRESSION SZIP"
#define NBIT            "COMPRESSION NBIT"
#define SCALEOFFSET            "COMPRESSION SCALEOFFSET"
#define SCALEOFFSET_MINBIT            "MIN BITS"
#define STORAGE_LAYOUT  "STORAGE_LAYOUT"
#define CONTIGUOUS      "CONTIGUOUS"
#define COMPACT         "COMPACT"
#define CHUNKED         "CHUNKED"
#define EXTERNAL_FILE   "EXTERNAL_FILE"
#define FILLVALUE       "FILLVALUE"
#define FILE_CONTENTS   "FILE_CONTENTS"

#define BEGIN           "{"
#define END             "}"

/*
 * dump structure for output - this was duplicated from the h5dump.h
 * file in order to support region reference data display
 */
typedef struct h5tools_dump_header_t {
    const char *name;
    const char *filebegin;
    const char *fileend;
    const char *bootblockbegin;
    const char *bootblockend;
    const char *groupbegin;
    const char *groupend;
    const char *datasetbegin;
    const char *datasetend;
    const char *attributebegin;
    const char *attributeend;
    const char *datatypebegin;
    const char *datatypeend;
    const char *dataspacebegin;
    const char *dataspaceend;
    const char *databegin;
    const char *dataend;
    const char *softlinkbegin;
    const char *softlinkend;
    const char *extlinkbegin;
    const char *extlinkend;
    const char *udlinkbegin;
    const char *udlinkend;
    const char *subsettingbegin;
    const char *subsettingend;
    const char *startbegin;
    const char *startend;
    const char *stridebegin;
    const char *strideend;
    const char *countbegin;
    const char *countend;
    const char *blockbegin;
    const char *blockend;

    const char *fileblockbegin;
    const char *fileblockend;
    const char *bootblockblockbegin;
    const char *bootblockblockend;
    const char *groupblockbegin;
    const char *groupblockend;
    const char *datasetblockbegin;
    const char *datasetblockend;
    const char *attributeblockbegin;
    const char *attributeblockend;
    const char *datatypeblockbegin;
    const char *datatypeblockend;
    const char *dataspaceblockbegin;
    const char *dataspaceblockend;
    const char *datablockbegin;
    const char *datablockend;
    const char *softlinkblockbegin;
    const char *softlinkblockend;
    const char *extlinkblockbegin;
    const char *extlinkblockend;
    const char *udlinkblockbegin;
    const char *udlinkblockend;
    const char *strblockbegin;
    const char *strblockend;
    const char *enumblockbegin;
    const char *enumblockend;
    const char *structblockbegin;
    const char *structblockend;
    const char *vlenblockbegin;
    const char *vlenblockend;
    const char *subsettingblockbegin;
    const char *subsettingblockend;
    const char *startblockbegin;
    const char *startblockend;
    const char *strideblockbegin;
    const char *strideblockend;
    const char *countblockbegin;
    const char *countblockend;
    const char *blockblockbegin;
    const char *blockblockend;

    const char *dataspacedescriptionbegin;
    const char *dataspacedescriptionend;
    const char *dataspacedimbegin;
    const char *dataspacedimend;

} h5tools_dump_header_t;

/*
 * Information about how to format output.
 */
typedef struct h5tool_format_t {
    /*
     * Fields associated with formatting numeric data.  If a datatype matches
     * multiple formats based on its size, then the first applicable format
     * from this list is used. However, if `raw' is non-zero then dump all
     * data in hexadecimal format without translating from what appears on
     * disk.
     *
     *   raw:        If set then print all data as hexadecimal without
     *               performing any conversion from disk.
     *
     *   fmt_raw:    The printf() format for each byte of raw data. The
     *               default is `%02x'.
     *
     *   fmt_int:    The printf() format to use when rendering data which is
     *               typed `int'. The default is `%d'.
     *
     *   fmt_uint:   The printf() format to use when rendering data which is
     *               typed `unsigned'. The default is `%u'.
     *
     *   fmt_schar:  The printf() format to use when rendering data which is
     *               typed `signed char'. The default is `%d'. This format is
     *               used ony if the `ascii' field is zero.
     *
     *   fmt_uchar:  The printf() format to use when rendering data which is
     *               typed `unsigned char'. The default is `%u'. This format
     *               is used only if the `ascii' field is zero.
     *
     *   fmt_short:  The printf() format to use when rendering data which is
     *               typed `short'. The default is `%d'.
     *
     *   fmt_ushort: The printf() format to use when rendering data which is
     *               typed `unsigned short'. The default is `%u'.
     *
     *   fmt_long:   The printf() format to use when rendering data which is
     *               typed `long'. The default is `%ld'.
     *
     *   fmt_ulong:  The printf() format to use when rendering data which is
     *               typed `unsigned long'. The default is `%lu'.
     *
     *   fmt_llong:  The printf() format to use when rendering data which is
     *               typed `long long'. The default depends on what printf()
     *               format is available to print this datatype.
     *
     *   fmt_ullong: The printf() format to use when rendering data which is
     *               typed `unsigned long long'. The default depends on what
     *               printf() format is available to print this datatype.
     *
     *   fmt_double: The printf() format to use when rendering data which is
     *               typed `double'. The default is `%g'.
     *
     *   fmt_float:  The printf() format to use when rendering data which is
     *               typed `float'. The default is `%g'.
     *
     *   ascii:      If set then print 1-byte integer values as an ASCII
     *               character (no quotes).  If the character is one of the
     *               standard C escapes then print the escaped version.  If
     *               the character is unprintable then print a 3-digit octal
     *               escape.  If `ascii' is zero then then 1-byte integers are
     *               printed as numeric values.  The default is zero.
     *
     *   str_locale: Determines how strings are printed. If zero then strings
     *               are printed like in C except. If set to ESCAPE_HTML then
     *               strings are printed using HTML encoding where each
     *               character not in the class [a-zA-Z0-9] is substituted
     *               with `%XX' where `X' is a hexadecimal digit.
     *
     *   str_repeat: If set to non-zero then any character value repeated N
     *               or more times is printed as 'C'*N
     *
     * Numeric data is also subject to the formats for individual elements.
     */
    hbool_t     raw;
    const char  *fmt_raw;
    const char  *fmt_int;
    const char  *fmt_uint;
    const char  *fmt_schar;
    const char  *fmt_uchar;
    const char  *fmt_short;
    const char  *fmt_ushort;
    const char  *fmt_long;
    const char  *fmt_ulong;
    const char  *fmt_llong;
    const char  *fmt_ullong;
    const char  *fmt_double;
    const char  *fmt_float;
    int         ascii;
    int         str_locale;
    int         str_repeat;

    /*
     * Fields associated with compound array members.
     *
     *   pre:       A string to print at the beginning of each array. The
     *              default value is the left square bracket `['.
     *
     *   sep:       A string to print between array values.  The default
     *              value is a ",\001" ("\001" indicates an optional line
     *              break).
     *
     *   suf:       A string to print at the end of each array.  The default
     *              value is a right square bracket `]'.
     *
     *   linebreaks: a boolean value to determine if we want to break the line
     *               after each row of an array.
     */
    const char  *arr_pre;
    const char  *arr_sep;
    const char  *arr_suf;
    int         arr_linebreak;

    /*
     * Fields associated with compound data types.
     *
     *   name:      How the name of the struct member is printed in the
     *              values. By default the name is not printed, but a
     *              reasonable setting might be "%s=" which prints the name
     *              followed by an equal sign and then the value.
     *
     *   sep:       A string that separates one member from another.  The
     *              default is ", \001" (the \001 indicates an optional
     *              line break to allow structs to span multiple lines of
     *              output).
     *
     *   pre:       A string to print at the beginning of a compound type.
     *              The default is a left curly brace.
     *
     *   suf:       A string to print at the end of each compound type.  The
     *              default is  right curly brace.
     *
     *   end:       a string to print after we reach the last element of
     *              each compound type. prints out before the suf.
     */
    const char  *cmpd_name;
    const char  *cmpd_sep;
    const char  *cmpd_pre;
    const char  *cmpd_suf;
    const char  *cmpd_end;

    /*
     * Fields associated with vlen data types.
     *
     *   sep:       A string that separates one member from another.  The
     *              default is ", \001" (the \001 indicates an optional
     *              line break to allow structs to span multiple lines of
     *              output).
     *
     *   pre:       A string to print at the beginning of a vlen type.
     *              The default is a left parentheses.
     *
     *   suf:       A string to print at the end of each vlen type.  The
     *              default is a right parentheses.
     *
     *   end:       a string to print after we reach the last element of
     *              each compound type. prints out before the suf.
     */
    const char  *vlen_sep;
    const char  *vlen_pre;
    const char  *vlen_suf;
    const char  *vlen_end;

    /*
     * Fields associated with the individual elements.
     *
     *   fmt:       A printf(3c) format to use to print the value string
     *              after it has been rendered.  The default is "%s".
     *
     *   suf1:      This string is appended to elements which are followed by
     *              another element whether the following element is on the
     *              same line or the next line.  The default is a comma.
     *
     *   suf2:      This string is appended (after `suf1') to elements which
     *              are followed on the same line by another element.  The
     *              default is a single space.
     */
    const char  *elmt_fmt;
    const char  *elmt_suf1;
    const char  *elmt_suf2;

    /*
     * Fields associated with the index values printed at the left edge of
     * each line of output.
     *
     *   n_fmt:     Each index value is printed according to this printf(3c)
     *              format string which should include a format for a long
     *              integer.  The default is "%lu".
     *
     *   sep:       Each integer in the index list will be separated from the
     *              others by this string, which defaults to a comma.
     *
     *   fmt:       After the index values are formated individually and
     *              separated from one another by some string, the entire
     *              resulting string will be formated according to this
     *              printf(3c) format which should include a format for a
     *              character string.  The default is "%s".
     */
    const char  *idx_n_fmt;             /*index number format           */
    const char  *idx_sep;               /*separator between numbers     */
    const char  *idx_fmt;               /*entire index format           */

    /*
     * Fields associated with entire lines.
     *
     *   ncols:     Number of columns per line defaults to 80.
     *
     *   per_line:  If this field has a positive value then every Nth element
     *              will be printed at the beginning of a line.
     *
     *   pre:       Each line of output contains an optional prefix area
     *              before the data. This area can contain the index for the
     *              first datum (represented by `%s') as well as other
     *              constant text.  The default value is `%s'.
     *
     *   1st:       This is the format to print at the beginning of the first
     *              line of output. The default value is the current value of
     *              `pre' described above.
     *
     *   cont:      This is the format to print at the beginning of each line
     *              which was continued because the line was split onto
     *              multiple lines. This often happens with compound
     *              data which is longer than one line of output. The default
     *              value is the current value of the `pre' field
     *              described above.
     *
     *   suf:       This character string will be appended to each line of
     *              output.  It should not contain line feeds.  The default
     *              is the empty string.
     *
     *   sep:       A character string to be printed after every line feed
     *              defaulting to the empty string.  It should end with a
     *              line feed.
     *
     *   multi_new: Indicates the algorithm to use when data elements tend to
     *              occupy more than one line of output. The possible values
     *              are (zero is the default):
     *
     *              0:  No consideration. Each new element is printed
     *                  beginning where the previous element ended.
     *
     *              1:  Print the current element beginning where the
     *                  previous element left off. But if that would result
     *                  in the element occupying more than one line and it
     *                  would only occupy one line if it started at the
     *                  beginning of a line, then it is printed at the
     *                  beginning of the next line.
     *
     *   multi_new: If an element is continued onto additional lines then
     *              should the following element begin on the next line? The
     *              default is to start the next element on the same line
     *              unless it wouldn't fit.
     *
     * indentlevel: a string that shows how far to indent if extra spacing
     *              is needed. dumper uses it.
     */
    int         line_ncols;             /*columns of output             */
    size_t      line_per_line;          /*max elements per line         */
    const char  *line_pre;              /*prefix at front of each line  */
    const char  *line_1st;              /*alternate pre. on first line  */
    const char  *line_cont;             /*alternate pre. on continuation*/
    const char  *line_suf;              /*string to append to each line */
    const char  *line_sep;              /*separates lines               */
    int         line_multi_new;         /*split multi-line outputs?     */
    const char  *line_indent;           /*for extra identation if we need it*/

    /*used to skip the first set of checks for line length*/
    int skip_first;

    /*flag used to hide or show the file number for obj refs*/
    int obj_hidefileno;

    /*string used to format the output for the obje refs*/
    const char *obj_format;

    /*flag used to hide or show the file number for dataset regions*/
    int dset_hidefileno;

    /*string used to format the output for the dataset regions*/
    const char *dset_format;

    const char *dset_blockformat_pre;
    const char *dset_ptformat_pre;
    const char *dset_ptformat;

    /*print array indices in output matrix */
    int pindex;

    /*escape non printable characters */
    int do_escape;

} h5tool_format_t;

typedef struct h5tools_context_t {
    size_t cur_column;                       /*current column for output */
    size_t cur_elmt;                         /*current element/output line */
    int  need_prefix;                        /*is line prefix needed? */
    unsigned ndims;                          /*dimensionality  */
    hsize_t p_min_idx[H5S_MAX_RANK];         /*min selected index */
    hsize_t p_max_idx[H5S_MAX_RANK];         /*max selected index */
    int  prev_multiline;                     /*was prev datum multiline? */
    size_t prev_prefix_len;                  /*length of previous prefix */
    int  continuation;                       /*continuation of previous data?*/
    hsize_t size_last_dim;                   /*the size of the last dimension,
                                              *needed so we can break after each
                                              *row */
    int  indent_level;                 /*the number of times we need some
                                       *extra indentation */
    int  default_indent_level;        /*this is used when the indent level gets changed */
    hsize_t acc[H5S_MAX_RANK];        /* accumulator position */
    hsize_t pos[H5S_MAX_RANK];        /* matrix position */
    hsize_t sm_pos;                   /* current stripmine element position */
} h5tools_context_t;

typedef struct subset_d {
    hsize_t     *data;
    unsigned int len;
} subset_d;

/* a structure to hold the subsetting particulars for a dataset */
struct subset_t {
    subset_d start;
    subset_d stride;
    subset_d count;
    subset_d block;
};

/* The following include, h5tools_str.h, must be after the
 * above stucts are defined. There is a dependency in the following
 * include that hasn't been identified yet. */

#include "h5tools_str.h"

#ifdef __cplusplus
extern "C" {
#endif
    
#ifdef H5_HAVE_H5DUMP_PACKED_BITS
H5TOOLS_DLLVAR int     packed_bits_num;       /* number of packed bits to display */
H5TOOLS_DLLVAR int         packed_data_offset; /* offset of packed bits to display */
H5TOOLS_DLLVAR unsigned int packed_data_mask;  /* mask in which packed bits to display */
#endif

H5TOOLS_DLLVAR FILE   *rawdatastream;       /* output stream for raw data */
H5TOOLS_DLLVAR int     bin_output;          /* binary output */
H5TOOLS_DLLVAR int     bin_form;            /* binary form */
H5TOOLS_DLLVAR int     region_output;       /* region output */

/* Strings for output */
#define H5_TOOLS_GROUP           "GROUP"
#define H5_TOOLS_DATASET         "DATASET"
#define H5_TOOLS_DATATYPE        "DATATYPE"

/* Definitions of useful routines */
H5TOOLS_DLL void     h5tools_init(void);
H5TOOLS_DLL void     h5tools_close(void);
H5TOOLS_DLL hid_t    h5tools_fopen(const char *fname, unsigned flags, hid_t fapl,
                    const char *driver, char *drivername, size_t drivername_len);
H5TOOLS_DLL int      h5tools_dump_dset(FILE *stream, const h5tool_format_t *info, hid_t dset,
                                  hid_t p_typ, struct subset_t *sset, int indentlevel);
H5TOOLS_DLL int      h5tools_dump_mem(FILE *stream, const h5tool_format_t *info, hid_t obj_id,
                                 hid_t type, hid_t space, void *mem, int indentlevel);
H5TOOLS_DLL hid_t    h5tools_get_native_type(hid_t type);
H5TOOLS_DLL hid_t    h5tools_get_little_endian_type(hid_t type);
H5TOOLS_DLL hid_t    h5tools_get_big_endian_type(hid_t type);


H5TOOLS_DLL void     h5tools_dump_simple_data(FILE *stream, const h5tool_format_t *info, hid_t container,
                         h5tools_context_t *ctx/*in,out*/, unsigned flags,
                         hsize_t nelmts, hid_t type, void *_mem);

H5TOOLS_DLL int      h5tools_canreadf(const char* name,
                                 hid_t dcpl_id);
H5TOOLS_DLL int      h5tools_can_encode(H5Z_filter_t filtn);

void            init_acc_pos(h5tools_context_t *ctx, hsize_t *dims);
/*
 * new functions needed to display region reference data
 */
void            h5tools_dump_datatype(FILE *stream, const h5tool_format_t *info,
                         h5tools_context_t *ctx/*in,out*/, hid_t type);
int             h5tools_print_dataspace(h5tools_str_t *buffer/*in,out*/, hid_t space);
int             h5tools_print_datatype(h5tools_str_t *buffer/*in,out*/,
                         const h5tool_format_t *info, h5tools_context_t *ctx/*in,out*/,
                         hid_t type);
int             h5tools_print_enum(h5tools_str_t *buffer/*in,out*/, hid_t type);
#ifdef __cplusplus
}
#endif

#endif /* H5TOOLS_H__ */

