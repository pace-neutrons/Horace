#!/usr/bin/env bash
#=============================================================================
# Copyright 2010-2011 Kitware, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#=============================================================================

# Prepare a copy of the message:
#  - strip comment lines
#  - stop at "diff --git" (git commit -v)
# Later versions of git gui on Windows don't set this properly
if [ -z "$GIT_DIR" ]; then
  GIT_DIR=$(git rev-parse --git-dir)
fi
commit_msg="$GIT_DIR/COMMIT_MSG"
sed -n -e '/^#/d' -e '/^diff --git/q' -e 'p;d' "$1" > "$commit_msg"

die_advice='
To continue editing, run the command
  git commit -e -F '"$commit_msg"'
(assuming your working directory is at the top).'

die() {
	echo 'commit-msg hook failure' 1>&2
	echo '-----------------------' 1>&2
	echo '' 1>&2
	echo "$@" 1>&2
	test -n "$die_advice" && echo "$die_advice" 1>&2
	exit 1
}

#-----------------------------------------------------------------------------
# Check the commit message layout with a simple state machine.

msg_is_merge() {
	test -f "$GIT_DIR/MERGE_HEAD" &&
	echo "$line" | grep "^Merge " >/dev/null 2>&1
}

msg_is_revert() {
	echo "$line" | grep "^Revert " >/dev/null 2>&1
}

# This method taken from http://github.com/stephenh/git-central
msg_trac() {
	grep -i '\(\(re\|refs\|qa\) #[0-9]\+\)\|\(no ticket\)' "$commit_msg" > /dev/null

	if [ $? -ne 0 ]
	then
		die 'Please reference a trac ticket via "Re(fs)"'
	fi
}


# First check that a ticket is referenced - disable for now
#msg_trac
# Pipe commit message into the state machine.
state=first
cat "$commit_msg" |
while IFS='' read line; do
	msg_$state || break
done &&
rm -f "$commit_msg" || exit 1
die_advice='' # No more temporary message file.



#-----------------------------------------------------------------------------
# Chain to project-specific hook.
#. "$GIT_DIR/hooks/hooks-chain.bash"
#hooks_chain commit-msg "$@"
