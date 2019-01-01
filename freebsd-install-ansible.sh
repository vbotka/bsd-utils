#!/bin/sh
# $Id$

# ------------------------------------------------------------------------------
# Copyright (c) 2019, Vladimir Botka <vbotka@gmail.com>
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# ------------------------------------------------------------------------------

# Prepare FreeBSD host to be controlled by Ansible.
# Befor running this script complete the following steps:
# 1) Install system
# 2) Change passord for default user "freebsd" and "root"
# 4) Configure network
# 5) ssh-copy-id freebsd@host
# 6) Install packages

aconf_user="asadmin"
aconf_sudoers="/usr/local/etc/sudoers"
# To run ansible at this host add py27-ansible24
aconf_pkg="sudo perl5 python27"

exerr () { echo -e "$*" >&2 ; exit 1; }

# Create user
if ! id -u ${aconf_user} > /dev/null 2>&1; then
    echo "Create user ${aconf_user}"
    if pw useradd -n ${aconf_user} -s /bin/sh -G wheel -m; then
	echo "[OK] User ${aconf_user} created."
    else
	exerr "[Error] Could not create user."
    fi
else
    echo "[OK] User ${aconf_user} exists."
fi

# Copy authorized_keys
if cp -a /home/freebsd/.ssh /home/asadmin; then
    echo "[OK] SSH authorized_keys copied."
else
    exerr "[Error] Can't copy SSH authorized_keys."
fi
if chown -R ${aconf_user}:${aconf_user} /home/asadmin/.ssh; then
    echo "[OK] Set ownership of SSH authorized_keys."
else
    exerr "[Error] Can't set ownership of SSH authorized_keys."
fi

# Allow user sudo ALL=(ALL) NOPASSWD: ALL
if [ -f ${aconf_sudoers} ]; then
    if  grep -q "${aconf_user} ALL=(ALL) NOPASSWD: ALL" ${aconf_sudoers}; then
	echo "[OK] User ${aconf_user} allowed sudo ALL=(ALL) NOPASSWD: ALL"
    else
	echo "Allow user ${aconf_user} sudo ALL=(ALL) NOPASSWD: ALL"
	echo "${aconf_user} ALL=(ALL) NOPASSWD: ALL" >> ${aconf_sudoers}
    fi
fi

# Install packages
for i in ${aconf_pkg}; do
    pkg info -e $i && echo "[OK] $i is installed" || echo "Install $i"
done

# EOF
