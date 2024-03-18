<a name="override-default-templates"></a>
# Override Default Templates

Any templates found in beegfs_ha_common/templates/ can be overridden but this should only be done when absolutely necessary 
to avoid BeeGFS configuration issues.

An example of the special case would be if the default NTP configuration need additional settings to 
comply to the security policies of your organization.

<a name="table-of-contents"></a>
## Table of Contents

- [Override Default Templates](#override-default-templates)
  - [Table of Contents](#table-of-contents)
  - [How to Override the Default Templates](#how-to-override-the-default-templates)
  - [Parameters Override with Jinja2 Expression](#parameters-override-with-jinja2-expression)

<a name="how-to-override-the-default-templates"></a>
## How to Override the Default Templates

To override the default template(s), make a copy of the desired template(s) in 
<YOUR_PLAYBOOK_DIRECTORY>/templates/beegfs_ha_common/<RELATIVE_TEMPLATE_PATH>/<TEMPLATE_NAME>.

Then make your modifications to the file(s) by replacing the default configuration value with a new value or with
a Jinja2 expression. Make sure to NOT modify the existing Jinja2 statements in the new files.

When you run your playbook, the new templates will be used instead of the default templates.

Here is an example of the override template in the playbook directory:

    my_beegfs_project/
        templates/                                   # Newly created directory structure or created previously
            beegfs_ha_common/
                common/
                    chrony_conf.j2
        playbook.yml
        inventory.yml

<a name="parameters-override-with-jinja2-expression"></a>
## Parameters Override with Jinja2 Expression

If you're replacing the value with a Jinja2 expression and for consistency, ensure a default is provided 
in the case the new variable is unset, we recommend the following Jinja2 expression is used:

    newly_defined_parameter={{ beegfs_ha_<VARIABLE_X> | default(<DEFAULT_VALUE>) }}
