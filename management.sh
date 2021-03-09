#! /bin/bash

# Show binary log list from the container
show_binary_logs() {
    docker exec -it $database_container_name mysql -u $database_user --password=$database_password -e "SHOW BINARY LOGS;"
    do_menu
}

# Show current active binary log
show_active_binary() {
    docker exec -it $database_container_name mysql -u $database_user --password=$database_password -e "SHOW MASTER STATUS;"
    do_menu
}

# Select the binary log required. 
select_active_binary() {
    read -p "Enter the desired binary: " active_binary
    if [[ "$active_binary" != \mysql-bin.* ]]; then 
        echo "Not Valid, Please use the exact name" 
        select_active_binary
    else
        echo "Selected Binary: " $active_binary
        do_menu
    fi
}

# Show the selected binary log
show_log() {
    docker exec -it $database_container_name mysqlbinlog --verbose /var/lib/mysql/$active_binary
    do_menu
}

# Select start/end position of the database binary log
select_time() {
    read -p "Enter start position from the binary log: " start_position
    read -p "Enter end position from the binary log: " stop_position
}

#Create new database from the selected binary log position
create_new_database() {
    #create statements.sql file and prepare it to be loaded in the second database
    docker exec -it $database_container_name bash -c "mysqlbinlog --start-position=$1 --stop-position=$2 --rewrite-db='$database_name->$database_backup_name'     /var/lib/mysql/$3 > /tmp/statements.sql"
    #Load the file to the second database. 
    docker exec -it $database_container_name mysql -u $database_user --password=$database_password -e "source /tmp/statements.sql"
    do_menu
}

# Menu Options
show_menus() {
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo " MySQL management Menu"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "  1. Show Binary Logs"
    echo "  2. Show Active Binary"
    echo "  3. Select Binary"
    echo "  4. Show Log for selected timeframe"
    echo "  5. Create another database from selected binary positions"
    echo "  6. Exit"
    echo ""
}

# Read selection and execute the required function
read_options(){
    local choice
    read -p "Enter choice [ 1 - 6 ] " choice
    case $choice in
    1) show_binary_logs;;
    2) show_active_binary;;
    3) select_active_binary;;
    4) show_log;;
    5) select_time && create_new_database $start_position $stop_position $active_binary;;
    6) exit 0;;
    *) echo -e "Error..." && sleep 2 && exit 0
    esac
}

# Initialize menu
do_menu() {
    show_menus
    read_options
}

# Load Environment Variables
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
    else
        echo "No enviroment file found." && exit 0
fi
# Show Menu and selection
do_menu