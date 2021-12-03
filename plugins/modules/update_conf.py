#!/usr/bin/python

# (c) 2021, NetApp, Inc
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import absolute_import, division, print_function
__metaclass__ = type


DOCUMENTATION = """
---
module: update_conf
short_description: Update standard Linux conf files
description:
    - Update an existing standard Linux conf file with the specified options and write the copy to the destination.
author: Nathan Swartz (@ndswartz)
options:
    path:
        description: Path to standard Linux conf file to be updated.
        type: str
        required: false
    src:
        description: Source for the base standard Linux conf file.
        type: str
        required: false
    dest:
        description: Destination for the updated standard Linux conf file.
        type: str
        required: false
    options:
        description: Dictionary containing the options key-value pairs to update conf file.
        type: dict
        required: false
        default: {}
    pattern:
        description:
            - Regular expression pattern to capture and update options
            - Must return three groups in the format "^(option)(equivalence)(value)$.
        type: str
        required: false
        default: "^([A-Za-z0-9_-]+)( *= *)(.*)$"
    padding:
        description: Ensures there's padding after the equivalence.
        type: bool
        require: false
    mode:
        description:
            - The file permissions the file should have in octal number form ("0644", "644")
            - When not specified the file permissions will be determined by the operating system defaults.
        type: str
        required: false
"""

EXAMPLES = """
- name: test update_conf module
  netapp_eseries.beegfs.update_conf:
    path: /root/beegfs-mgmtd.conf
    options: {connMgmtdPortTCP: 8008, connMgmtdPortUDP: 18008}
    mode: "0644"
  become: true

- name: test update_conf module
  netapp_eseries.beegfs.update_conf:
    src: /etc/beegfs/beegfs-mgmtd.conf
    dest: /root/beegfs-mgmtd.conf
    options: {connMgmtdPortTCP: 8008, connMgmtdPortUDP: 18008}
    mode: "0644"
  become: true
"""

from ansible.module_utils._text import to_native
from ansible.module_utils.basic import AnsibleModule
import re
from os.path import exists
from os import chmod, stat

class CreateConfFile(object):
    def __init__(self):
        ansible_options = dict(
            path=dict(type="str", require=False),
            src=dict(type="str", require=False),
            dest=dict(type="str", require=False),
            options=dict(type="dict", required=False, default={}),
            pattern=dict(type="str", required=False, default="^([A-Za-z0-9_-]+)( *= *)(.*)$"),
            padding=dict(type="bool", required=False, default=True),
            mode=dict(type="str", required=False)
        )
        self.module = AnsibleModule(argument_spec=ansible_options,
                                    mutually_exclusive=[["path", "src"]],
                                    required_together=[["src", "dest"]],
                                    supports_check_mode=True)

        args = self.module.params
        if args["path"]:
            self.src = args["path"]
            self.dest = args["path"]
        else:
            self.src = args["src"]
            self.dest = args["dest"]
        self.options = args["options"]
        self.pattern = args["pattern"]
        self.padding = args["padding"]
        self.mode = args["mode"]

        self.copy_lines_cached = None
        self.update_required_cached = None

    @property
    def updated_copy(self):
        """Create a copy of the source conf file in memory and update the options."""
        options = self.options.keys()

        if self.copy_lines_cached is None:
            with open(self.src, "r") as fh:
                self.copy_lines_cached = fh.readlines()

            # Update the copy with the options provided.
            for index, line in enumerate(self.copy_lines_cached):
                result = re.search(self.pattern, line)
                if result:
                    option, equivalence, value = list(result.groups())
                    if option in options:
                        if self.padding:
                            self.copy_lines_cached[index] = "%s%s %s\n" % (option, equivalence.rstrip(" "), str(self.options.pop(option)))
                        else:
                            self.copy_lines_cached[index] = "%s%s%s\n" % (option, equivalence, str(self.options.pop(option)))
            
            if self.options:
                self.module.warn("Warning! Option(s) were not used. Options: [%s]" % ", ".join(self.options))
        
        return self.copy_lines_cached

    @property
    def update_required(self):
        """Determine whether and update is required."""
        if self.update_required_cached is None:

            self.update_required_cached = False
            if exists(self.dest):
                with open(self.dest, "r") as fh:
                    self.update_required_cached = self.updated_copy != fh.readlines()
                
                if self.mode:
                    mode = oct(stat(self.dest).st_mode)[-1 * len(self.mode):]
                    if self.mode != mode:
                        update_required_cached = True
            else:
                self.update_required_cached = True

        return self.update_required_cached

    def write_copy(self):
        """Write copy to the destination."""
        with open(self.dest, "w") as fh:
            fh.writelines(self.updated_copy)

        if self.mode:
            chmod(self.dest, int("0o%s" % self.mode, 8))

    def apply(self):
        """Determine and apply any required change to a copy of the source conf file."""
        if self.update_required and not self.module.check_mode:
            self.write_copy()

        self.module.exit_json(changed=self.update_required)

def main():
    create_conf = CreateConfFile()
    create_conf.apply()


if __name__ == "__main__":
    main()
