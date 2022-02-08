# Override Default Templates
Most parameters (i.e., NUMA zones) in the default templates used to build the BeeGFS cluster already have variables 
that allow the values to be specified as described in the getting started readme. However, in the case where certain
parameters weren't setup with a variable then you can override the templates to add new variables.

Any templates found in beegfs_ha_7_2/templates/ can be overridden but this should only be done when absolutely necessary 
to avoid BeeGFS configuration issues.

An example of the special case would be if the default NTP configuration need additional settings to 
comply to the security policies of your organization.

<br>

## Table of Contents
------------
1. [Override Default Templates](#how-to-override-the-default-templates)
2. [Parameters Override with Jinja2 Expression](#parameters-override-with-jinja2-expression)

<br>

<a name="how-to-override-the-default-templates"></a>
## How to Override the Default Templates
--------------------------
To override the default template(s), make a copy of the desired template(s) in 
<YOUR_PLAYBOOK_DIRECTORY>/templates/beegfs_ha_7_2/<RELATIVE_TEMPLATE_PATH>/<TEMPLATE_NAME>.

Then make your modifications to the file(s) by replacing the default configuration value with a new value or with
a Jinja2 expression. Make sure to NOT modify the existing Jinja2 statements in the new files.

When you run your playbook, the new templates will be used instead of the default templates.

Here is an example of the override template in the playbook directory:

    my_beegfs_project/
        templates/                                   # Newly created directory structure or created previously
            beegfs_ha_7_2/
                common/
                    chrony_conf.j2
        playbook.yml
        inventory.yml

<br>

<a name="parameters-override-with-jinja2-expression"></a>
## Parameters Override with Jinja2 Expression
------------
If you're replacing the value with a Jinja2 expression and for consistency, ensure a default is provided 
in the case the new variable is unset, we recommend the following Jinja2 expression is used:

    {{ beegfs_ha_<VARIABLE_X> | default(<DEFAULT_VALUE>) }}.

For example, you want to replace the line `TimeoutStopSec=300` in management/beegfs_mgmtd_service.j2 with an expression.
You would change it to `TimeoutStopSec={{ beegfs_ha_timeoutStopSec | default('300') }}`. Then simply set
`beegfs_ha_timeoutStopSec` variable under group_vars/mgmt.yml with the desired value.