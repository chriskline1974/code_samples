#!/bin/sh

usage()
{
	echo "
  Usage:
    $0 [options] [COMMAND]
    $0 -h

  Options:
    -b              adds build option to docker-compose command
    -c              run container in console mode
    -d <file name>  docker compose file
    -h              Print this help and exit successfully.

  Commands:
    connect         connects to the Httpd server
    log             display log for container
    start           starts the containers
    stop            stops the containers
    "
}

checkForSetup() {
  echo
  echo 'Checking for setup....'

  return 1
}

setup()
{
  echo
  echo 'Running httpd Setup ...'

  # cleanup old directories
  cleanup
}

cleanup()
{
  echo 'Running Httpd Cleanup ...'
}

checkStatus()
{
  # echo "** Return status from ${2} script was ${1}"
  if [ ${1} -gt 0 ]; then
    # echo 'Error with the script exiting!'
    exit 1
  else
    echo "Command ${2} completed successfully"
  fi
}

start()
{
  echo 'Running Httpd Start ...'
  stop
  buildFlag=${1}

  checkForSetup
  setupStatus=$?
  #echo "setup status is ${setupStatus}"
  if [ $setupStatus == 2 ]; then
    # if not setup run setup
    echo "Setup not run doing it now"
    setup
    buildFlag="--build"
  fi

  echo "Starting ...."
  # run docker container
  echo "  sudo docker-compose -f ${dockerCompose} up ${buildFlag} ${2} --remove-orphans kma"
  sudo docker-compose -f ${dockerCompose} up ${buildFlag} ${2} --remove-orphans kma
  scriptStatus=$?
  checkStatus $scriptStatus "docker-compose"
}

stop()
{
    echo "Stopping ...."
    echo "  sudo docker-compose -f ${dockerCompose} stop kma"
    sudo docker-compose -f ${dockerCompose} stop kma
}

connect()
{
  echo 'Connection to KMA httpd container ...'
  sudo docker exec -it ${1} bash
}

log()
{
  echo 'Displaying logs for httpd container ...'
  sudo docker-compose -f ${dockerCompose} logs -t kma
}


# Check for arguments if non supplied, display usage
if [ "$1" == "" ]; then
	echo "You must supply an argument!"
	usage
	exit 1
fi

# Start the main script
detached="-d"
build=""
dockerCompose="./docker-compose.yml"
lb=""

# Parse options to the command
while getopts ":bcd:h" opt; do
  case ${opt} in
    b )
      # echo 'build mode accepted'
      build="--build"
      ;;
    c )
      # echo 'Non Detached mode accepted'
      detached=""
      ;;
    d )
      # echo 'Non Detached mode accepted'
      dockerCompose=$OPTARG
      ;;
    h )
      usage
      exit 0
      ;;
    : )
      echo "Must supply a value for -$OPTARG" 1>&2
      exit 1
      ;;
    \? )
      usage
      exit 0
      ;;
  esac
done
shift $((OPTIND -1))

subcommand=$1; shift  # Remove 'pip' from the argument list
case "$subcommand" in
  cleanup )
    # echo "Got a cleanup command";
    shift
    cleanup
    ;;
  connect )
    # echo "Got a connect command";
    shift
    connect kma-httpd-server
    ;;
  log )
    # echo "Got a log command";
    shift
    log
    ;;
  setup )
    # echo "Got a setup command";
    shift  # Remove 'setup' from the argument list
    setup
    ;;
  start )
    # echo "Got a start command";
    shift
    start "$build" "$detached"
    ;;
  stop )
    # echo "Got a stop command";
    shift
    stop
    ;;
  * )
    usage
    exit 0
    ;;
esac;

exit 0