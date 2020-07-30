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
  echo 'Running Start ...'
  stop
  buildFlag=${1}

  # run docker container
  echo "  sudo docker-compose -f ${dockerCompose} up ${buildFlag} ${2} --remove-orphans ${site}"
  sudo docker-compose -f ${dockerCompose} up ${buildFlag} ${2} --remove-orphans ${site}
  scriptStatus=$?
  checkStatus $scriptStatus "docker-compose"

  echo "Call open Browswer"
  openBrowser
}

stop()
{
    echo "Stopping ...."
    echo "  sudo docker-compose -f ${dockerCompose} stop ${site}"
    sudo docker-compose -f ${dockerCompose} stop $site
}

connect()
{
  echo "Connection to ${1} container ..."
  sudo docker exec -it ${1} bash
}

log()
{
  echo "Displaying logs for ${site} container ..."
  sudo docker-compose -f ${dockerCompose} logs -t $site
}

openBrowser()
{
  dir=`pwd`
  url="file://${dir}/index.html"
  echo "Opening Browser to ${url}"
  open ${url}
}

setWebSite()
{
  echo '1. Klines martial Arts'
  echo '2. Chris Kline'
  echo '3. Tech X Web'
  echo '4. Manners N More'
  echo '5. Marty Jo'
  echo '6. Pawsitive Connections Training'
  echo '7. Toky Maille'
  echo ''
  echo 'Please enter a number to connect to that server > '
  read conChoice
  ser=""
  case $conChoice in
    1 )
      server="kma-httpd-server"
      site="kma"
      ;;
    2 )
      server="cek-httpd-server"
      site="cek"
      ;;
    3 )
      server="txw-httpd-server"
      site="txw"
      ;;
    4 )
      server="mnm-httpd-server"
      site="mnm"
      ;;
    5 )
      server="mjb-httpd-server"
      site="mjb"
      ;;
    6 )
      server="pct-httpd-server"
      site="pct"
      ;;
    7 )
      server="tkm-httpd-server"
      site="tkm"
      ;;
    * )
      echo "Please enter a valid number"
      exit 1
  esac
  echo "Server set to - ${site}"   
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
site=""
server=""

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
  connect )
    # echo "Got a connect command";
    shift
    setWebSite
    connect $server
    ;;
  log )
    # echo "Got a log command";
    shift
    setWebSite
    log
    ;;
  start )
    # echo "Got a start command";
    shift
    setWebSite
    start "$build" "$detached"
    ;;
  stop )
    # echo "Got a stop command";
    shift
    setWebSite
    stop
    ;;
  * )
    usage
    exit 0
    ;;
esac;

exit 0