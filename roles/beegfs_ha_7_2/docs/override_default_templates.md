## Table of Contents
1. Override Default Templates (#override-default-templates)

## Override Default Templates
--------------------------
All templates found in beegfs_ha_7_2/templates/ can be overridden by create a template in <PLAYBOOK_DIRECTORY>/templates/beegfs_ha_7_2/<RELATIVE_TEMPLATE_PATH>/<TEMPLATE_NAME>. Start by copying the default template and make your modifications to it. Do not modify the existing Jinja2 statements.

    beegfs_project/
        templates/
            beegfs_ha_7_2/
                metadata/
                    beegfs_meta_conf.j2
                storage/
                    beegfs_storage_conf.j2
        playbook.yml
        inventory.yml

You may wish to override some configuration parameters found in these templates on a per-resource group basis. While common parameters (for example NUMA zones) already have a variable that can be set in each resource group's "group_vars" file, you can easily modify the templates to be able to specify your own variables by replacing the default configuration value with a Jinja2 expression. For consistency and to ensure a default is provided if the variable is unset, we recommend the following Jinja2 expression: {{ beegfs_ha_X | default(<DEFAULT_VALUE>) }}. For example you could replace the line tuneNumStreamListeners = 1 with tuneNumStreamListeners = {{ beegfs_ha_tuneNumeStreamListeners | default('1') }}. Then simply set beegfs_ha_tuneNumeStreamListeners under any of the group_vars/<resource_group>.yml you want to override.