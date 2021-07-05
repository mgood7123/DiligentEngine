if [[ $# < 3 ]]
    then
        echo "$0 <folder> <extension> <command_to_get_chmod_info>"
        echo "folder                    - the folder to search for files"
        echo "extension                 - the file extension to split by"
        echo "command_to_get_chmod_info - a command that outputs the    "
        echo "                            file's permission flags       "
        echo "                            eg output 777 for permissions "
        echo "                            of read, write, and execute   "
        exit 1
fi

FOLDER=$1
NAME=\*.$2

find $FOLDER -name $NAME -exec bash -c "\
DIR=\"\$(dirname {})\"; \
BASE=\"\$(basename {})\"; \
cd \$DIR; \
echo \"size in bytes is -            \$(wc -c \$BASE)\"; \
echo \"size in bytes for splitting is - \$((1024*1024*1024*90))\"; \
if [[ \$(wc -c \$BASE) > \$((1024*1024*1024*90)) ]]; \
    then \
        echo \$BASE qualifies for splitting; \
        echo creating split info for \$BASE; \
        touch \$BASE.SPLIT_MARKER; \
        echo \$BASE > \$BASE.SPLIT_MARKER_NAME; \
        $3 \$BASE > \$BASE.SPLIT_MARKER_CHMOD; \
        echo created split info for \$BASE; \
        echo splitting \$BASE; \
        split -b 90M \$BASE \$BASE.SPLIT_FILE; \
        rm \$BASE; \
        echo split \$BASE; \
    else \
        echo \$BASE does not qualify for splitting; \
fi" \
\;
