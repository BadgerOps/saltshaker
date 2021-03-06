#!/usr/bin/env bash

# AUTOGENERATED VIA SALT! DO NOT EDIT!

{% for envvar, value in envvars.items() %}
export {{envvar}}="{{value}}"
{% endfor %}

if [ ! -e /etc/duplicity.d ]; then
    echo "configuration folder /etc/duplicity.d is missing"
    exit 1;
fi

if [ $# -ne 1 ]; then
    echo "usage: duplicity-backup.sh [crontype]"
    echo "where [crontype] is the name of a subfolder of /etc/duplicity.d"
    echo ""
    echo "This script will execute all executable files in"
    echo "/etc/duplicity.d/[ct]/prescripts without recursing into subfolders. It will then"
    echo "backup folders symlinked from /etc/duplicity.d/[ct]/folderlinks taking care to"
    echo "check if prescripts or postscripts contains a folder of the same name as the"
    echo "symlink. If they do t\is script will execute these pre and postscripts before"
    echo "and after backing up the symlink's target folder."
    echo "After completing all backup jobs, this script will execute all executable"
    echo "files in /etc/duplicity.d/[ct]/postscripts without recursing into subfolders."
    echo "This allows you to execute scripts before and after all of the backups by just"
    echo "dropping them into /etc/duplicity.d/[ct]/prescripts and "
    echo "/etc/duplicity.d/[ct]/postscripts and also execute them before and after each"
    echo "individual backup job by putting them into subfolders of prescripts/postscripts"
    echo "that share the symlinks name in /etc/duplicity.d/folderlinks."
    echo ""
    echo "Valid detected [crontype] values are:"
    for DIR in /etc/duplicity.d/*; do
        if [ -d $DIR ]; then
            echo "    $(basename $DIR)"
        fi
    done
    exit 1;
fi

if [ ! -e "/etc/duplicity.d/$1" ]; then
    echo "folder does not exist /etc/duplicity.d/$1"
    exit 1;
fi

if [ ! -x /usr/bin/duplicity ]; then
    echo "/usr/bin/duplicity does not exist or is not executable"
    exit 1;
fi

for PRESCRIPT in /etc/duplicity.d/$1/prescripts/*; do
    [ -e "$PRESCRIPT" ] || continue
    if [ ! -d $PRESCRIPT ] && [ -x $PRESCRIPT ]; then
        echo "executing prescript:$PRESCRIPT"
        $PRESCRIPT
    else
        continue
    fi
done

for LINK in /etc/duplicity.d/$1/folderlinks/*; do
    [ -e "$LINK" ] || continue
    FOLDER=""
    BL="$(basename $LINK)"
    if [ -h $LINK ]; then
        FOLDER="$(readlink $LINK)"
    else
        echo "$LINK is not a symlink. /etc/duplicity.d/$1/folderlinks/ should only contain symlinks"
        continue
    fi

    if [ -d "/etc/duplicity.d/$1/prescripts/$BL" ]; then
        for PRESCRIPT in /etc/duplicity.d/$1/prescripts/$BL/*; do
            if [ -x $PRESCRIPT ]; then
                echo "executing prescript:$BL:$(basename $PRESCRIPT)"
                $PRESCRIPT
            else
                echo "warning: $PRESCRIPT"
                echo "    is not executable. Subfolders of /etc/duplicity.d/[ct]/prescripts should"
                echo "    only contain script files."
            fi
        done
    fi

    echo "Running duplicity {% if additional_options %}{{additional_options|replace('"', '\"')}}{% endif %}" \
         "{% for key_id in gpg_keys %}--encrypt-key={{key_id|replace('"', '\"')}} {% endfor %}" \
         "{% if gpg_options %}--gpg-options='{{gpg_options|replace('"', '\"')}}'{% endif %} " \
         "$FOLDER {{backup_target_url}}"

    /usr/bin/duplicity {% if additional_options %}{{additional_options}}{% endif %} \
        {% for key_id in gpg_keys %}--encrypt-key={{key_id}} {% endfor %} \
        {% if gpg_options %}--gpg-options='{{gpg_options}}'{% endif %} $FOLDER {{backup_target_url}}

    if [ -d "/etc/duplicity.d/$1/postscripts/$BL" ]; then
        for POSTSCRIPT in /etc/duplicity.d/$1/postscripts/$BL/*; do
            if [ -x $POSTSCRIPT ]; then
                echo "executing postscript:$BL:$(basename $POSTSCRIPT)"
                $POSTSCRIPT
            else
                echo "warning: $POSTSCRIPT"
                echo "    is not executable. Subfolders of /etc/duplicity.d/[ct]/postscripts"
                echo "    should only contain script files."
            fi
        done
    fi
done

for POSTSCRIPT in /etc/duplicity.d/$1/postscripts/*; do
    [ -e "$POSTSCRIPT" ] || continue
    if [ ! -d $POSTSCRIPT ] && [ -x $POSTSCRIPT ]; then
        echo "executing postscript:$POSTSCRIPT"
        $POSTSCRIPT
    else
        continue
    fi
done
