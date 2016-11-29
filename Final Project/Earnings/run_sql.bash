sqlcmd -U 'IVYuser' -P 'resuyvi' -S vita.ieor.columbia.edu -i "OpenInterestEarningsCreation.sql"

folders=(
    "sql_1-20"
    "sql_1-10"
    "sql_1-30"
    "sql_2-20"
    "sql_2-10"
    "sql_2-30"
    "sql_3-20"
    "sql_3-10"
    "sql_3-30"
)

for folder in "${folders[@]}"; do
    echo $folder
    file_count=$(ls $folder/*.sql | wc -l)
    for x in $folder/*.sql; do
        sqlcmd -U 'IVYuser' -P 'resuyvi' -S vita.ieor.columbia.edu -i "$x" > /dev/null
        echo "$x,status $?" >> sql.log

        # Update progress bar
        echo -n X
    done | pv -s ${file_count} - > /dev/null
done
