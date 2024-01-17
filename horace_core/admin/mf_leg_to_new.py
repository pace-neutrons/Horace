"""
Script to roughly convert from multifit_legacy to modern multifit syntax

J. Wilkins 8-9-2023
"""

import doctest
import re
import sys
import unittest
from typing import Iterator

ARG_TYPE = ("fun", "pin", "free", "bind")
OLD_OPT_TO_NEW = {'fit': 'fit_control_parameters',
                  'list': 'listing',
                  'select': 'selected'}

USAGE = f'{sys.argv[0]} "<original legacy multifit string>"'

DELIM = "[({"
CLDELIM = "])}"
STRDELIM = "'\""


def get_args(string: str) -> Iterator[str]:
    """ Get arguments from argument list using rudimentary delim counting """
    stack = []

    accum = ""
    str_mode = False

    for ind, char in enumerate(string):
        if char in STRDELIM:
            if not str_mode:
                stack.append(char)
                str_mode = True

            elif stack[-1] == char:  # Only leave string mode if matching quote
                stack.pop()
                str_mode = False

        elif str_mode:
            pass

        elif char in DELIM:
            stack.append(CLDELIM[DELIM.index(char)])

        elif char in CLDELIM:
            if not stack:
                raise ValueError(f"Unmatched delim at char {ind} in: \n{string}\n{' '*ind+'^'}\n"
                                 f"Got {char}")
            tmp = stack.pop()
            if tmp != char:
                raise ValueError(f"Unmatched delim at char {ind} in: \n{string}\n{' '*ind+'^'}\n"
                                 f"Expected {tmp} got {char}")

        elif char == "," and not stack:
            yield accum.strip(" \t\n,")
            accum = ""

        accum += char

    if stack:
        raise ValueError(f"Unexpected end in {string}, perhaps an unmatched delimiter?")

    yield accum.strip(" \t\n,")


def convert_legacy_multifit(string: str) -> str:
    """ Convert a MATLAB multifit line from multifit_legacy style to modern mfclass syntax

    >>> print(convert_legacy_multifit("[wfit, fitdata] = multifit_sqw(my_new_cut, @sr122_xsec, pars, pfree, pbind, 'list', 1)"))
    kk = multifit(my_new_cut);
    kk = kk.set_fun(@sr122_xsec);
    kk = kk.set_pin(pars);
    kk = kk.set_free(pfree);
    kk = kk.set_bind(pbind);
    kk = kk.set_options('listing', 1);
    [wfit, fitdata] = kk.fit();
    <BLANKLINE>
    """

    # In case of continuation
    string = " ".join(string.split("...\n"))

    # Return what was asked for
    if "=" in string:
        ret = string.split("=", 1)[0].strip()
    else:
        ret = "[wfit, fit_data]"

    args = string[string.index('(')+1:string.rindex(')')]

    args = list(get_args(args))

    typ = re.search("fit((?:_sqw){0,2})", string)

    # Find where key points are
    fhandles_loc = [i for i, arg in enumerate(args) if arg.startswith("@")]
    kwargs_loc = [i for i, arg in enumerate(args) if arg.startswith("'") or arg.startswith('"')]

    if not fhandles_loc:
        raise IOError("Cannot identify fitting functions. Please explicitly note with '@func'")

    if kwargs_loc:
        kwargs_start = slice(0, kwargs_loc[0]), slice(kwargs_loc[0], len(args))
    else:
        kwargs_start = slice(0, len(args)), slice(0, 0)

    args, kwargs = args[kwargs_start[0]], args[kwargs_start[1]]
    if len(fhandles_loc) == 2:  # Have foreground and background
        data, args = args[:fhandles_loc[0]], (args[fhandles_loc[0]:fhandles_loc[1]],
                                              args[fhandles_loc[1]:])
    else:
        data, args = args[:fhandles_loc[0]], (args[fhandles_loc[0]:],)

    # Start processing
    outstr = ""
    outstr += f"kk = multifit{typ[1]}({', '.join(data)});\n"

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

    outstr += f"{ret} = kk.fit();\n"
    return outstr


class TestConversion(unittest.TestCase):

    def test_a(self):
        ans = convert_legacy_multifit("[wfit, fitdata] = multifit_sqw"
                                      "(my_new_cut, @sr122_xsec, pars,"
                                      "pfree, pbind, 'list', 1)")

        self.assertEqual(ans, """
kk = multifit(my_new_cut);
kk = kk.set_fun(@sr122_xsec);
kk = kk.set_pin(pars);
kk = kk.set_free(pfree);
kk = kk.set_bind(pbind);
kk = kk.set_options('listing', 1);
[wfit, fitdata] = kk.fit();
""".lstrip())

    def test_b(self):
        ans = convert_legacy_multifit("[wfit,fitdata]=multifit_sqw"
                                      "(my_new_cut,@sr122_xsec,pars,"
                                      "pfree,@bfunc,bpars,bfree,bpbind, 'list',1)")
        self.assertEqual(ans, """
kk = multifit(my_new_cut);
kk = kk.set_fun(@sr122_xsec);
kk = kk.set_pin(pars);
kk = kk.set_free(pfree);
kk = kk.set_bfun(@bfunc);
kk = kk.set_bpin(bpars);
kk = kk.set_bfree(bfree);
kk = kk.set_bbind(bpbind);
kk = kk.set_options('listing', 1);
[wfit,fitdata] = kk.fit();
""".lstrip())

    def test_c(self):
        ans = convert_legacy_multifit("multifit(mynewcut, @x, p, pf,"
                                      "pb, @bf, bp, [true false false],"
                                      "{1, 2, 3}, 'list', n,"
                                      "'fit', [1 2 3], 'global_foreground',"
                                      "'local_background', 'evaluate' 'chisqr',"
                                      "'foreground', 'list', n, 'keep',"
                                      "[1 2 3 4], 'mask', [1 1 1 0 0 0],"
                                      "'ranges', 'select', false, 'average')")

        self.assertEqual(ans, """
kk = multifit(mynewcut);
kk = kk.set_fun(@x);
kk = kk.set_pin(p);
kk = kk.set_free(pf);
kk = kk.set_bind(pb);
kk = kk.set_bfun(@bf);
kk = kk.set_bpin(bp);
kk = kk.set_bfree([true false false]);
kk = kk.set_bbind({1, 2, 3});
kk = kk.set_options('listing', n);
kk = kk.set_options('fit_control_parameters', [1 2 3]);
kk.global_foreground = true;
kk.local_background = true;
kk = kk.set_options('listing', n);
kk = kk.set_mask(~[1 2 3 4]);
kk = kk.set_mask([1 1 1 0 0 0]);
warning('HORACE:impossible_auto_conversion', 'Cannot convert keyword ranges')
kk = kk.set_options('selected', false);
[wfit, fit_data] = kk.fit();
""".lstrip())

    def test_d(self):
        ans = convert_legacy_multifit("multifit(x, y, e, @x, p, pf, pb, @bf, bp,"
                                      "[true false false], {1, 2, 3}, "
                                      "'fit', [1 2 3],"
                                      "'global_foreground', 'local_background',"
                                      " 'evaluate' 'chisqr', 'foreground', "
                                      "'list', n, 'keep', [1 2 3 4], "
                                      "'mask', [1 1 1 0 0 0], 'ranges', "
                                      "'select', false, 'average')")

        self.assertEqual(ans, """
kk = multifit(x, y, e);
kk = kk.set_fun(@x);
kk = kk.set_pin(p);
kk = kk.set_free(pf);
kk = kk.set_bind(pb);
kk = kk.set_bfun(@bf);
kk = kk.set_bpin(bp);
kk = kk.set_bfree([true false false]);
kk = kk.set_bbind({1, 2, 3});
kk = kk.set_options('fit_control_parameters', [1 2 3]);
kk.global_foreground = true;
kk.local_background = true;
kk = kk.set_options('listing', n);
kk = kk.set_mask(~[1 2 3 4]);
kk = kk.set_mask([1 1 1 0 0 0]);
warning('HORACE:impossible_auto_conversion', 'Cannot convert keyword ranges')
kk = kk.set_options('selected', false);
[wfit, fit_data] = kk.fit();
""".lstrip())


def load_tests(loader, tests, ignore):
    tests.addTests(doctest.DocTestSuite())
    return tests


if __name__ == '__main__':
    if "test" == sys.argv[1]:
        del sys.argv[1]
        unittest.main()
    elif len(sys.argv) > 1:
        print(convert_legacy_multifit(" ".join(sys.argv[1:])))
    else:
        print(USAGE)
