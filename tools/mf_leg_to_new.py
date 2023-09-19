"""
Script to roughly convert from multifit_legacy to modern multifit syntax

J. Wilkins 8-9-2023
"""

import sys
import re

ARG_TYPE = ("fun", "pin", "free", "bind")
OLD_OPT_TO_NEW = {'fit': 'fit_control_parameters',
                  'list': 'listing',
                  'select': 'selected'}

USAGE = f'{sys.argv[0]} "<original legacy multifit string>"'

DELIM = ["'", '"', r"\[", r"\(",  r"\{"]
CLDELIM = ["'", '"', r"\]", r"\)",  r"\}"]
RE_MATCH = "|".join(f"{ope}[^{clos}]+{clos}"
                    for ope, clos in zip(DELIM, CLDELIM))


def convert_legacy_multifit(string: str) -> str:
    """ Convert a string from multifit_legacy style to modern mfclass syntax """

    # In case of continuation
    string = " ".join(string.split("...\n"))

    # Return what was asked for
    if "=" in string:
        ret, *_ = string.partition("=")
    else:
        ret = "[wfit, fit_data]"

    args = string[string.index('(')+1:string.rindex(')')]
    strargs = re.finditer(RE_MATCH, args)

    # Temporary substitution to avoid commas
    strlist = []
    for i, strarg in enumerate(strargs):
        args = args.replace(strarg.group(0), f"¬{i}", 1)
        strlist.append(strarg.group(0))

    # Restore args to their correct places and remove whitespace
    args = map(lambda x: x.strip(), args.split(","))
    args = [strlist[int(arg[1:])] if arg.startswith("¬") else arg
            for arg in args]

    # Find where key points are
    fhandles_loc = [i for i, arg in enumerate(args) if arg.startswith("@")]
    kwargs_loc = (i for i, arg in enumerate(args) if arg.startswith("'") or arg.startswith('"'))
    kwargs_start = next(kwargs_loc)

    args, kwargs = args[:kwargs_start], args[kwargs_start:]
    if len(fhandles_loc) == 2:  # Have foreground and background
        data, args = args[:fhandles_loc[0]], (args[fhandles_loc[0]:fhandles_loc[1]],
                                              args[fhandles_loc[1]:])
    else:
        data, args = args[:fhandles_loc[0]], (args[fhandles_loc[0]:],)

    # Start processing
    outstr = ""
    outstr += f"kk = multifit({', '.join(data)});\n"

    for back, params in enumerate(args):
        argmt = ARG_TYPE if not back else map(lambda x: f"b{x}", ARG_TYPE)
        for key, val in zip(argmt, params):
            outstr += f"kk = kk.set_{key}({val});\n"

    # Remove extraneous quotes. We add our own where needed
    kw_iter = map(lambda x: x.strip("'\""), kwargs)

    for kw in kw_iter:
        if kw in ("list", "fit", "list", "keep", "mask", "select"):
            val = next(kw_iter)
        if kw in OLD_OPT_TO_NEW:
            outstr += f"kk = kk.set_options('{OLD_OPT_TO_NEW[kw]}', {val});\n"
        elif kw.endswith("ground") and "_" in kw:
            outstr += f"kk.{kw} = true;\n"
        elif kw == "mask":
            outstr += f"kk = kk.set_mask({val});\n"
        elif kw == "keep":
            outstr += f"kk = kk.set_mask(~{val});\n"
        elif kw in ("ranges", "evaluate"):
            outstr += ("warning('HORACE:impossible_auto_conversion', "
                       f"'Cannot convert keyword {kw}')\n")

    outstr += f"{ret} = kk.fit()\n"
    return outstr


if __name__ == '__main__':
    if len(sys.argv) > 1:
        print(convert_legacy_multifit(" ".join(sys.argv[1:])))
    else:
        print(USAGE)
