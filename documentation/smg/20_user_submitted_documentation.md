# Handling User-submitted documentation

### Oct 19. 2022

## Introduction

With the migration of the documentation from the wiki environment to GitHub pages, the new documentation has a number of
barriers to entry for not-git-savvy users. To this end, we have endeavoured to create an environment whereby the average
users need only to have an active GitHub account logged in, and subsequently can submit a PR into the system through a
well-defined step-by-step procedure documented on the `Contributing` page. This should hopefully allow contributions
from non-expert users into the documentation without excessive effort or learning requirements on their part.

## Team responsibilities

### Modifications to the documentation

With user-submitted documentation PRs, it should for the most part, simply be a case of reviewing and merging the added
corrections or content through standard review and merge procedures. The exception to normal procedure is that it should
not be expected of the average user to know how to modify/update their branch or respond to PR comments and therefore
should correction or modification be needed, ultimate responsibility for the documentation falls on the
development team.

### Addition of new pages

In terms of managing the addition of new pages to the documentation, a `new_page` file has been added to the root
documentation folder which the "add new page" directs to. This is a template file which the user will edit and submit as
a PR. Obviously this means that responsibility falls on the development team to migrate this file to the appropriate
place, restore the `new_page` file and add the new page into the `toctree`s. The procedure for this follows:

- Check out appropriate PR branch
- Run the following git commands:
```
git mv documentation/user_docs/docs/new_page.rst documentation/user_docs/docs/<new_location>/<title>.rst # e.g. documentation/user_docs/docs/manual/My_new_page.rst
git checkout master documentation/user_docs/docs/new_page.rst # Restore original new_page
```
- Edit the `toctree` adding the new page, e.g.:
```
Horace Manual
=============

.. toctree::
   :caption: Horace Manual Chapters
   :maxdepth: 1

   manual/Changing_Horace_settings
   [...]
   manual/Tobyfit
   manual/My_new_page
```

- Add commit and push changes to PR before merging.
