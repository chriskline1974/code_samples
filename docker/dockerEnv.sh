#!/bin/sh

usage()
{
	echo "
    Usage: $0 [setup|build|start|stop|stopAndPurge|list|connectNode|connectDb|connectTomcat|connectHttpd|connectActiveMQ1|connectJESB|connectLdap]
      setup            Downloads and creates scaffolding for build
      build            builds the containers
      start            starts the containers
      stop             stops the containers
      stopAndPurge     stops and removes the containers
      list             lists running containers
      connectKMAHttpd  connects to the apache web server
    "
}

setup()
{
  echo
  echo 'Running Setup.... This may take a little while'

  # cleanup old directories
  cleanup

  # build all now
  build
}

build() {
  echo
  echo 'Building the docker images'
  # build the image
  sudo docker-compose up --build --remove-orphans -d
  list
}

start()
{
  # sudo docker run -it nodesvr /bin/bash
  sudo docker-compose up -d
  list
}

stop()
{
  echo 'Stoping and removing all servers'
  sudo docker-compose down -v --remove-orphans
}

stopAndPurge()
{
  echo 'Stoping and removing all servers'
  sudo docker-compose down -v --rmi all --remove-orphans
}

# list the containers that where built
list()
{
  echo
  echo 'Docker Image Information'
  echo

  sudo docker container ls
  ws=`sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kma-httpd-server`
  ws1=`sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cek-httpd-server`
  ws2=`sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' txw-httpd-server`
  ws3=`sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mnm-httpd-server`
  ws4=`sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mjb-httpd-server`
  ws5=`sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' pct-httpd-server`
  ws6=`sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' tkm-httpd-server`

  echo 'IP Address'
  echo 'kma-httpd-server      '$ws
  echo 'cek-httpd-server      '$ws1
  echo 'txw-httpd-server      '$ws2
  echo 'mnm-httpd-server      '$ws3
  echo 'mjb-httpd-server      '$ws4
  echo 'pct-httpd-server      '$ws5
  echo 'tkm-httpd-server      '$ws6
}

deepClean()
{
  stop
  sudo docker container prune -f
  sudo docker volume prune -f
  sudo docker image prune -f
}

connectServer()
{
  echo "Connecting to server $1"
  sudo docker exec -it $1 bash
}

cleanup() {
  echo 'Cleaning up'
}

if [ "$1" == "" ]; then
	echo "You must supply an argument!"
	usage
	exit 1
fi

# Start the main script

while [ "$1" != "" ]; do
    case $1 in
        setup)
                setup
                ;;
        start)
                start
                ;;
        stop)
                stop
                ;;
        stopAndPurge)
                stopAndPurge
                ;;
        list)
                list
                ;;
        build)
                build
                ;;
        connect)
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
                    ser="kma-httpd-server"
                    ;;
                  2 )
                    ser="cek-httpd-server"
                    ;;
                  3 )
                    ser="txw-httpd-server"
                    ;;
                  4 )
                    ser="mnm-httpd-server"
                    ;;
                  5 )
                    ser="mjb-httpd-server"
                    ;;
                  6 )
                    ser="pct-httpd-server"
                    ;;
                  7 )
                    ser="tkm-httpd-server"
                    ;;
                  * )
                    echo "Please enter a valid number"
                    exit 1
                esac
                echo "Connecting to server - ${ser}"   
                connectServer $ser
                ;;
        purgeall)
                deepClean
                ;;
        *)
                usage
                ;;
    esac
    shift
done

exit 0
