# (c) 2020, NetApp, Inc
# BSD-3 Clause (see COPYING or https://opensource.org/licenses/BSD-3-Clause)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = """
    lookup: eseries_template_path
    author: Nathan Swartz
    short_description: Searches playbook's directory for expected templates file before using the E-Series role's.
    description:
      - Attempts to find the template source file first in the playbook's directory under templates/<ROLES_NAME>/ otherwise use the role's template file.
      - Provides a mechanism for users to override NetApp E-Series Ansible role's templates.
    options:
      relative_filepath:
        description: Roles template source file. 
        required: true
"""
import os
from ansible.plugins.lookup import LookupBase


class LookupModule(LookupBase):
    def run(self, relative_filepath, variables=None, **kwargs):
        playbook_dir_templates_path = "%s/templates/%s/" % (variables["playbook_dir"], variables["role_name"])
        path = "%s%s" % (playbook_dir_templates_path, relative_filepath[0])
        if os.path.exists(path):
            return [path]

        return [relative_filepath[0]]
